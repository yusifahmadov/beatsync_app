import 'package:beatsync_app/features/statistics/domain/entities/hrv_analysis_result.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class BpmOverTimeChart extends StatelessWidget {
  final List<HrvAnalysisResult> analysisResults;

  const BpmOverTimeChart({super.key, required this.analysisResults});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (analysisResults.isEmpty) {
      return Center(
        child: Text(
          "No BPM data available for this period.",
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    List<FlSpot> spots = analysisResults.map((result) {
      return FlSpot(
        result.analysisTime.millisecondsSinceEpoch.toDouble(),
        result.bpm.toDouble(),
      );
    }).toList();


    double minY = double.maxFinite;
    double maxY = double.minPositive;
    for (var result in analysisResults) {
      if (result.bpm < minY) minY = result.bpm.toDouble();
      if (result.bpm > maxY) maxY = result.bpm.toDouble();
    }

    minY = (minY - 10).clamp(0, double.maxFinite); 
    maxY += 10;


    if (minY >= maxY) {
      minY = (maxY - 20).clamp(0, double.maxFinite);
      if (minY >= maxY) {

        minY = (maxY / 2).clamp(0, double.maxFinite);
      }
    }
    if (minY == maxY) {

      maxY = minY + 10; 
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 16.0, bottom: 8.0),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: ((maxY - minY) / 4)
                .roundToDouble()
                .clamp(5, double.maxFinite), 
            verticalInterval: _calculateVerticalInterval(analysisResults),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.dividerColor.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: theme.dividerColor.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: ((maxY - minY) / 4)
                    .roundToDouble()
                    .clamp(5, double.maxFinite), 
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: theme.textTheme.labelSmall,
                    textAlign: TextAlign.left,
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: _calculateVerticalInterval(analysisResults),
                getTitlesWidget: (value, meta) {
                  DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());

                  final overallInterval =
                      meta.max - meta.min; 
                  if (overallInterval < Duration(days: 2).inMilliseconds &&
                      date.hour != 0 &&
                      date.minute != 0) {
                    if (analysisResults.length > 1 &&
                        (value == meta.min || value == meta.max)) {

                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8.0,
                    child: Text(
                        analysisResults.length > 1 &&
                                (DateTime.fromMillisecondsSinceEpoch(meta.max.toInt())
                                        .difference(DateTime.fromMillisecondsSinceEpoch(
                                            meta.min.toInt()))
                                        .inDays <
                                    2)
                            ? DateFormat.Hm()
                                .format(date) 
                            : DateFormat.Md().format(date), 
                        style: theme.textTheme.labelSmall),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor, width: 1),
              left: BorderSide(color: theme.dividerColor, width: 1),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.5),
                  theme.colorScheme.primary.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: spots.length < 20, 
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 3,
                  color: theme.colorScheme.primary,
                  strokeWidth: 1,
                  strokeColor: theme.colorScheme.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.3),
                    theme.colorScheme.primary.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: theme.colorScheme.surfaceContainerHighest,
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final DateTime date =
                      DateTime.fromMillisecondsSinceEpoch(barSpot.x.toInt());
                  return LineTooltipItem(
                    '${DateFormat.yMd().add_Hm().format(date)}\n',
                    TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '${barSpot.y.toStringAsFixed(0)} BPM',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                    textAlign: TextAlign.left,
                  );
                }).toList();
              },
            ),
            getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(
                      color: theme.colorScheme.primary.withOpacity(0.5), strokeWidth: 2),
                  FlDotData(
                    getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                      radius: 5,
                      color: theme.colorScheme.primary,
                      strokeWidth: 2,
                      strokeColor: theme.colorScheme.surface,
                    ),
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  double _calculateVerticalInterval(List<HrvAnalysisResult> results) {
    if (results.length < 2) return 1; 

    double minX = results.first.analysisTime.millisecondsSinceEpoch.toDouble();
    double maxX = results.last.analysisTime.millisecondsSinceEpoch.toDouble();


    for (var result in results) {
      final timeEpoch = result.analysisTime.millisecondsSinceEpoch.toDouble();
      if (timeEpoch < minX) minX = timeEpoch;
      if (timeEpoch > maxX) maxX = timeEpoch;
    }

    double range = maxX - minX;
    if (range == 0) return 1; 


    int numberOfIntervals = 4;
    double interval = range / numberOfIntervals;


    if (interval < Duration(hours: 1).inMilliseconds) {
      return Duration(minutes: 15).inMilliseconds.toDouble();
    } else if (interval < Duration(days: 1).inMilliseconds) {
      return Duration(
              hours: (interval / Duration(hours: 1).inMilliseconds).round().clamp(1, 24))
          .inMilliseconds
          .toDouble();
    }

    return (range / numberOfIntervals); 
  }
}
