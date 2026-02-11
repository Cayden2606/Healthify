import 'package:flutter/material.dart';
import 'package:healthify/models/appointment.dart';
import 'package:healthify/utilities/firebase_calls.dart';
import 'package:healthify/widgets/appointments/appointments_list.dart';
import 'package:healthify/widgets/appointments/book_appointment_button.dart';

import 'package:healthify/utilities/status_bar_utils.dart';

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
    // StatusBarUtils.setStatusBar(context);
    ThemeData theme = Theme.of(context);

    final size = MediaQuery.of(context).size;
    final barColor = theme.colorScheme.primaryFixed.withValues(alpha: 0.2);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointments',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: barColor,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        systemOverlayStyle:
            StatusBarUtils.styleFor(context, background: barColor),
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
                        return theme.colorScheme.onSurface
                            .withValues(alpha: 0.08);
                      }
                      if (states.contains(WidgetState.pressed)) {
                        return theme.colorScheme.onSurface
                            .withValues(alpha: 0.12);
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
                    AppointmentsList(
                      appointmentsFuture: _appointmentsFuture,
                      status: 'upcoming',
                    ),
                    // Passed Appointments Tab
                    AppointmentsList(
                      appointmentsFuture: _appointmentsFuture,
                      status: 'passed',
                    ),
                  ],
                ),
              ),
            ],
          ),
          BookAppointmentButton(theme: theme),
        ],
      ),
    );
  }
}
