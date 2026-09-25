import 'package:flutter/material.dart';

/// Semantic color tokens for MAPID Mobile GIS, adhering to antislop-ui guidelines
/// and WCAG AA contrast standards (>= 4.5:1 for body copy).
abstract final class AppColors {
  // Brand & Primary
  static const Color primary = Color(0xFF1E3A8A); // Deep Royal Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF172554);

  // Cartographic & Vector Markers
  static const Color mapPinDefault = Color(0xFF0284C7); // Vivid Sky Blue (Inactive POI)
  static const Color mapPinBorder = Color(0xFFFFFFFF);
  static const Color mapPinActive = Color(0xFF1E3A8A); // Deep Royal Blue (Active/Selected POI, Brand Accent)
  static const Color mapPinActiveHalo = Color(0x330284C7); // Focus Halo Ring (20% Opacity)
  static const Color userLocationMarker = Color(0xFF2563EB); // Vibrant GPS Blue
  static const Color userLocationHalo = Color(0x332563EB); // Semi-transparent pulse

  // Neutrals & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF1F5F9); // Slate 100
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderStrong = Color(0xFFCBD5E1); // Slate 300

  // Text & Typography (WCAG AA Compliant)
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900 (~17.8:1 on white)
  static const Color textSecondary = Color(0xFF475569); // Slate 600 (~7.5:1 on white)
  static const Color textMuted = Color(0xFF57657A); // Slate 550 (~5.9:1 on white, ~5.4:1 on surfaceElevated)
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status & Feedback
  static const Color error = Color(0xFFB91C1C); // Red 700 (~5.9:1 on errorSurface, ~6.4:1 on white)
  static const Color errorSurface = Color(0xFFFEF2F2); // Red 50
  static const Color errorBorder = Color(0xFFFECACA); // Red 200
  static const Color success = Color(0xFF059669); // Emerald 600
  static const Color successSurface = Color(0xFFECFDF5); // Emerald 50
  static const Color warning = Color(0xFFD97706); // Amber 600
}
