import 'package:flutter/material.dart';

/// Brand palette for Sankar Connect.
///
/// Indigo is the primary brand colour, teal is the supporting accent and
/// amber is used sparingly for ratings and highlights.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color secondary = Color(0xFF14B8A6);
  static const Color accent = Color(0xFFF59E0B);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color star = Color(0xFFFBBF24);

  // Light theme neutrals
  static const Color lightBackground = Color(0xFFF7F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // Dark theme neutrals
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF181B24);
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF2A2F3A);

  /// Main brand gradient used on splash, headers and hero cards.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF6366F1), Color(0xFF4F46E5), Color(0xFF3730A3)],
  );

  /// Softer accent gradient for promotional cards.
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF14B8A6), Color(0xFF0EA5E9)],
  );
}
