import 'package:beatsync_app/di/main_injection.dart';
import 'package:beatsync_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:beatsync_app/features/home/presentation/cubit/home_state.dart';
import 'package:beatsync_app/features/home/presentation/widgets/home_app_bar.dart';
import 'package:beatsync_app/features/home/presentation/widgets/info_metric_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  static const Color _heartRateCardColor = Color(0xFFE0F7FA); 
  static const Color _rmssdCardColor = Color(0xFFE8F5E9); 
  static const Color _sdnnCardColor = Color(0xFFFFF3E0); 
  static const Color _lfhfCardColor = Color(0xFFEDE7F6); 




  static const Color _cardTitleIconColor = Color(0xFF566573); 
  static const Color _cardValueColor =
      Color(0xFF263238); 

  @override
  void initState() {
    super.initState();






  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocProvider(
        create: (context) => sl<HomeCubit>()..loadHomeScreenData(),
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<HomeCubit>().loadHomeScreenData();
          },
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading || state is HomeInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is HomeError) {
                return Center(
                    child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: ${state.errorMessage}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error, fontSize: 16)),
                ));
              }
              if (state is HomeLoaded) {
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CustomScrollView(
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: HomeAppBar(
                            userName: state.userName,
                            currentDate: state.currentDate,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),
                        SliverGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.95,
                          children: <Widget>[
                            InfoMetricCard(
                              title: 'Heart Rate',
                              value: state.heartRateData?['value'],
                              unit: state.heartRateData?['unit'] ?? 'bpm',
                              timestamp: state.heartRateData?['timestamp'],
                              lottieAssetPath: 'assets/lottie/heart-ratio.json',
                              iconData: Icons.favorite_outline,
                              backgroundColor: _heartRateCardColor,
                              contentColor: _cardValueColor,
                              noDataMessage: 'No measurement',
                            ),
                            InfoMetricCard(
                              title: 'RMSSD',
                              value: state.rmssdData?['value'],
                              unit: state.rmssdData?['unit'] ?? 'ms',
                              lottieAssetPath: 'assets/lottie/rmsdd.json',
                              iconData: Icons.healing_outlined,
                              backgroundColor: _rmssdCardColor,
                              contentColor: _cardValueColor,
                            ),
                            InfoMetricCard(
                              title: 'SDNN',
                              value: state.sdnnData?['value'],
                              unit: state.sdnnData?['unit'] ?? 'ms',
                              lottieAssetPath: 'assets/lottie/sdnn.json',
                              iconData: Icons.show_chart_outlined,
                              backgroundColor: _sdnnCardColor,
                              contentColor: _cardValueColor,
                            ),
                            InfoMetricCard(
                              title: 'LF/HF Ratio',
                              value: state.lfhfData?['value'],
                              unit: '',
                              lottieAssetPath: 'assets/lottie/lf-hf.json',
                              iconData: Icons.trending_up,
                              backgroundColor: _lfhfCardColor,
                              contentColor: _cardValueColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const Center(child: Text('Something went wrong. Please try again.'));
            },
          ),
        ),
      ),
    );
  }
}
