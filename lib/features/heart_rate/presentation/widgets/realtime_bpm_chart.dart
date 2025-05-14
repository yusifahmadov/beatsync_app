import 'package:beatsync_app/core/services/ppg_processor_service.dart'; 
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RealtimeBpmChart extends StatelessWidget {
  final List<EmaSensorValue> dataPoints;

  const RealtimeBpmChart({super.key, required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty || dataPoints.length < 2) {
      return Center(
        child: Text(
          '',
          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
        ),
      );
    }

    List<FlSpot> spots = [];
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;

    DateTime firstTimestamp = dataPoints[0].time;

    for (int i = 0; i < dataPoints.length; i++) {
      final dataPoint = dataPoints[i];

      final double xValue =
          dataPoint.time.difference(firstTimestamp).inMilliseconds / 1000.0;
      final double yValue = dataPoint.value;

      spots.add(FlSpot(xValue, yValue));

      if (xValue < minX) minX = xValue;
      if (xValue > maxX) maxX = xValue;
      if (yValue < minY) minY = yValue;
      if (yValue > maxY) maxY = yValue;
    }


    double yPadding = (maxY - minY) * 0.1; 
    minY -= yPadding;
    maxY += yPadding;
    if (minY == maxY) {

      minY -= 1;
      maxY += 1;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 8.0), 
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: (maxX - minX) / 5 > 0 ? (maxX - minX) / 5 : 1, 
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4,
                    child: Text('${value.toStringAsFixed(1)}s',
                        style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).textTheme.bodySmall?.color)),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  return LineTooltipItem(
                      '${flSpot.y.toStringAsFixed(2)}\n',
                      TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: '${flSpot.x.toStringAsFixed(1)}s',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.8),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                      textAlign: TextAlign.center);
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }
}
