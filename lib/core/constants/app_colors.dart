// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Premium Modern Violet theme seeds
  static const Color primarySeed = Color(0xFF6C5CE7);
  
  // Custom dark-mode accents
  static const Color darkBackground = Color(0xFF0F0E17);
  static const Color darkSurface = Color(0xFF15141F);
  
  // Custom light-mode accents
  static const Color lightBackground = Color(0xFFF9F9FB);
  static const Color lightSurface = Color(0xFFFFFFFF);

  // Generate Theme Data helper
  static ThemeData getTheme(bool isDarkMode) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      colorScheme: baseScheme.copyWith(
        surface: isDarkMode ? darkSurface : lightSurface,
      ),
      scaffoldBackgroundColor: isDarkMode ? darkBackground : lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? darkSurface : lightSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: isDarkMode ? darkSurface : lightSurface,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
