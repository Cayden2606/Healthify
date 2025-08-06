import 'package:flutter/material.dart';

class ClinicSearchBar extends StatelessWidget {
  const ClinicSearchBar({
    super.key,
    required this.isDarkMode,
    required this.colorScheme,
    required this.theme,
  });

  final bool isDarkMode;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? colorScheme.surface.withOpacity(0.9)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 50,
        child: TextField(
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Icon(
                Icons.search,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            hintText: "Search clinics, services...",
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
