import 'dart:developer' as developer;

import 'package:beatsync_app/core/services/camera_service.dart';
import 'package:beatsync_app/di/main_injection.dart';
import 'package:beatsync_app/features/heart_rate/presentation/cubit/heart_rate_cubit.dart';

import 'package:beatsync_app/features/heart_rate/presentation/widgets/realtime_bpm_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class HeartRateScreen extends HookWidget {
  const HeartRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(() => sl<HeartRateCubit>(), []);
    final cameraService = useMemoized(() => sl<CameraService>(), []);

    useEffect(() {
      Future<void> checkPermission() async {
        var status = await Permission.camera.status;
        if (!status.isGranted) {
          await Permission.camera.request();
        }
      }

      checkPermission();
      return () {};
    }, [cubit, cameraService]);

    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocConsumer<HeartRateCubit, HeartRateState>(
            listener: (context, state) {
              developer.log(
                  '[HeartRateScreen] Listener triggered. New state: ${state.runtimeType}',
                  name: 'UI');
              if (state is HeartRateFailure) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.statusMessage ?? 'An unknown error occurred.'),
                  backgroundColor: Colors.red,
                ));
              }
            },
            builder: (context, state) {
              developer.log(
                  '[HeartRateScreen] Builder rebuilding. Current state: ${state.runtimeType}',
                  name: 'UI');
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Flexible(
                    flex: 2,
                    child: _StatusInstructionDisplay(state: state),
                  ),
                  Expanded(
                    flex: 5,
                    child: _BpmChartZone(state: state),
                  ),
                  Flexible(
                    flex: 3,
                    child: _CameraPreviewAreaFramework(
                        state: state, cameraService: cameraService),
                  ),
                  _ControlButtonsArea(cubit: cubit, state: state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatusInstructionDisplay extends StatelessWidget {
  final HeartRateState state;
  const _StatusInstructionDisplay({required this.state});

  @override
  Widget build(BuildContext context) {
    Widget content;
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    if (state is HeartRateInitial) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Place your finger gently over the camera and flash.",
              style: textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text("Tap 'START' to begin.",
              style: textTheme.bodyLarge, textAlign: TextAlign.center),
        ],
      );
    } else if (state is HeartRateLoading) {
      final loadingState = state as HeartRateLoading;
      List<Widget> loadingWidgets = [
        Flexible(
          child: Text(
              loadingState.statusMessage ??
                  (loadingState.isFakeMode ? "Simulating..." : "Measuring..."),
              style: textTheme.titleLarge,
              textAlign: TextAlign.center),
        ),
        Text("Time remaining: ${loadingState.countdownValue}s",
            style: textTheme.titleMedium, textAlign: TextAlign.center),
      ];

      if (!loadingState.isFakeMode) {
        IconData indicatorIcon = Icons.circle_outlined;
        Color indicatorColor = Colors.grey;
        String indicatorText = "";

        switch (loadingState.fingerDetectionStatus) {
          case FingerDetectionStatus.goodSignal:
            indicatorIcon = Icons.check_circle;
            indicatorColor = Colors.green;
            indicatorText = "Finger detected clearly";
            break;
          case FingerDetectionStatus.poorSignal:
            indicatorIcon = Icons.warning_amber_rounded;
            indicatorColor = Colors.orange;
            indicatorText = "Adjust finger position";
            break;
          case FingerDetectionStatus.noFinger:
            indicatorIcon = Icons.highlight_off;
            indicatorColor = Colors.red;
            indicatorText = "Place finger on camera";
            break;
          case FingerDetectionStatus.notApplicable:

            indicatorText = "Align finger with camera...";
            break;
        }
        if (indicatorText.isNotEmpty) {
          loadingWidgets.add(const SizedBox(height: 4));
          loadingWidgets.add(Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(indicatorIcon, color: indicatorColor, size: 20),
              const SizedBox(width: 8),
              Text(indicatorText,
                  style: textTheme.bodyLarge?.copyWith(color: indicatorColor)),
            ],
          ));
        }
      }
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: loadingWidgets,
      );
    } else if (state is HeartRateDataReady) {
      content = Text(state.statusMessage ?? "Measurement Complete!",
          style: textTheme.headlineSmall, textAlign: TextAlign.center);
    } else if (state is HeartRateFailure) {
      content = Text(state.statusMessage ?? "An error occurred.",
          style: textTheme.titleLarge?.copyWith(color: theme.colorScheme.error),
          textAlign: TextAlign.center);
    } else {

      content = Text(state.statusMessage ?? "Status: ${state.runtimeType}",
          style: textTheme.titleMedium, textAlign: TextAlign.center);
    }

    String countdownKeyPart = "";
    String fingerStatusKeyPart = "";
    if (state is HeartRateLoading) {
      final loadingState = state as HeartRateLoading;
      countdownKeyPart = loadingState.countdownValue.toString();
      fingerStatusKeyPart = loadingState.fingerDetectionStatus.toString();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: Container(
        key: ValueKey<String>(state.runtimeType.toString() +
            (state.statusMessage ?? "") +
            countdownKeyPart +
            fingerStatusKeyPart),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}

class _BpmChartZone extends StatelessWidget {
  final HeartRateState state;
  const _BpmChartZone({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BpmDisplay(state: state),
          const SizedBox(height: 16),
          Expanded(
              child: RealtimeBpmChart(
            dataPoints: (state is HeartRateDataReady)
                ? (state as HeartRateDataReady).emaValues
                : (state is HeartRateLoading)
                    ? (state as HeartRateLoading).liveChartData
                    : const [],
          )),
        ],
      ),
    );
  }
}

