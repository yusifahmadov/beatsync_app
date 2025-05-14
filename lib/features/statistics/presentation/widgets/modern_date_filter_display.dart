import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../cubit/statistics_cubit.dart'; 
import './date_range_modal.dart'; 

class ModernDateFilterDisplay extends StatelessWidget {
  final PresetRange selectedPresetRange;
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  final Function(PresetRange) onPresetSelected;
  final Function(DateTimeRange) onCustomDateRangeSelected;

  const ModernDateFilterDisplay({
    super.key,
    required this.selectedPresetRange,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.onPresetSelected,
    required this.onCustomDateRangeSelected,
  });

  String _getDisplayString() {
    switch (selectedPresetRange) {
      case PresetRange.Today:
        return 'Today';
      case PresetRange.SevenDays:
        return 'Last 7 Days';
      case PresetRange.ThirtyDays:
        return 'Last 30 Days';
      case PresetRange.Last90Days:
        return 'Last 90 Days';
      case PresetRange.Custom:
        return 'Custom Range';
    }
  }

  String _getCustomDateRangeString() {
    final DateFormat formatter = DateFormat('MMM d, yyyy');
    final start = formatter.format(selectedStartDate);
    final end = formatter.format(selectedEndDate);
    if (start == end) return start;
    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mainDisplayString = _getDisplayString();

    return InkWell(
      onTap: () {
        showDateRangeModal(
          context,
          currentPreset: selectedPresetRange,
          currentCustomDateRange: selectedPresetRange == PresetRange.Custom
              ? DateTimeRange(start: selectedStartDate, end: selectedEndDate)
              : null,
          onPresetSelected: onPresetSelected,
          onCustomDateRangeSelected: onCustomDateRangeSelected,
        );
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mainDisplayString,
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
                if (selectedPresetRange == PresetRange.Custom)
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Text(
                      _getCustomDateRangeString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 6.0),
            Icon(Icons.arrow_drop_down_rounded,
                size: 22, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }
}
