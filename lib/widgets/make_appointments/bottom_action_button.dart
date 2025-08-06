import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:healthify/models/clinic.dart';
import 'package:healthify/screens/home.dart' as home_screen;
import 'package:healthify/utilities/firebase_calls.dart';

class BottomActionButton extends StatelessWidget {
  final Clinic clinic;
  final String? selectedService;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final TextEditingController additionalInfoController;

  const BottomActionButton({
    super.key,
    required this.clinic,
    required this.selectedService,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.additionalInfoController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer.withOpacity(0.85),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appointment Summary',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$selectedService\n${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} at $selectedTimeSlot',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _bookAppointment(context, theme);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 4,
                      shadowColor: theme.colorScheme.primary.withOpacity(0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: Text(
                      'Book Appointment',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _bookAppointment(BuildContext context, ThemeData theme) {
    FirebaseCalls().addAppointment(
      placeId: clinic.placeId,
      appointmentDateTime: DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        int.parse(selectedTimeSlot!.split(':')[0]),
        int.parse(selectedTimeSlot!.split(':')[1].split(' ')[0]),
      ),
      serviceType: selectedService!,
      additionalInfo: additionalInfoController.text,
    );
    _showBookingConfirmation(context, theme);
  }

  void _showBookingConfirmation(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Booking Confirmed'),
          ],
        ),
        content: Text(
          'Your appointment has been successfully booked. \nYou will receive a confirmation Email shortly.',
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const home_screen.HomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}