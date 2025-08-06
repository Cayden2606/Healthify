import 'package:flutter/material.dart';

class AdditionalInfoCard extends StatelessWidget {
  final TextEditingController controller;

  const AdditionalInfoCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Additional Notes (Optional)',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintStyle: const TextStyle(fontSize: 16),
                  hintText:
                      'Any specific concerns or symptoms you\'d like to mention...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.onSecondaryContainer,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please arrive 15 minutes before your appointment time. Bring your NRIC and any relevant medical documents.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}