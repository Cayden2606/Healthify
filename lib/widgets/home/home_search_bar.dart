import 'package:flutter/material.dart';
import '../../screens/clinics_screen.dart';

class HomeSearchBar extends StatefulWidget {
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
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? widget.colorScheme.surface.withAlpha(200)
            : widget.colorScheme.surface,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: widget.colorScheme.outline.withAlpha(80),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.colorScheme.shadow.withAlpha(30),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 60,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClinicsScreen(
                      // searchQuery: value.trim(), // pass the search text
                      ),
                ),
              );
            }
          },
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: Icon(
                Icons.search,
                color: widget.colorScheme.onSurface.withAlpha(150),
              ),
            ),
            hintText: "Search clinics, services...",
            hintStyle: widget.theme.textTheme.bodyMedium?.copyWith(
              color: widget.colorScheme.onSurface.withAlpha(150),
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          ),
          style: widget.theme.textTheme.bodyLarge?.copyWith(
            color: widget.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
