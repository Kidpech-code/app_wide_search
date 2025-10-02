import 'package:flutter/material.dart';

/// Pre-defined themes for examples.
///
/// Provides consistent, accessible themes across all example apps.
class AppThemes {
  AppThemes._();

  /// Default light theme with Material 3.
  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    ),
  );

  /// Default dark theme with Material 3.
  static ThemeData get darkTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    ),
  );

  /// Blue accent theme.
  static ThemeData get blueTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );

  /// Green accent theme.
  static ThemeData get greenTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );

  /// Orange accent theme.
  static ThemeData get orangeTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );

  /// High contrast theme for accessibility.
  static ThemeData get highContrastTheme => ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      secondary: Colors.black,
      surface: Colors.white,
      error: Colors.red,
    ),
    useMaterial3: true,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
      bodyMedium: TextStyle(color: Colors.black, fontSize: 16),
    ),
  );

  /// List of all available themes with names.
  static Map<String, ThemeData> get allThemes => {
    'Light': lightTheme,
    'Dark': darkTheme,
    'Blue': blueTheme,
    'Green': greenTheme,
    'Orange': orangeTheme,
    'High Contrast': highContrastTheme,
  };
}
