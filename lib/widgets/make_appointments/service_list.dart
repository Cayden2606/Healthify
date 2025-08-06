import 'package:flutter/material.dart';
import 'package:healthify/models/appointment_data.dart';

class ServiceList extends StatelessWidget {
  final String? selectedServiceCategory;
  final String? selectedService;
  final ValueChanged<String> onServiceSelected;

  const ServiceList({
    super.key,
    required this.selectedServiceCategory,
    required this.selectedService,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryServices =
        appointmentServices[selectedServiceCategory] ?? [];

    return Column(
      children: categoryServices.map((service) {
        final isSelected = selectedService == service;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => onServiceSelected(service),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primaryContainer.withOpacity(0.4)
                    : theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      service,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 18,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}