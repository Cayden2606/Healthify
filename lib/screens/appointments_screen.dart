import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthify/utilities/firebase_calls.dart';
import 'dart:ui';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showCalendar = false;

  final initials =
      '${appUser.name.isNotEmpty ? appUser.name[0] : ''}${appUser.nameLast.isNotEmpty ? appUser.nameLast[0] : ''}';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    color: theme.colorScheme.outline.withOpacity(0.12),
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
                        color: theme.colorScheme.shadow.withOpacity(0.08),
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
                        return theme.colorScheme.onSurface.withOpacity(0.08);
                      }
                      if (states.contains(WidgetState.pressed)) {
                        return theme.colorScheme.onSurface.withOpacity(0.12);
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
                          Text("Missed"),
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
                    _buildUpcomingAppointments(theme),
                    // Missed Appointments Tab
                    _buildMissedAppointments(theme),
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
                        color: theme.colorScheme.shadow.withOpacity(0.12),
                        blurRadius: 24,
                        offset: Offset(0, -8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.05),
                        blurRadius: 40,
                        offset: Offset(0, -12),
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: SafeArea(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 18),
                        elevation: 4,
                        shadowColor:
                            theme.colorScheme.primary.withOpacity(0.25),
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

  Widget _buildUpcomingAppointments(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAppointmentCard(
              theme: theme,
              serviceType: "Doctor Consult",
              date: "Tomorrow",
              time: "10:30 AM",
              clinic: "Heart Care Center",
              isUpcoming: true,
            ),
            const SizedBox(height: 16),
            _buildAppointmentCard(
              theme: theme,
              serviceType: "Doctor Consult",
              date: "Dec 15, 2024",
              time: "2:00 PM",
              clinic: "Skin Health Clinic",
              isUpcoming: true,
            ),
            const SizedBox(height: 16),
            _buildAppointmentCard(
              theme: theme,
              serviceType: "Doctor Consult",
              date: "Dec 15, 2024",
              time: "2:00 PM",
              clinic: "Skin Health Clinic",
              isUpcoming: true,
            ),
            const SizedBox(height: 16),
            _buildAppointmentCard(
              theme: theme,
              serviceType: "Doctor Consult",
              date: "Dec 15, 2024",
              time: "2:00 PM",
              clinic: "Skin Health Clinic",
              isUpcoming: true,
            ),
            const SizedBox(height: 16),
            _buildAppointmentCard(
              theme: theme,
              serviceType: "Doctor Consult",
              date: "Dec 15, 2024",
              time: "2:00 PM",
              clinic: "Skin Health Clinic",
              isUpcoming: true,
            ),
            SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildMissedAppointments(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        children: [
          _buildAppointmentCard(
            theme: theme,
            serviceType: "Doctor Consult",
            date: "Dec 1, 2024",
            time: "9:00 AM",
            clinic: "Family Health Center",
            isUpcoming: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard({
    required ThemeData theme,
    required String serviceType,
    required String date,
    required String time,
    required String clinic,
    required bool isUpcoming,
  }) {
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
                  "20",
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                Text(
                  "Jul",
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "2025",
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
                  clinic,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$time",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  serviceType,
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
