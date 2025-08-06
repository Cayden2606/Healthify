import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthify/models/appointment.dart';
import 'package:healthify/utilities/firebase_calls.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

import '../utilities/status_bar_utils.dart';
import 'clinics_screen.dart';
import 'make_appointments_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseCalls _firebaseCalls = FirebaseCalls();
  late Future<List<Appointment>> _appointmentsFuture;

  final initials =
      '${appUser.name.isNotEmpty ? appUser.name[0] : ''}${appUser.nameLast.isNotEmpty ? appUser.nameLast[0] : ''}';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  void _loadAppointments() {
    setState(() {
      _appointmentsFuture = _firebaseCalls.getAppointments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Change status bar color
    StatusBarUtils.setStatusBar(context);

    ThemeData theme = Theme.of(context);

    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointments',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: theme.colorScheme.primaryFixed.withValues(alpha: 0.2),
      ),
      body: Stack(
        children: [
          Container(
            height: size.height,
            width: size.width,
            color: theme.colorScheme.primaryFixed.withValues(alpha: 0.2),
          ),
          Column(
            children: [
              SizedBox(height: 10),

              // TabBar Section
              Container(
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  splashBorderRadius: BorderRadius.circular(20),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  dividerColor: Colors.transparent,
                  labelColor: theme.colorScheme.onSecondaryContainer,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  labelStyle: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                  unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overlayColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.hovered)) {
                        return theme.colorScheme.onSurface.withValues(alpha: 0.08);
                      }
                      if (states.contains(WidgetState.pressed)) {
                        return theme.colorScheme.onSurface.withValues(alpha: 0.12);
                      }
                      return null;
                    },
                  ),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upcoming_outlined, size: 20),
                          SizedBox(width: 8),
                          Text("Upcoming"),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_outlined, size: 20),
                          SizedBox(width: 8),
                          Text("Passed"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // TabBarView Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Upcoming Appointments Tab
                    _buildAppointmentsList(theme, 'upcoming'),
                    // Missed Appointments Tab
                    _buildAppointmentsList(theme, 'passed'),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer
                        .withValues(alpha: 0.85),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        width: 0.5,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: Offset(0, -8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.05),
                        blurRadius: 40,
                        offset: Offset(0, -12),
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: SafeArea(
                    child: ElevatedButton(
                      onPressed: () {
                        // Make appointment functionality
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ClinicsScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 18),
                        elevation: 4,
                        shadowColor:
                            theme.colorScheme.primary.withValues(alpha: 0.25),
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
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(ThemeData theme, String status) {
    return FutureBuilder<List<Appointment>>(
      future: _appointmentsFuture,
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
              'No ${status} appointments.',
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
              child: _buildAppointmentCard(
                theme: theme,
                appointment: appointment,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppointmentCard({
    required ThemeData theme,
    required Appointment appointment,
  }) {
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
              Container(
                width: 48,
                height: 38,
                child: isUpcoming
                    ? ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          elevation: 1.0,
                          shadowColor: Colors.black.withValues(alpha: 0.4),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Icon(Icons.edit, size: 16),
                      )
                    : ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          elevation: 1.0,
                          shadowColor: Colors.black.withValues(alpha: 0.4),
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
              Container(
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
                        child: Icon(Icons.map, size: 16),
                      )
                    : ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          elevation: 1.0,
                          shadowColor: Colors.black.withValues(alpha: 0.4),
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
