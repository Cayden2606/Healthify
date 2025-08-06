import 'package:flutter/material.dart';
import 'package:healthify/models/appointment.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.theme,
    required this.appointment,
  });

  final ThemeData theme;
  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = appointment.status == 'upcoming';
    final date = appointment.appointmentDateTime;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isUpcoming
              ? theme.colorScheme.primary.withAlpha(20)
              : theme.colorScheme.error.withAlpha(20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withAlpha(20),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  DateFormat('d').format(date),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat('y').format(date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.clinic.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat.jm().format(date), // Format time e.g. 5:08 PM
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  appointment.serviceType,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                width: 48,
                height: 38,
                child: isUpcoming
                    ? ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          elevation: 1.0,
                          shadowColor: Colors.black.withAlpha(40),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Icon(Icons.edit, size: 16),
                      )
                    : ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          elevation: 1.0,
                          shadowColor: Colors.black.withAlpha(40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Icon(
                          Icons.refresh,
                          size: 16,
                          color: theme.colorScheme.error,
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 48,
                height: 38,
                child: isUpcoming
                    ? OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: theme.colorScheme.surfaceContainerHighest,
                              width: 0),
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Icon(Icons.map, size: 16),
                      )
                    : ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          elevation: 1.0,
                          shadowColor: Colors.black.withAlpha(40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Icon(
                          Icons.delete,
                          size: 16,
                          color: theme.colorScheme.error,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}