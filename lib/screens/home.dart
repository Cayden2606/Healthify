import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthify/custom_widgets/bottom_navigation_bar.dart';
import 'package:healthify/utilities/firebase_calls.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<StepCount> _stepCountStream;
  int _steps = 0;

  @override
  void initState() {
    super.initState();
    requestActivityPermission();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps;
    });
  }

  void onStepCountError(error) {
    debugPrint('Step Count Error: $error');
  }

  Future<void> initPlatformState() async {
    _stepCountStream = await Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
  }

  Future<void> requestActivityPermission() async {
    final status = await Permission.activityRecognition.status;
    if (!status.isGranted) {
      final result = await Permission.activityRecognition.request();
      if (result.isGranted) {
        debugPrint('Activity permission granted');
      } else {
        debugPrint('Activity permission denied');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    bool isDarkMode = theme.brightness == Brightness.dark;

    String colorToHex(Color color) =>
        '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';

    String getBlobSvg(Color color) {
      final hex = colorToHex(color);
      return '''
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <path fill="$hex" d="M45.2,-52.2C59.1,-42.2,71.4,-28.5,68.1,-16.5C64.8,-4.6,46,5.5,36.8,21.2C27.7,36.9,28.3,58.2,19.5,67.5C10.7,76.7,-7.6,73.9,-24.6,67.7C-41.6,61.5,-57.3,51.8,-66,37.6C-74.8,23.5,-76.6,4.8,-69.9,-8.7C-63.2,-22.3,-48,-30.7,-35,-40.9C-21.9,-51,-10.9,-62.9,2.3,-65.7C15.6,-68.5,31.3,-62.2,45.2,-52.2Z" transform="translate(100 100)" />
</svg>
''';
    }

    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -150,
          child: SvgPicture.string(
            getBlobSvg(colorScheme.primary),
            width: 400,
            height: 400,
          ),
        ),
        Scaffold(
          // backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with avatar and greeting
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: const NetworkImage(
                      "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png?20150327203541",
                    ),
                    backgroundColor: Colors.transparent,
                  ),

                  const SizedBox(height: 20),
                  Text(
                    "Hello",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '${appUser.name}!',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? colorScheme.surface.withOpacity(0.5)
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Icon(
                            Icons.search,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        hintText: "Search clinics, services...",
                        hintStyle: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Steps Widget
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.onPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.directions_walk,
                            size: 28,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "TODAY'S STEPS", // It only track from phone's last boot
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onPrimary.withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _steps > 0 ? _steps.toString() : 'Loading...',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    20), // makes it pill-shaped
                                child: LinearProgressIndicator(
                                  value: (_steps.clamp(0, 10000)) / 10000,
                                  minHeight:
                                      10, // optional: makes the pill taller
                                  backgroundColor:
                                      colorScheme.onPrimary.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.onPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.onPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "Goal: 10K",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Upcoming Schedule
                  Text(
                    "Upcoming Schedule",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 130,
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.secondaryContainer,
                          colorScheme.secondaryContainer.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 32,
                          color: colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "No appointments today",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tap to schedule",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSecondaryContainer
                                .withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // What do you need?
                  Text(
                    "What do you need?",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildServiceCard(
                        context: context,
                        icon: Icons.local_hospital,
                        title: "Doctor",
                        color: colorScheme.primary,
                      ),
                      _buildServiceCard(
                        context: context,
                        icon: Icons.medical_services,
                        title: "Medicines",
                        color: colorScheme.tertiary,
                      ),
                      _buildServiceCard(
                        context: context,
                        icon: Icons.health_and_safety,
                        title: "Health Tips",
                        color: colorScheme.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 0),
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
  }) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle tap
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
