import 'package:flutter/material.dart';
import 'package:healthify/models/appointment_data.dart';

class TimeSlotGrid extends StatelessWidget {
  final String? selectedTimeSlot;
  final ValueChanged<String> onTimeSlotSelected;

  const TimeSlotGrid({
    super.key,
    required this.selectedTimeSlot,
    required this.onTimeSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.5,
      ),
      itemCount: appointmentTimeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = appointmentTimeSlots[index];
        final isSelected = selectedTimeSlot == timeSlot;
        final isAvailable = true; // Mock availability

        return GestureDetector(
          onTap: isAvailable ? () => onTimeSlotSelected(timeSlot) : null,
          child: Container(
            decoration: BoxDecoration(
              color: !isAvailable
                  ? theme.colorScheme.surfaceVariant.withValues(alpha: 0.3)
                  : isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                timeSlot,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: !isAvailable
                      ? theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5)
                      : isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
