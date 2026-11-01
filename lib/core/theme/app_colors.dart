import 'package:flutter/material.dart';

class AppColors {
  static const bgTop = Color(0xFF07080C);
  static const bgBottom = Color(0xFF12142A);
  static const surface = Color(0xB314172A); // #14172A at ~70%
  static const hairline = Color(0x14FFFFFF); // white at 8%

  static const goldLight = Color(0xFFE8C48A);
  static const goldDark = Color(0xFFC98A4B);

  static const textPrimary = Color(0xFFF5F3EE);
  static const textSecondary = Color(0xFF8D90A3);
  static const textMuted = Color(0xFF5A5D70);

  static const goldGradient = LinearGradient(
    colors: [goldLight, goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const backgroundGradient = LinearGradient(
    colors: [bgTop, bgBottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}