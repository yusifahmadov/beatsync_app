import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../cubit/statistics_cubit.dart'; 


typedef OnPresetSelected = void Function(PresetRange preset);
typedef OnCustomDateRangeSelected = void Function(DateTimeRange range);

class DateRangeModal extends StatefulWidget {
  final PresetRange currentPreset;
  final DateTimeRange? currentCustomDateRange;
  final OnPresetSelected onPresetSelected;
  final OnCustomDateRangeSelected onCustomDateRangeSelected;

  const DateRangeModal({
    super.key,
    required this.currentPreset,
    this.currentCustomDateRange,
    required this.onPresetSelected,
    required this.onCustomDateRangeSelected,
  });

  @override
  State<DateRangeModal> createState() => _DateRangeModalState();
}

class _DateRangeModalState extends State<DateRangeModal> {
  bool _showCustomRangePicker = false;
  late DateTimeRange _selectedCustomDateRange;

  @override
  void initState() {
    super.initState();
    _showCustomRangePicker = widget.currentPreset == PresetRange.Custom;
    _selectedCustomDateRange = widget.currentCustomDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 6)),
          end: DateTime.now(),
        );
  }

  Widget _buildPresetTile(BuildContext context, PresetRange preset, String title) {
    final bool isSelected = widget.currentPreset == preset && !_showCustomRangePicker;
    final theme = Theme.of(context);
    return ListTile(
      title: Text(title,
          style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant)),
      onTap: () {
        widget.onPresetSelected(preset);
        Navigator.pop(context);
      },
      trailing: isSelected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat formatter = DateFormat('MMM d, yyyy');

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 8.0, right: 8.0),
            child: Text(
              'Select Date Range',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (!_showCustomRangePicker) ...[
            _buildPresetTile(context, PresetRange.Today, 'Today'),
            _buildPresetTile(context, PresetRange.SevenDays, 'Last 7 Days'),
            _buildPresetTile(context, PresetRange.ThirtyDays, 'Last 30 Days'),
            _buildPresetTile(context, PresetRange.Last90Days, 'Last 90 Days'),
            ListTile(
              title: Text('Custom Range',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
              trailing: Icon(Icons.calendar_today_outlined,
                  color: theme.colorScheme.onSurfaceVariant),
              onTap: () {
                setState(() {
                  _showCustomRangePicker = true;
                });
              },
            ),
          ],
          if (_showCustomRangePicker) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.arrow_back_ios_new, size: 16),
                    label: const Text('Presets'),
                    onPressed: () {
                      setState(() {
                        _showCustomRangePicker = false;
                      });
                    },
                    style:
                        TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
                  ),
                  Text(
                    'Custom Range',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 80), 
                ],
              ),
            ),
            CalendarDatePicker(
              initialDate: _selectedCustomDateRange.end,
              firstDate: DateTime(DateTime.now().year - 5),
              lastDate: DateTime.now(),
              currentDate: _selectedCustomDateRange.end, 
              onDateChanged: (newDate) {









              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                'Selected: ${formatter.format(_selectedCustomDateRange.start)} - ${formatter.format(_selectedCustomDateRange.end)}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  initialDateRange: _selectedCustomDateRange,
                  firstDate: DateTime(DateTime.now().year - 5),
                  lastDate: DateTime.now(),
                  builder: (pickerContext, child) {
                    return Theme(
                      data: Theme.of(pickerContext).copyWith(
                        colorScheme: theme.colorScheme.copyWith(
                          primary: theme.colorScheme.primary,
                          onPrimary: theme.colorScheme.onPrimary,
                          surface: theme.colorScheme.surfaceContainerHighest,
                          onSurface: theme.colorScheme.onSurface,
                        ),
                        dialogBackgroundColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _selectedCustomDateRange = picked;
                  });
                }
              },
              child: const Text('Select Custom Dates'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                      foregroundColor: theme.textTheme.bodyLarge?.color),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final endDateEndOfDay = DateTime(
                        _selectedCustomDateRange.end.year,
                        _selectedCustomDateRange.end.month,
                        _selectedCustomDateRange.end.day,
                        23,
                        59,
                        59,
                        999);
                    widget.onCustomDateRangeSelected(DateTimeRange(
                        start: _selectedCustomDateRange.start, end: endDateEndOfDay));
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Custom'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

void showDateRangeModal(
  BuildContext context, {
  required PresetRange currentPreset,
  DateTimeRange? currentCustomDateRange,
  required OnPresetSelected onPresetSelected,
  required OnCustomDateRangeSelected onCustomDateRangeSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, 
    backgroundColor: Colors.transparent, 
    builder: (BuildContext builderContext) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(builderContext).viewInsets.bottom),
        child: DateRangeModal(
          currentPreset: currentPreset,
          currentCustomDateRange: currentCustomDateRange,
          onPresetSelected: onPresetSelected,
          onCustomDateRangeSelected: onCustomDateRangeSelected,
        ),
      );
    },
  );
}
