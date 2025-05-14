import 'package:beatsync_app/di/main_injection.dart';
import 'package:beatsync_app/features/statistics/domain/entities/hrv_analysis_result.dart';
import 'package:beatsync_app/features/statistics/presentation/widgets/bpm_over_time_chart.dart';
import 'package:beatsync_app/features/statistics/presentation/widgets/hrv_metric_chart.dart';
import 'package:beatsync_app/features/statistics/presentation/widgets/metric_card.dart';
import 'package:beatsync_app/features/statistics/presentation/widgets/modern_date_filter_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../cubit/statistics_cubit.dart';

class _MetricInfo {
  final String name;
  final String shortDescription;
  final IconData iconData;
  final String unit;
  final Color? cardAccentBackgroundColor;
  final double Function(HrvAnalysisResult) valueExtractor;
  final Widget Function(BuildContext context, List<HrvAnalysisResult> allResults,
      double Function(HrvAnalysisResult) specificExtractor) chartBuilder;
  final Color? chartLineColor;

  const _MetricInfo({
    required this.name,
    required this.shortDescription,
    required this.iconData,
    required this.unit,
    required this.valueExtractor,
    required this.chartBuilder,
    this.cardAccentBackgroundColor,
    this.chartLineColor,
  });
}

class _AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration delayBase;
  final Duration duration;

  const _AnimatedListItem({
    required this.index,
    required this.child,
    this.delayBase = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(curvedAnimation);

    Future.delayed(Duration(milliseconds: widget.index * widget.delayBase.inMilliseconds),
        () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  String _getAppBarTitle(StatisticsState state) {
    final DateFormat formatter = DateFormat('MMM d, yyyy');
    switch (state.selectedPresetRange) {
      case PresetRange.Today:
        return 'HRV Stats (Today)';
      case PresetRange.SevenDays:
        return 'HRV Stats (Last 7 Days)';
      case PresetRange.ThirtyDays:
        return 'HRV Stats (Last 30 Days)';
      case PresetRange.Last90Days:
        return 'HRV Stats (Last 90 Days)';
      case PresetRange.Custom:
        final start = formatter.format(state.selectedStartDate);
        final end = formatter.format(state.selectedEndDate);
        if (start == end) return 'HRV Statistics ($start)';
        return 'HRV Statistics ($start - $end)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StatisticsCubit>()..fetchUserAnalysisData(),
      child: Builder(
        builder: (scaffoldContext) {
          final cubit = BlocProvider.of<StatisticsCubit>(scaffoldContext);
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
            appBar: AppBar(
              title: BlocBuilder<StatisticsCubit, StatisticsState>(
                buildWhen: (prev, curr) =>
                    prev.selectedPresetRange != curr.selectedPresetRange ||
                    prev.selectedStartDate != curr.selectedStartDate ||
                    prev.selectedEndDate != curr.selectedEndDate,
                builder: (context, state) {
                  return Text(_getAppBarTitle(state),
                      style: Theme.of(context).textTheme.titleLarge);
                },
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: BlocBuilder<StatisticsCubit, StatisticsState>(
                      builder: (context, state) {
                    return ModernDateFilterDisplay(
                      selectedPresetRange: state.selectedPresetRange,
                      selectedStartDate: state.selectedStartDate,
                      selectedEndDate: state.selectedEndDate,
                      onPresetSelected: (preset) {
                        cubit.setPresetRange(preset);
                      },
                      onCustomDateRangeSelected: (range) {
                        final endDateEndOfDay = DateTime(range.end.year, range.end.month,
                            range.end.day, 23, 59, 59, 999);
                        cubit.setDateRange(range.start, endDateEndOfDay);
                      },
                    );
                  }),
                ),
                const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                Expanded(
                  child: BlocBuilder<StatisticsCubit, StatisticsState>(
                    builder: (context, state) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          final curvedAnimation = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOutCubic,
                          );
                          return ScaleTransition(
                            scale: Tween<double>(begin: 0.95, end: 1.0)
                                .animate(curvedAnimation),
                            child: FadeTransition(
                              opacity: curvedAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: _buildContentForState(context, state),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentForState(BuildContext context, StatisticsState state) {
    if (state is StatisticsInitial || state is StatisticsLoading) {
      return _buildLoadingShimmer(context, key: const ValueKey('loading'));
    } else if (state is StatisticsLoaded) {
      return _buildLoadedContent(context, state, key: const ValueKey('loaded'));
    } else if (state is StatisticsError) {
      return _buildErrorState(context, state.message, key: const ValueKey('error'));
    }
    return _buildErrorState(context, 'Something went wrong.',
        key: const ValueKey('unknown_error'));
  }

  Widget _buildLoadingShimmer(BuildContext context, {Key? key, int itemCount = 4}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.6),
        highlightColor:
            Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          itemBuilder: (context, index) => _buildShimmerPlaceholder(context),
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder(BuildContext context) {
    final cardColor = Theme.of(context).colorScheme.surfaceContainer;
    final placeholderColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      height: 200,
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.1),
          )),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 24, height: 24, color: placeholderColor),
                const SizedBox(width: 8),
                Container(width: 100, height: 20, color: placeholderColor),
                const Spacer(),
                Container(width: 24, height: 24, color: placeholderColor),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(color: placeholderColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, StatisticsLoaded state, {Key? key}) {
    if (state.analysisResults.isEmpty) {
      return _buildEmptyState(context, key: key);
    }
    final theme = Theme.of(context);

    final List<_MetricInfo> metrics = [
      _MetricInfo(
        name: "Heart Rate Trend",
        shortDescription: "Your heart rate (BPM) over the selected period.",
        iconData: Icons.monitor_heart_outlined,
        unit: "BPM",
        cardAccentBackgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.1),
        valueExtractor: (r) => r.bpm.toDouble(),
        chartBuilder: (BuildContext context, List<HrvAnalysisResult> data,
            double Function(HrvAnalysisResult) extractorIgnored) {
          if (data.isEmpty) return const Center(child: Text("No BPM data available."));
          double sumBpm = data.fold(0, (sum, item) => sum + item.bpm);
          double avgBpm = data.isNotEmpty ? sumBpm / data.length : 0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, top: 12.0, bottom: 8.0, right: 16.0),
                child: Text(
                  "Average: ${avgBpm.toStringAsFixed(0)} BPM",
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
              ),
              Expanded(child: BpmOverTimeChart(analysisResults: data)),
            ],
          );
        },
      ),
      _MetricInfo(
        name: 'RMSSD',
        shortDescription: 'Reflects short-term vagal (parasympathetic) activity.',
        iconData: Icons.spa_outlined,
        unit: 'ms',
        cardAccentBackgroundColor: Colors.blue.shade50,
        valueExtractor: (r) => r.rmssd,
        chartBuilder: (BuildContext context, List<HrvAnalysisResult> data,
            double Function(HrvAnalysisResult) extractor) {
          return HrvMetricChart(
              analysisResults: data,
              metricExtractor: extractor,
              lineColor: Colors.blue.shade400,
              metricName: 'RMSSD');
        },
        chartLineColor: Colors.blue.shade400,
      ),
      _MetricInfo(
        name: 'SDNN',
        shortDescription:
            'Overall HRV, influenced by both sympathetic & parasympathetic systems.',
        iconData: Icons.timeline_outlined,
        unit: 'ms',
        cardAccentBackgroundColor: Colors.green.shade50,
        valueExtractor: (r) => r.sdnn,
        chartBuilder: (BuildContext context, List<HrvAnalysisResult> data,
            double Function(HrvAnalysisResult) extractor) {
          return HrvMetricChart(
              analysisResults: data,
              metricExtractor: extractor,
              lineColor: Colors.green.shade400,
              metricName: 'SDNN');
        },
        chartLineColor: Colors.green.shade400,
      ),
      _MetricInfo(
        name: 'LF/HF Ratio',
        shortDescription:
            'Index of sympathovagal balance (sympathetic vs. parasympathetic).',
        iconData: Icons.balance_outlined,
        unit: '',
        cardAccentBackgroundColor: Colors.purple.shade50,
        valueExtractor: (r) => r.lfHfRatio,
        chartBuilder: (BuildContext context, List<HrvAnalysisResult> data,
            double Function(HrvAnalysisResult) extractor) {
          return HrvMetricChart(
              analysisResults: data,
              metricExtractor: extractor,
              lineColor: Colors.purple.shade400,
              metricName: 'LF/HF Ratio');
        },
        chartLineColor: Colors.purple.shade400,
      ),
    ];

    return ListView.builder(
        key: key,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: metrics.length,
        itemBuilder: (context, index) {
          final metric = metrics[index];
          return _AnimatedListItem(
            index: index,
            child: MetricCard(
              metricName: metric.name,
              metricDescription: metric.shortDescription,
              analysisResults: state.analysisResults,
              metricExtractor: metric.valueExtractor,
              accentBackgroundColor: metric.cardAccentBackgroundColor,
              chartLineColor: metric.chartLineColor,
              onShowInfoDialog: (BuildContext ctx, String name) =>
                  _showMetricInfoDialog(ctx, name, metric.shortDescription),
            ),
          );
        });
  }

  Widget _buildEmptyState(BuildContext context, {Key? key}) {
    final theme = Theme.of(context);
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.data_usage_rounded,
                size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text(
              'No Data Available',
              style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'There is no HRV analysis data for the selected period. Try adjusting the date range or take a new measurement.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, {Key? key}) {
    final theme = Theme.of(context);
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 64, color: theme.colorScheme.error.withOpacity(0.7)),
            const SizedBox(height: 20),
            Text(
              'Oops, Something Went Wrong',
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.error.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showMetricInfoDialog(
      BuildContext context, String metricName, String description) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          title: Text('About $metricName',
              style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
          content: Text(description,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                textStyle:
                    theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              child: const Text('GOT IT'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }
}
