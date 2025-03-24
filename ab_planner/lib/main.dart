
import 'package:ab_planner/screens/log_in_screen.dart';
import 'package:ab_planner/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() {
  runApp(const MainApp());
}

final ThemeData customLoginTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xFF0A0A1F), // ciemne tło

  inputDecorationTheme: InputDecorationTheme(
    filled: false,
    hintStyle: TextStyle(color: Colors.white70),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white30),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
    prefixIconColor: Colors.white,
  ),

  textTheme: TextTheme(
    bodyMedium: TextStyle(color: Colors.white),
    labelLarge: TextStyle(color: Colors.white),
    titleLarge: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 22,
      color: Colors.white,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF6C00FF), // fiolet
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(vertical: 14),
      textStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 14),
      textStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  ),

  iconTheme: IconThemeData(color: Colors.white70),
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const MainScreen(),
    );
  }
}
