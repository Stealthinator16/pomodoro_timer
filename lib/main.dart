import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';
import 'timer_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(storage: StorageService(prefs)));
}

class MyApp extends StatefulWidget {
  final StorageService storage;

  const MyApp({super.key, required this.storage});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _currentThemeMode = ThemeMode.system;

  void _cycleThemeMode() {
    setState(() {
      if (_currentThemeMode == ThemeMode.system) {
        _currentThemeMode = ThemeMode.light;
      } else if (_currentThemeMode == ThemeMode.light) {
        _currentThemeMode = ThemeMode.dark;
      } else {
        _currentThemeMode = ThemeMode.system;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- Light Palette ---
    const lightCreamBg = Color(0xFFFFFBF5);
    const lightPinkPrimary = Color(0xFFFFACC7);
    const lightBrownText = Color(0xFF6D4C41);
    const lightOnPrimary = Colors.white;
    final lightBase = ThemeData.light().textTheme;

    // --- Dark Palette ---
    const darkIndigoBg = Color(0xFF242038);
    const darkPinkPrimary = Color(0xFFF8BBD0);
    const darkCreamText = Color(0xFFFDF9F3);
    const darkOnPrimary = Color(0xFF242038);
    final darkBase = ThemeData.dark().textTheme;

    return MaterialApp(
      title: 'Cute Pomo',
      debugShowCheckedModeBanner: false,

      // --- Light Theme ---
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: lightPinkPrimary,
          brightness: Brightness.light,
          surface: lightCreamBg,
          primary: lightPinkPrimary,
          onSurface: lightBrownText,
          onPrimary: lightOnPrimary,
        ),
        scaffoldBackgroundColor: lightCreamBg,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: lightBrownText.withValues(alpha: 0.8)),
          titleTextStyle: lightBase.titleLarge?.copyWith(
            color: lightBrownText,
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: lightBase.apply(
          bodyColor: lightBrownText,
          displayColor: lightBrownText,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightPinkPrimary,
            foregroundColor: lightOnPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: lightBrownText.withValues(alpha: 0.8),
          ),
        ),
      ),

      // --- Dark Theme ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkPinkPrimary,
          brightness: Brightness.dark,
          surface: darkIndigoBg,
          primary: darkPinkPrimary,
          onSurface: darkCreamText,
          onPrimary: darkOnPrimary,
        ),
        scaffoldBackgroundColor: darkIndigoBg,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: darkCreamText.withValues(alpha: 0.8)),
          titleTextStyle: darkBase.titleLarge?.copyWith(
            color: darkCreamText,
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: darkBase.apply(
          bodyColor: darkCreamText,
          displayColor: darkCreamText,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkPinkPrimary,
            foregroundColor: darkOnPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: darkCreamText.withValues(alpha: 0.8),
          ),
        ),
      ),

      themeMode: _currentThemeMode,

      home: TimerPage(
        onThemeModePressed: _cycleThemeMode,
        currentThemeMode: _currentThemeMode,
        storage: widget.storage,
      ),
    );
  }
}
