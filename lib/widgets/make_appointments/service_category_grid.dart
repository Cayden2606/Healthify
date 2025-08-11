import 'package:flutter/material.dart';
import 'package:healthify/models/appointment_data.dart';

class ServiceCategoryGrid extends StatelessWidget {
  final String? selectedServiceCategory;
  final ValueChanged<String> onCategorySelected;

  const ServiceCategoryGrid({
    super.key,
    required this.selectedServiceCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemCount: appointmentServices.keys.length,
      itemBuilder: (context, index) {
        final category = appointmentServices.keys.elementAt(index);
        final isSelected = selectedServiceCategory == category;

        return GestureDetector(
          onTap: () => onCategorySelected(category),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.8)
                  : theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.secondary.withValues(alpha: 0.3)
                    : theme.colorScheme.outline.withValues(alpha: 0.12),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color:
                            theme.colorScheme.secondary.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  getCategoryIcon(category),
                  color: isSelected
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  category,
                  textAlign: TextAlign.left,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 18,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
