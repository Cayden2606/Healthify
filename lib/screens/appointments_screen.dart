import 'package:flutter/material.dart';
import 'package:healthify/utilities/firebase_calls.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointments',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          // User Profile Section
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.onPrimaryFixedVariant,
                  backgroundImage: appUser.profilePic.isNotEmpty
                      ? NetworkImage(appUser.profilePic)
                      : null,
                  child: appUser.profilePic.isEmpty
                      ? Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${appUser.name} ${appUser.nameLast}',
                        style: theme.textTheme.headlineMedium!
                            .copyWith(fontSize: 16),
                      ),
                      Text(
                        appUser.contact,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Make New Appointment Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // Handle new appointment creation
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withAlpha(180),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outline.withAlpha(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(80),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline_outlined,
                        size: 16,
                        color: theme.colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Make new appointment",
                        style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // TabBar Section
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(30),
              ),
              splashBorderRadius: BorderRadius.circular(30),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: theme.colorScheme.onPrimaryContainer,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              labelStyle: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
              unselectedLabelStyle: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 14,
              ),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule_outlined, size: 18),
                      SizedBox(width: 8),
                      Text("Upcoming"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_outlined, size: 18),
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
    );
  }

  Widget _buildUpcomingAppointments(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Sample upcoming appointment card
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
          // Sample missed appointment card
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUpcoming
              ? theme.colorScheme.primary.withAlpha(80)
              : theme.colorScheme.error.withAlpha(80),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withAlpha(30),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date Section (Left side)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "20", // Extract day from date
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                Text(
                  "Jul", // Extract month from date
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "2025", // Extract year from date
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Appointment Details (Center)
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

          // Action Buttons (Right side)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit
              Container(
                width: 48,
                height: 36,
                child: isUpcoming
                    ? ElevatedButton(
                        onPressed: () {
                          // Handle join/view action
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 16,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          // Handle reschedule action
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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

              // Map Button
              Container(
                width: 48,
                height: 36,
                child: OutlinedButton(
                  onPressed: () {
                    // Handle map action
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: theme.colorScheme.surfaceContainerHighest,
                        width: 0),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Icon(
                    Icons.map,
                    size: 16,
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
