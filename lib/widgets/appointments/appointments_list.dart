import 'package:flutter/material.dart';
import 'package:healthify/models/appointment.dart';
import 'package:healthify/widgets/appointments/appointment_card.dart';

class AppointmentsList extends StatelessWidget {
  const AppointmentsList({
    super.key,
    required this.appointmentsFuture,
    required this.status,
  });

  final Future<List<Appointment>> appointmentsFuture;
  final String status;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return FutureBuilder<List<Appointment>>(
      future: appointmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No appointments found.',
              style: theme.textTheme.bodyLarge,
            ),
          );
        }

        final appointments = snapshot.data!
            .where((appt) => appt.status == status)
            .toList();

        if (appointments.isEmpty) {
          return Center(
            child: Text(
              'No $status appointments.',
              style: theme.textTheme.bodyLarge,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AppointmentCard(
                theme: theme,
                appointment: appointment,
              ),
            );
          },
        );
      },
    );
  }
}