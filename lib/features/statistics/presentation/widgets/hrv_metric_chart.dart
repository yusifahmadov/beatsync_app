import 'dart:math'; 

import 'package:beatsync_app/features/statistics/domain/entities/hrv_analysis_result.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class HrvMetricChart extends StatelessWidget {
  final List<HrvAnalysisResult> analysisResults;
  final double Function(HrvAnalysisResult) metricExtractor;
  final String metricName;
  final Color? lineColor; 
  final List<Color>? belowBarGradientColors; 

  const HrvMetricChart({
    super.key,
    required this.analysisResults,
    required this.metricExtractor,
    required this.metricName,
    this.lineColor, 
    this.belowBarGradientColors, 
  });

  @override
  Widget build(BuildContext context) {
    final sortedResults = List<HrvAnalysisResult>.from(analysisResults)
      ..sort((a, b) => a.analysisTime.compareTo(b.analysisTime));


    if (sortedResults.isEmpty) {
      return _buildNoDataState(context);
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < sortedResults.length; i++) {
      final result = sortedResults[i];

      final value = metricExtractor(result);
      if (value.isFinite) {
        spots.add(FlSpot(result.analysisTime.millisecondsSinceEpoch.toDouble(), value));
      }
    }


    if (spots.isEmpty) {
      return _buildNoDataState(context);
    }


    final yValues = spots.map((s) => s.y).toList();
    double minY = yValues.reduce(min);
    double maxY = yValues.reduce(max);
    double range = maxY - minY;
    if (range < 1e-6) {
      maxY += 1; 
      minY -= 1;
      range = 2;
    }
    double padding = range * 0.15;
    minY -= padding;
    maxY += padding;

    double minX = spots.first.x;
    double maxX = spots.last.x;


    final currentLineColor = lineColor ?? Theme.of(context).colorScheme.primary;
    final currentBelowBarGradientColors = belowBarGradientColors ??
        [
          currentLineColor.withOpacity(0.4),
          currentLineColor.withOpacity(0.05),
        ];

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        minX: minX,
        maxX: maxX,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                if (value == meta.min || value == meta.max) return Container();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Text(value.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.7))),
                );
              },
              interval: (maxY - minY) / 4, 
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _calculateAdequateInterval(spots),
              getTitlesWidget: (value, meta) {
                if (value < meta.min || value > meta.max) return Container();
                DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 6,
                  child: Text(
                    DateFormat('MMM d').format(date),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.7)),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.4, 
            gradient: LinearGradient(
              colors: [
                currentLineColor,
                currentLineColor.withOpacity(0.7)
              ], 
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            barWidth: 3, 
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false), 
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: currentBelowBarGradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true, 
          getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                FlLine(
                    color:
                        currentLineColor.withOpacity(0.5), 
                    strokeWidth: 1.5, 
                    dashArray: [4, 4]), 
                FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 6, 
                      color: currentLineColor, 
                      strokeWidth: 2,
                      strokeColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest), 
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 12.0, 
            tooltipBgColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.95), 
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final DateTime date =
                    DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt());
                final String dateString = DateFormat('MMM d, HH:mm').format(date);
                return LineTooltipItem(
                    '${touchedSpot.y.toStringAsFixed(1)} ', 
                    TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold, 
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: dateString, 
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.9),
                          fontSize: 11, 
                        ),
                      ),
                    ]);
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
      ),
      duration: const Duration(milliseconds: 300), 
    );
  }


  Widget _buildNoDataState(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.show_chart_outlined,
            size: 40, color: Theme.of(context).hintColor.withOpacity(0.5)),
        const SizedBox(height: 8),
        Text(
          "No data for $metricName",
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: Theme.of(context).hintColor),
          textAlign: TextAlign.center,
        ),
      ],
    ));
  }

  double _calculateAdequateInterval(List<FlSpot> spots) {
    if (spots.length < 2) return const Duration(days: 1).inMilliseconds.toDouble();
    double totalDurationMs = spots.last.x - spots.first.x;
    if (totalDurationMs <= 0) return const Duration(days: 1).inMilliseconds.toDouble();

    int numberOfDays = (totalDurationMs / const Duration(days: 1).inMilliseconds).ceil();


    if (numberOfDays <= 1) {
      return totalDurationMs / 4; 
    } else if (numberOfDays <= 3) {
      return const Duration(days: 1).inMilliseconds.toDouble(); 
    } else if (numberOfDays <= 7) {
      return const Duration(days: 2).inMilliseconds.toDouble(); 
    } else if (numberOfDays <= 30) {
      return const Duration(days: 7).inMilliseconds.toDouble(); 
    } else if (numberOfDays <= 90) {
      return const Duration(days: 15).inMilliseconds.toDouble(); 
    } else if (numberOfDays <= 180) {
      return const Duration(days: 30).inMilliseconds.toDouble(); 
    } else {

      return const Duration(days: 60).inMilliseconds.toDouble(); 
    }
  }
}
