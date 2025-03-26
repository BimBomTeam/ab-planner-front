
import 'package:ab_planner/screens/log_in_screen.dart';
import 'package:ab_planner/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() {
  runApp(const MainApp());
}

final ThemeData customLoginTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0A0A1F),

  inputDecorationTheme: const InputDecorationTheme(
    prefixIconColor: Colors.white70,
    labelStyle: TextStyle(color: Colors.white70),
    hintStyle: TextStyle(color: Colors.white70),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white38),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
  ),

  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white),
    labelLarge: TextStyle(color: Colors.white),
    titleLarge: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 26,
      letterSpacing: 1.2,
      color: Colors.white,
    ),
    bodySmall: TextStyle(color: Colors.white70, fontSize: 14),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF3A0CA3),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      side: const BorderSide(color: Colors.white30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),

  iconTheme: const IconThemeData(color: Colors.white70),
);


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
    return SafeArea(child: child!);
  },
      theme: customLoginTheme,
      localizationsDelegates:  const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales:  const [
        Locale('pl', 'PL'), 
        Locale('en', 'US'), 
      ],
      home: SafeArea(child: const MainScreen()),
    );
  }
}
