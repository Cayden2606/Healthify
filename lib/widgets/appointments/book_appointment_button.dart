import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:healthify/screens/clinics_screen.dart';

class BookAppointmentButton extends StatelessWidget {
  const BookAppointmentButton({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withAlpha(217),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withAlpha(25),
                  width: 0.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withAlpha(30),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: theme.colorScheme.primary.withAlpha(13),
                  blurRadius: 40,
                  offset: const Offset(0, -12),
                  spreadRadius: 4,
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ClinicsScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 4,
                  shadowColor: theme.colorScheme.primary.withAlpha(64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  'Book Appointment',
                  style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}