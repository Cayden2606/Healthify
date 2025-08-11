import 'package:flutter/material.dart';

class ClinicSearchBar extends StatefulWidget {
  const ClinicSearchBar({
    super.key,
    required this.isDarkMode,
    required this.colorScheme,
    required this.theme,
    this.existingSearch,
    required this.onChanged, // Add this
  });

  final bool isDarkMode;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final String? existingSearch;
  final ValueChanged<String> onChanged; // Add this

  @override
  State<ClinicSearchBar> createState() => _ClinicSearchBarState();
}

class _ClinicSearchBarState extends State<ClinicSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existingSearch);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? widget.colorScheme.surface.withValues(alpha: 0.9)
            : widget.colorScheme.surface,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: widget.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 50,
        child: TextField(
          controller: _controller,
          onChanged: widget.onChanged, // Call the callback
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Icon(
                Icons.search,
                color: widget.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            hintText: "Search for clinics",
            hintStyle: widget.theme.textTheme.bodyMedium?.copyWith(
              color: widget.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          ),
          style: widget.theme.textTheme.bodyMedium?.copyWith(
            color: widget.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
