import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:healthify/screens/health_assistant.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';

import 'package:healthify/screens/home.dart';
import 'package:healthify/screens/settings.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healthify/utilities/firebase_calls.dart';

// ms tans files
import 'package:healthify/screens/login_screen.dart';
import 'package:healthify/screens/update_app_user_screen.dart';
import 'package:healthify/screens/clinics_screen.dart';

import 'package:healthify/screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('dotenv load failed: $e');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final geminiApiKey = dotenv.env['GEMINI_API_KEY'];
  if (geminiApiKey == null || geminiApiKey.isEmpty) {
    debugPrint('GEMINI_API_KEY missing; Gemini disabled.');
  } else {
    Gemini.init(apiKey: geminiApiKey);
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _darkMode = false;
  Color _userColor = Colors.blue[100]!;
  bool _themeInitialized = false;

  bool _showOnboarding = true;

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seen = prefs.getBool('onboarding_seen') ?? false;
    setState(() {
      _showOnboarding = !seen;
    });
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    setState(() {
      _showOnboarding = false;
    });
  }

  static MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<MyAppState>();
  }

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
    initializeTheme();
  }

  Future<void> initializeTheme() async {
    // Wait for user authentication and data loading
    // This should be called after user logs in
    if (auth.currentUser != null && !_themeInitialized) {
      try {
        await FirebaseCalls().getAppUser(auth.currentUser!.uid);
        setState(() {
          _darkMode = appUser.darkMode;
          _userColor = appUser.colorSeed;
          _themeInitialized = true;
        });
      } catch (e) {
        print('Error initializing theme: $e');
      }
    }
  }

  void toggleDarkMode(bool value, {bool saveToFirebase = true}) {
    setState(() => _darkMode = value);
    if (saveToFirebase) _updateThemePreferences();
  }

  void changeUserColor(Color value, {bool saveToFirebase = true}) {
    setState(() => _userColor = value);
    if (saveToFirebase) _updateThemePreferences();
  }

  Future<void> _updateThemePreferences() async {
    if (auth.currentUser != null) {
      try {
        await FirebaseCalls().updateThemePreferences(_darkMode, _userColor);
      } catch (e) {
        print('Error updating theme preferences: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    HSLColor _userColorHSL = HSLColor.fromColor(_userColor);
    Color _userLightThemeColor = _userColorHSL.toColor();
    Color _userDarkThemeColor = _userColorHSL.withLightness(0.5).toColor();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => _showOnboarding
            ? OnboardingScreen(onDone: _completeOnboarding)
            : const LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/clinics': (context) => const ClinicsScreen(),
        '/user': (context) => const UpdateAppUserScreen(),
        '/assistant': (context) => const HealthAssistant(),
        '/settings': (context) => SettingsPage(
            darkMode: _darkMode,
            toggleDarkMode: toggleDarkMode,
            userColor: _userColor,
            setUserColor: changeUserColor,
            onThemeInitialize: initializeTheme),
      },
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Product Sans',
        colorSchemeSeed: _userLightThemeColor,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Product Sans', fontSize: 24),
          bodyMedium: TextStyle(fontFamily: 'Product Sans', fontSize: 20),
          bodySmall: TextStyle(fontFamily: 'Product Sans', fontSize: 16),
          headlineLarge: TextStyle(
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w900,
              fontSize: 32),
          headlineMedium: TextStyle(
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w700,
              fontSize: 20),
          headlineSmall: TextStyle(
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w500,
              fontSize: 16),
        ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
              fontFamily: 'Product Sans',
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Product Sans',
        colorSchemeSeed: _userDarkThemeColor,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
              fontFamily: 'Product Sans', color: Colors.white, fontSize: 24),
          bodyMedium: TextStyle(
              fontFamily: 'Product Sans', color: Colors.white, fontSize: 20),
          bodySmall: TextStyle(
              fontFamily: 'Product Sans', color: Colors.white, fontSize: 16),
          headlineLarge: TextStyle(
              fontFamily: 'Product Sans',
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 32),
          headlineMedium: TextStyle(
              fontFamily: 'Product Sans',
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20),
          headlineSmall: TextStyle(
              fontFamily: 'Product Sans',
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16),
        ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
              fontFamily: 'Product Sans',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        scaffoldBackgroundColor: const Color(0xFF131213),
      ),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
