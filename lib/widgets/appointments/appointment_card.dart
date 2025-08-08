import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthify/models/appointment.dart';
import 'package:healthify/models/appointment_data.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../screens/clinics_screen.dart';

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
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Container(
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        theme.colorScheme.shadow.withAlpha(20),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Handle bar
                                  Container(
                                    margin: const EdgeInsets.only(top: 16),
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withAlpha(60),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),

                                  // Header with clinic info
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        24, 20, 24, 8),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                theme.colorScheme
                                                    .primaryContainer,
                                                theme.colorScheme
                                                    .secondaryContainer,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            FontAwesomeIcons.locationDot,
                                            color: theme
                                                .colorScheme.onPrimaryContainer,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          appointment.clinic.name,
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Choose how to view location',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Action buttons
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        24, 16, 24, 32),
                                    child: Column(
                                      children: [
                                        // Healthify Map Option
                                        Container(
                                          width: double.infinity,
                                          margin:
                                              const EdgeInsets.only(bottom: 12),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ClinicsScreen(
                                                              passedClinic:
                                                                  appointment
                                                                      .clinic)));
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: theme
                                                  .colorScheme.primaryContainer,
                                              foregroundColor: theme.colorScheme
                                                  .onPrimaryContainer,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(width: 16),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: theme
                                                        .colorScheme.primary
                                                        .withAlpha(20),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Icon(
                                                    Icons.map_rounded,
                                                    size: 20,
                                                    color: theme.colorScheme
                                                        .onPrimaryContainer,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'View in Healthify',
                                                        style: theme.textTheme
                                                            .titleMedium
                                                            ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: theme
                                                              .colorScheme
                                                              .onPrimaryContainer,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Quick location preview',
                                                        style: theme
                                                            .textTheme.bodySmall
                                                            ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .onPrimaryContainer
                                                              .withAlpha(180),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: 16,
                                                  color: theme.colorScheme
                                                      .onPrimaryContainer
                                                      .withAlpha(120),
                                                ),
                                                const SizedBox(width: 16),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Google Maps Option
                                        Container(
                                          width: double.infinity,
                                          child: OutlinedButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              final String clinicName =
                                                  appointment.clinic.name;
                                              final String address =
                                                  appointment.clinic.address;
                                              final String searchQuery =
                                                  '$clinicName, $address';
                                              final String encodedQuery =
                                                  Uri.encodeComponent(
                                                      searchQuery);
                                              final Uri mapsUri = Uri.parse(
                                                  'https://www.google.com/maps/search/?api=1&query=$encodedQuery');

                                              if (await canLaunchUrl(mapsUri)) {
                                                await launchUrl(mapsUri);
                                              }
                                            },
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                color: theme.colorScheme.outline
                                                    .withAlpha(60),
                                                width: 1.5,
                                              ),
                                              backgroundColor:
                                                  theme.colorScheme.surface,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(width: 16),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme
                                                        .secondaryContainer,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Icon(
                                                    Icons.directions_rounded,
                                                    size: 20,
                                                    color: theme.colorScheme
                                                        .onSecondaryContainer,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Get Directions',
                                                        style: theme.textTheme
                                                            .titleMedium
                                                            ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: theme
                                                              .colorScheme
                                                              .onSurface,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Open in Google Maps',
                                                        style: theme
                                                            .textTheme.bodySmall
                                                            ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.open_in_new_rounded,
                                                  size: 16,
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                                const SizedBox(width: 16),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
                        child:
                            const Icon(FontAwesomeIcons.locationDot, size: 16),
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
