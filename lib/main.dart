import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'package:healthify/screens/home.dart';
import 'package:healthify/screens/settings.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ms tans files
import 'package:healthify/screens/login_screen.dart';
import 'package:healthify/screens/update_app_user_screen.dart';
import 'package:healthify/screens/clinics_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await dotenv.load(fileName: ".env");
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _darkMode = ThemeMode.system == ThemeMode.dark;
  void _toggleDarkMode(bool value) {
    setState(() => _darkMode = value);
  }

  Color _userColor = Colors.blue[100]!;
  void _changeUserColor(Color value) {
    setState(() => _userColor = value);
  }

  @override
  Widget build(BuildContext context) {
    HSLColor _userColorHSL = HSLColor.fromColor(_userColor);
    Color _userLightThemeColor = _userColorHSL.toColor();
    Color _userDarkThemeColor = _userColorHSL.withLightness(0.5).toColor();

    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/clinics': (context) => const ClinicsScreen(),
        '/user': (context) => const UpdateAppUserScreen(),
        '/settings': (context) => SettingsPage(
            darkMode: _darkMode,
            toggleDarkMode: _toggleDarkMode,
            userColor: _userColor,
            setUserColor: _changeUserColor),
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
