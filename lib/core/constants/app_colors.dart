import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core Brand Colors
  static const Color primaryGold = Color(0xFFD4A056);
  static const Color goldLight = Color(0xFFF3E5AB);
  static const Color goldDark = Color(0xFFA6752C);
  static const Color brewGreen = Color(0xFF1B4D3E);
  static const Color brewGreenDark = Color(0xFF0F3026);
  static const Color brewGreenLight = Color(0xFF286D58);

  // Background & Surface
  static const Color darkBackground = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF252525);
  static const Color lightCream = Color(0xFFF9F9F9);
  static const Color white = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF757575);
  static const Color textDark = Color(0xFF1A1A1A);

  // Accent & Status
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);
  static const Color divider = Color(0xFF2D2D2D);

  // Loyalty Membership Tiers
  static const Color tierBronze = Color(0xFFCD7F32);
  static const Color tierSilver = Color(0xFFC0C0C0);
  static const Color tierGold = Color(0xFFD4A056);
  static const Color tierPlatinum = Color(0xFFE5E4E2);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFE5B869), Color(0xFFB8822B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF256653), Color(0xFF13382D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luxuryCardGradient = LinearGradient(
    colors: [Color(0xFF2A2824), Color(0xFF171614)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
