import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1B4DFF),
        secondary: Color(0xFF00C2A8),
        surface: Color(0xFFF7F7FB),
        error: Color(0xFFD64545),
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF7F7FB),
        foregroundColor: Color(0xFF121212),
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 14),
      ),
    );
  }
}
