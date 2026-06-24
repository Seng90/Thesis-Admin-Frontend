import 'package:flutter/material.dart';

class AppColors {
  // Material 3 (Flutter) inspired theme from Web Prototype
  static const Color primary = Color(0xFF592DB3); // HSL 256 60% 45%
  static const Color primaryHover = Color(0xFF431D93); // Darker primary
  static const Color primaryLight = Color(0xFFEBE6F5); // HSL 256 90% 92%

  static const Color background = Color(0xFFF8F5FB); // HSL 270 25% 98%
  static const Color surface = Color(0xFFF5F0FA); // HSL 270 30% 97%
  static const Color card = Color(0xFFFFFFFF); // HSL 0 0% 100%

  static const Color sidebar = Color(0xFFF5F0FA); // HSL 270 30% 97%
  static const Color border = Color(0xFFDFD8E6); // HSL 270 15% 88%

  static const Color textPrimary = Color(0xFF1B1A1E); // HSL 270 15% 12%
  static const Color textSecondary = Color(0xFF625B69); // HSL 270 8% 42%
  static const Color textMuted = Color(0xFF948A9C); // HSL 270 10% 60%

  static const Color success = Color(0xFF25925A); // HSL 152 60% 36%
  static const Color successBg = Color(0xFFD1FAE5);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFCA1C1C); // HSL 0 75% 45%
  static const Color errorBg = Color(0xFFFEE2E2);

  static const Color white = Colors.white;
}

class AppConstants {
  static const String appName = 'InvesTrack Admin';
  static const String baseUrl = 'http://127.0.0.1:8000/api';
}
