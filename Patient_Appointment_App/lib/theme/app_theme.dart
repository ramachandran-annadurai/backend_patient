import 'package:flutter/material.dart';

class AppTheme {
  // Background blob colors from the theme image
  static const Color backgroundLightBlue = Color(0xFFE3F2FD); // Light blue blob
  static const Color backgroundLightPink = Color(0xFFFCE4EC); // Light pink blob

  // Pastel color palette based on the image
  static const Color lightBlue = Color(0xFFB8E6FF); // Soft periwinkle blue
  static const Color lightPink = Color(0xFFFFB8D1); // Soft blush pink

  // Brighter versions for buttons
  static const Color brightBlue = Color(0xFF4FC3F7); // Brighter blue
  static const Color brightPink = Color(0xFFFF6B9D); // Brighter pink

  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF2C2C2C); // Border color
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color textGray = Color(0xFF666666);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightBlue,
        brightness: Brightness.light,
        primary: lightBlue,
        secondary: lightPink,
        surface: white,
        background: white,
        error: Colors.red.shade300,
      ),
      scaffoldBackgroundColor: white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textGray,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textGray,
          fontSize: 32,
          fontWeight: FontWeight.w300,
        ),
        displayMedium: TextStyle(
          color: textGray,
          fontSize: 28,
          fontWeight: FontWeight.w300,
        ),
        headlineLarge: TextStyle(
          color: textGray,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: TextStyle(
          color: textGray,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        bodyLarge: TextStyle(
          color: textGray,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: textGray,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightBlue,
          foregroundColor: white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightGray, width: 1),
        ),
      ),
    );
  }
}
