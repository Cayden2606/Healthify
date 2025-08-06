import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            selectedDate != null
                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                : 'Tap to select date',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: selectedDate != null
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );

              if (date != null) {
                onDateSelected(date);
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }
}