class _CameraPreviewAreaFramework extends StatelessWidget {
  final HeartRateState state;
  final CameraService cameraService;

  const _CameraPreviewAreaFramework({required this.state, required this.cameraService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget content;

    if (state is HeartRateLoading) {


      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),

          Text(state.statusMessage ?? "Processing...", style: theme.textTheme.bodyLarge),
        ],
      );

      return Container(
        width: double.infinity,
        height: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5))),
        child: Center(child: content),
      );
    } else if (state is HeartRateInitial && !state.isFakeMode) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined,
              size: 48, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7)),
          const SizedBox(height: 8),
          Text("Camera Area",
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7))),
        ],
      );
      return Container(
        width: double.infinity,
        height: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: content),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class _BpmDisplay extends StatelessWidget {
  final HeartRateState state;
  const _BpmDisplay({required this.state});

  @override
  Widget build(BuildContext context) {
    String mainText;
    String subText;
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    if (state is HeartRateInitial) {
      mainText = "--";
      subText = "Ready to measure";
    } else if (state is HeartRateLoading) {
      final loadingState = state as HeartRateLoading;
      mainText = loadingState.bpm?.toStringAsFixed(0) ?? "...";


      if (loadingState.isFakeMode) {

        subText = "Live Reading"; 
      } else {
        switch (loadingState.fingerDetectionStatus) {
          case FingerDetectionStatus.goodSignal:
            subText = "Live Reading";
            break;
          case FingerDetectionStatus.poorSignal:
            subText = "Adjust Finger Position";
            break;
          case FingerDetectionStatus.noFinger:
            subText = "Place Finger on Camera";
            break;
          case FingerDetectionStatus.notApplicable:
            subText = "Initializing...";
            break;
        }
      }
    } else if (state is HeartRateDataReady) {
      final readyState = state as HeartRateDataReady;
      mainText = "${readyState.bpm?.toStringAsFixed(0) ?? '--'} BPM";
      subText = "Your Resting Heart Rate";
    } else if (state is HeartRateFailure) {
      mainText = "Failed";
      subText = state.statusMessage ?? "Measurement error";
    } else {
      mainText = "--";
      subText = state.statusMessage ?? state.runtimeType.toString();
    }

    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child));
          },
          child: Text(
            mainText,
            key: ValueKey<String>(
                mainText + (state.bpm?.toString() ?? '') + state.runtimeType.toString()),
            style: GoogleFonts.poppins(
              textStyle: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            subText,
            key: ValueKey<String>(subText + state.runtimeType.toString()),
            style: textTheme.titleMedium?.copyWith(
                color: textTheme.bodySmall?.color?.withOpacity(0.8),
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _ControlButtonsArea extends StatelessWidget {
  final HeartRateCubit cubit;
  final HeartRateState state;

  const _ControlButtonsArea({required this.cubit, required this.state});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final ButtonStyle baseButtonStyle = ButtonStyle(
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
          horizontal: 20, vertical: 12)), 
      textStyle: WidgetStateProperty.all(
        theme.textTheme.labelLarge
            ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.8),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)), 
      ),
      minimumSize:
          WidgetStateProperty.all(const Size(120, 48)), 
    );

    Widget currentButtons;

    if (state is HeartRateInitial) {
      currentButtons = FilledButton.icon(
        icon: const Icon(Icons.play_arrow),
        label: const Text('START'),
        style: baseButtonStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
          foregroundColor: WidgetStateProperty.all(theme.colorScheme.onPrimary),
        ),
        onPressed: () => cubit.startMeasurement(),
      );
    } else if (state is HeartRateLoading) {
      currentButtons = FilledButton.icon(
        icon: const Icon(Icons.stop_circle_outlined),
        label: const Text('STOP'),
        style: baseButtonStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(theme.colorScheme.errorContainer),
          foregroundColor: WidgetStateProperty.all(theme.colorScheme.onErrorContainer),
        ),
        onPressed: () => cubit.stopMeasurement(manualStop: true),
      );
    } else if (state is HeartRateDataReady) {
      currentButtons = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('AGAIN'),
                style: baseButtonStyle.copyWith(
                  side: WidgetStateProperty.all(
                      BorderSide(color: theme.colorScheme.primary)),
                  foregroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
                ),
                onPressed: () => cubit.discardEmaData(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.save_alt_outlined),
                label: const Text('SAVE'),
                style: baseButtonStyle.copyWith(
                  backgroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
                  foregroundColor: WidgetStateProperty.all(theme.colorScheme.onPrimary),
                ),
                onPressed: () => cubit.sendEmaDataToBackend(),
              ),
            ),
          ],
        ),
      );
    } else if (state is HeartRateFailure) {
      currentButtons = FilledButton.icon(
        icon: const Icon(Icons.error_outline_rounded), 
        label: const Text('TRY AGAIN'),
        style: baseButtonStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
          foregroundColor: WidgetStateProperty.all(theme.colorScheme.onPrimary),
        ),
        onPressed: () => cubit.startMeasurement(),
      );
    } else {
      currentButtons = const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Container(
          key: ValueKey<String>(
              state.runtimeType.toString()), 
          child: currentButtons,
        ),
      ),
    );
  }
}
