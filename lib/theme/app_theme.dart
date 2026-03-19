import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF0B1410);
  static const Color surface = Color(0xFF162018);
  static const Color card = Color(0xFF1A2A20);
  static const Color cardLight = Color(0xFF1E3028);
  static const Color primaryGreen = Color(0xFF4ADE80);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color darkGreen = Color(0xFF14532D);
  static const Color borderGreen = Color(0xFF2D5A3D);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8B9B93);
  static const Color textMuted = Color(0xFF5B6B63);
  static const Color danger = Color(0xFFEF4444);
  static const Color orange = Color(0xFFFF9F43);
  static const Color navInactive = Color(0xFF5B6B63);
  static const Color chipActive = Color(0xFF1A3A28);
  static const Color chipBorder = Color(0xFF2A4A38);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryGreen,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        surface: AppColors.background,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.navInactive,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
    );
  }
}
