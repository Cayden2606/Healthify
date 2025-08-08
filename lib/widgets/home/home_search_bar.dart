import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
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
            ? colorScheme.surface.withAlpha(200)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: colorScheme.outline.withAlpha(80),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(30),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 60,
        child: TextField(
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: Icon(
                Icons.search,
                color: colorScheme.onSurface.withAlpha(150),
              ),
            ),
            hintText: "Search clinics, services...",
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withAlpha(150),
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
