import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthify/widgets/bottom_navigation_bar.dart';
import 'package:healthify/screens/health_assistant.dart';
import 'package:healthify/utilities/firebase_calls.dart';
import 'package:healthify/widgets/home/home_app_bar.dart';
import 'package:healthify/widgets/home/home_search_bar.dart';
import 'package:healthify/widgets/home/steps_card.dart';
import 'package:healthify/widgets/home/upcoming_schedule_card.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:healthify/main.dart';
import 'package:healthify/utilities/status_bar_utils.dart';

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

    // Force Color
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = MyAppState.of(context);
      appState?.toggleDarkMode(appUser.darkMode, saveToFirebase: false);
      appState?.changeUserColor(appUser.colorSeed, saveToFirebase: false);
    });

    requestActivityPermission();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    if (!mounted) return; // Prevent setState if widget is disposed
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
    // Change status bar color
    StatusBarUtils.setStatusBar(context);

    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    bool isDarkMode = theme.brightness == Brightness.dark;

    String colorToHex(Color color) =>
        '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';

    String getBlobSvg(Color color) {
      final hex = colorToHex(color);
      return '''
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <path fill="$hex" d="M42,-47.9C54.9,-39.2,66.3,-26.4,70,-11.4C73.7,3.6,69.9,20.9,60,31.6C50.2,42.4,34.4,46.6,17.9,55.2C1.5,63.7,-15.5,76.6,-31.1,75.3C-46.6,74,-60.6,58.5,-63.4,42.2C-66.2,25.8,-57.8,8.6,-52.8,-7.5C-47.8,-23.6,-46.2,-38.4,-38,-47.9C-29.8,-57.5,-14.9,-61.7,-0.2,-61.5C14.5,-61.3,29,-56.6,42,-47.9Z" transform="translate(100 100)" />
</svg>
''';
    }

    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Container(
          height: size.height,
          width: size.width,
          color: colorScheme.surface,
        ),
        Positioned(
          top: -240,
          left: -210,
          child: SvgPicture.string(
            getBlobSvg(colorScheme.secondaryContainer),
            width: 730,
            height: 730,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with avatar and greeting
                  HomeAppBar(theme: theme),
                  const SizedBox(height: 20),
                  Text(
                    "Hello",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
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
                  HomeSearchBar(
                      isDarkMode: isDarkMode,
                      colorScheme: colorScheme,
                      theme: theme),
                  const SizedBox(height: 20),
                  // Steps Widget
                  StepsCard(
                      colorScheme: colorScheme, theme: theme, steps: _steps),
                  const SizedBox(height: 20),
                  // Upcoming Schedule
                  Text(
                    "Upcoming Schedule",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 15),
                  UpcomingScheduleCard(colorScheme: colorScheme, theme: theme),
                  const SizedBox(height: 20),
                  // What do you need?
                  Text(
                    "AI Shortcuts",
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
                        title: "Symptoms",
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
                        title: "Wellness",
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
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (title == "Wellness") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HealthAssistant(
                        shortCutQuery:
                            "Give me a variety of practical health tips for maintaining overall physical and mental wellness. Include advice on nutrition, exercise, sleep, stress management, and hydration. Make the tips beginner-friendly and easy to follow in daily life.")),
              );
            } else if (title == "Symptoms") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HealthAssistant(
                        shortCutQuery:
                            "I’m experiencing some symptoms but I’m not sure what they mean. Help me understand what common causes might be for things like headaches, fatigue, stomach pain, or dizziness. Keep it general and informative — I’m not looking for a diagnosis, just guidance.")),
              );
            } else if (title == "Medicines") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HealthAssistant(
                        shortCutQuery:
                            "What are some commonly used medicines for everyday issues like pain, cold, allergies, or stomach problems? Briefly explain what they do and what to watch out for.")),
              );
            }
            // Handle tap
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
