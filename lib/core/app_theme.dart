
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bg,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
    );
  }

  /// Font monospace untuk plat nomor & label teknis.
  static TextStyle mono({
    double size = 14,
    FontWeight w = FontWeight.w600,
    Color? color,
    double? spacing,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: w,
        color: color ?? AppColors.textDark,
        letterSpacing: spacing,
      );
}
