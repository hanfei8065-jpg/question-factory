import 'package:flutter/material.dart';

class AppTheme {
  static const double padding = 16.0;

  // WeChat Green - Updated from #00A86B to #07C160
  static const Color primary = Color(0xFF07C160);

  static final ThemeData theme = ThemeData(
    primaryColor: const Color(0xFF07C160),
    scaffoldBackgroundColor: const Color(
      0xFFEDEDED,
    ), // WeChat classic light grey
    fontFamily: '-apple-system',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF111111)),
      titleTextStyle: TextStyle(
        color: Color(0xFF111111),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF07C160), // WeChat Green
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF808080), // Grey
        side: const BorderSide(color: Color(0xFFD5D5D5)), // WeChat border
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF07C160), // WeChat Green
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFFFFFF), // Pure white
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD5D5D5)), // WeChat border
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD5D5D5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF07C160), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    colorScheme: const ColorScheme(
      primary: Color(0xFF07C160), // WeChat Green
      secondary: Color(0xFF07C160), // WeChat Green
      surface: Color(0xFFFFFFFF), // Pure white
      error: Color(0xFFFA5151), // WeChat Red
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF111111), // Almost black
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xFF111111)),
      displayMedium: TextStyle(color: Color(0xFF111111)),
      displaySmall: TextStyle(color: Color(0xFF111111)),
      headlineLarge: TextStyle(color: Color(0xFF111111)),
      headlineMedium: TextStyle(color: Color(0xFF111111)),
      headlineSmall: TextStyle(color: Color(0xFF111111)),
      titleLarge: TextStyle(color: Color(0xFF111111)),
      titleMedium: TextStyle(color: Color(0xFF111111)),
      titleSmall: TextStyle(color: Color(0xFF111111)),
      bodyLarge: TextStyle(color: Color(0xFF111111)),
      bodyMedium: TextStyle(color: Color(0xFF111111)),
      bodySmall: TextStyle(color: Color(0xFF808080)), // Grey
      labelLarge: TextStyle(color: Color(0xFF111111)),
      labelMedium: TextStyle(color: Color(0xFF808080)),
      labelSmall: TextStyle(color: Color(0xFF808080)),
    ),
    dividerColor: const Color(0xFFD5D5D5), // WeChat divider
  );
}
