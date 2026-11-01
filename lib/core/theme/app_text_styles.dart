import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Big numbers (steps, calories)
  static final hero = GoogleFonts.sora(
    fontSize: 64,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.3,
    color: AppColors.textPrimary,
    height: 1.0,
  );

  static final headline = GoogleFonts.sora(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.7,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static final title = GoogleFonts.sora(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static final body = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static final bodyStrong = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Small uppercase labels
  static final label = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.3,
    color: AppColors.textSecondary,
  );
}