import 'package:flutter/material.dart';
import 'package:healthify/screens/appointments_screen.dart';

class UpcomingScheduleCard extends StatelessWidget {
  const UpcomingScheduleCard({
    super.key,
    required this.colorScheme,
    required this.theme,
  });

  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AppointmentsScreen(),
            ),
          );
        },
        child: Container(
          height: 130,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.secondaryContainer,
                colorScheme.secondaryContainer.withAlpha(180),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outline.withAlpha(50),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withAlpha(80),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 32,
                color: colorScheme.onSecondaryContainer,
              ),
              const SizedBox(height: 8),
              Text(
                "No appointments today",
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Tap to schedule",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondaryContainer.withAlpha(200),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}