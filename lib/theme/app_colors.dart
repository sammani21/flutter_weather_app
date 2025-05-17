import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Dark Purple and Medium Purple)
  static const Color primaryDark = Color(0xFF4A148C); // Deep Purple
  static const Color primary = Color(0xFF6A1B9A);     // Medium Purple

  // Accent Colors (Light Purple shades)
  static const Color accent = Color(0xFFBA68C8);       // Soft Purple Accent
  static const Color accentLight = Color(0xFFE1BEE7);  // Very Light Purple

  // Background Colors
  static const Color background = Color(0xFF6A1B9A); // Matching Primary
  static const Color cardBackground = Colors.white;

  // Text Colors
  static const Color textDark = Color(0xFF2D2F3A); // Can remain the same
  static const Color textLight = Colors.white;
  static const Color textGrey = Color(0xFFBDBDBD); // Slightly lighter gray

  // Progress Colors
  static const Color progress = Color(0xFFCE93D8); // Purple Progress
  static const Color progressBackground = Color(
    0x33FFFFFF,
  ); // White with 20% opacity

  // Gradient Colors - Purple Gradient
  static final List<Color> backgroundGradient = [
    const Color(0xFFBA68C8), // Soft Purple
    const Color(0xFF8E24AA), // Stronger Purple
  ];
}
