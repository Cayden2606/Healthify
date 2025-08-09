import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:healthify/models/appointment.dart';
import 'package:healthify/utilities/firebase_calls.dart';
import 'package:healthify/screens/appointments_screen.dart';

class UpcomingScheduleCard extends StatefulWidget {
  const UpcomingScheduleCard({
    super.key,
    required this.colorScheme,
    required this.theme,
  });

  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  State<UpcomingScheduleCard> createState() => _UpcomingScheduleCardState();
}

class _UpcomingScheduleCardState extends State<UpcomingScheduleCard> {
  late Future<Appointment?> nextAppointment;

  // for live countdown
  Timer? _countdownTimer;
  Timer? _alignTimer;
  String _nowTick = '';

  @override
  void initState() {
    super.initState();
    nextAppointment = loadNextUpcoming();
    _startCountdownTicker();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _alignTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTicker() {
    final now = DateTime.now();
    final secondsToNextMinute = 60 - now.second;
    _alignTimer = Timer(Duration(seconds: secondsToNextMinute), () {
      if (!mounted) return;
      setState(() => _nowTick = DateTime.now().toIso8601String());
      _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (mounted) {
          setState(() => _nowTick = DateTime.now().toIso8601String());
        }
      });
    });
  }

  Future<Appointment?> loadNextUpcoming() async {
    final appointments = await FirebaseCalls().getAppointments();
    final now = DateTime.now();

    final upcomingAppointments = appointments
        .where((appointment) =>
            appointment.status == 'upcoming' &&
            appointment.appointmentDateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.appointmentDateTime.compareTo(b.appointmentDateTime));

    return upcomingAppointments.isEmpty ? null : upcomingAppointments.first;
  }

  String getRelativeTime(DateTime dateTime) {
    final difference = dateTime.difference(DateTime.now());
    if (difference.inMinutes <= 0) return 'Now';
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    if (hours == 0) return '$minutes min';
    return minutes == 0 ? '$hours hrs' : '$hours hrs, $minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colorScheme = widget.colorScheme;

    return FutureBuilder<Appointment?>(
      future: nextAppointment,
      builder: (context, snapshot) {
        onTap() => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
            );

        Widget buildShell(Widget child,
            {Color? borderColor, VoidCallback? onTap}) {
          final isEmpty = snapshot.connectionState != ConnectionState.done ||
              snapshot.data == null;
          final border = borderColor ??
              (isEmpty
                  ? colorScheme.outline.withAlpha(30)
                  : colorScheme.primary.withAlpha(20));

          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Container(
                constraints: const BoxConstraints(minHeight: 130),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withAlpha(20),
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildShell(Row(
            children: [
              buildDateTile(theme, colorScheme,
                  day: '–', month: '–––', year: '—'),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildBar(
                        colorScheme.onSurfaceVariant.withOpacity(.15), 140),
                    const SizedBox(height: 8),
                    buildBar(
                        colorScheme.onSurfaceVariant.withOpacity(.12), 100),
                    const SizedBox(height: 8),
                    buildBar(
                        colorScheme.onSurfaceVariant.withOpacity(.10), 180),
                  ],
                ),
              ),
            ],
          ));
        }

        final appointment = snapshot.data;
        if (appointment == null) {
          return buildShell(
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 28, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text(
                    'No upcoming appointments',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    'Tap to schedule',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            onTap: onTap,
          );
        }

        final appointmentDateTime = appointment.appointmentDateTime.toLocal();
        final day = DateFormat('d').format(appointmentDateTime);
        final month = DateFormat('MMM').format(appointmentDateTime);
        final year = DateFormat('y').format(appointmentDateTime);
        final timeString = DateFormat('h:mm a').format(appointmentDateTime);

        final countdownText = getRelativeTime(appointmentDateTime) + _nowTick;

        return buildShell(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDateTile(theme, colorScheme,
                    day: day, month: month, year: year),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        appointment.clinic.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            timeString,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer
                                  .withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: colorScheme.secondary.withAlpha(10),
                                  width: 1),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.15),
                                    end: Offset.zero,
                                  ).animate(anim),
                                  child: child,
                                ),
                              ),
                              child: Text(
                                getRelativeTime(appointmentDateTime),
                                key: ValueKey<String>(countdownText),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        appointment.serviceType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          onTap: onTap,
        );
      },
    );
  }

  Widget buildDateTile(ThemeData theme, ColorScheme colorScheme,
      {required String day, required String month, required String year}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.0,
              )),
          Text(month,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              )),
          Text(year,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              )),
        ],
      ),
    );
  }

  Widget buildBar(Color color, double width) => Container(
        width: width,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      );
}
