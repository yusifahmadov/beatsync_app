import 'package:beatsync_app/features/statistics/domain/entities/hrv_analysis_result.dart';
import 'package:beatsync_app/features/statistics/presentation/widgets/hrv_metric_chart.dart';
import 'package:flutter/material.dart';


typedef ShowMetricInfoDialogCallback = void Function(
    BuildContext context, String metricName);

class MetricCard extends StatelessWidget {
  final String metricName;
  final String metricDescription; 
  final List<HrvAnalysisResult> analysisResults;
  final double Function(HrvAnalysisResult) metricExtractor;
  final ShowMetricInfoDialogCallback onShowInfoDialog;
  final Color? chartLineColor; 
  final List<Color>? chartGradientColors; 
  final Color? accentBackgroundColor; 

  const MetricCard({
    super.key,
    required this.metricName,
    required this.metricDescription,
    required this.analysisResults,
    required this.metricExtractor,
    required this.onShowInfoDialog,
    this.chartLineColor, 
    this.chartGradientColors, 
    this.accentBackgroundColor, 
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), 
        side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.2),
            width: 1), 
      ),
      color: accentBackgroundColor ??
          colorScheme.surfaceContainer, 
      margin: const EdgeInsets.symmetric(vertical: 8.0), 
      child: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metricName,
                        style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme
                                .onSurface 
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        metricDescription,
                        style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant
                                .withOpacity(0.8) 
                            ),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'About $metricName',
                  child: InkWell(
                    onTap: () => onShowInfoDialog(context, metricName),
                    borderRadius: BorderRadius.circular(24),
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 22,
                        color: colorScheme.onSurfaceVariant
                            .withOpacity(0.7), 
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180, 
              child: HrvMetricChart(
                analysisResults: analysisResults,
                metricExtractor: metricExtractor,
                metricName: metricName,
                lineColor: chartLineColor, 
                belowBarGradientColors: chartGradientColors, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
