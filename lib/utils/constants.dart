import 'package:flutter/material.dart';

class AppColors {
  // Modern SaaS Color Palette
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryHover = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFFEEF2FF); // Indigo 50
  
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF); // White
  
  static const Color sidebar = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successBg = Color(0xFFD1FAE5); // Emerald 100
  
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningBg = Color(0xFFFEF3C7); // Amber 100
  
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorBg = Color(0xFFFEE2E2); // Red 100
  
  static const Color white = Colors.white;
}

class AppConstants {
  static const String appName = 'InvesTrack Admin';
  static const String baseUrl = 'http://127.0.0.1:8000/api'; 
}
