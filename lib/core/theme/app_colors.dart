import 'package:flutter/material.dart';

class AppColors {
  // Primary color from design
  static const Color primary = Color(0xFF47897F);
  
  // Background colors
  static const Color background = Color(0xFFE8F5F3);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);
  
  // Status colors
  static const Color statusEnviado = Color(0xFF5F9AE0);
  static const Color statusAnalise = Color(0xFFF4D03F);
  static const Color statusConcluido = Color(0xFF52C41A);
  static const Color statusRejeitado = Color(0xFFE74C3C);
  
  // Input colors
  static const Color inputBackground = Color(0xFFF5F5F5);
  static const Color inputBorder = Color(0xFFE0E0E0);
  
  // Button colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = surface;
  
  // Gradient for background
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF47897F),
      Color(0xFF5A9D93),
    ],
  );
}
