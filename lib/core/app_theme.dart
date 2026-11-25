import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  /// Kurva animasi membal (bouncy spring) sesuai panduan desain.
  static const Curve bouncyCurve = Cubic(0.34, 1.56, 0.64, 1);
  static const Duration bouncyDuration = Duration(milliseconds: 240);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.peach,
        onSecondary: AppColors.peachInk,
        surface: AppColors.elevated,
        onSurface: AppColors.textDark,
        error: AppColors.danger,
      ),
    );

    final bodyTheme = base.textTheme.apply(
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      bodyColor: AppColors.textDark,
      displayColor: AppColors.textDark,
    );

    return base.copyWith(
      textTheme: bodyTheme.copyWith(
        headlineLarge: heading(size: 28),
        headlineMedium: heading(size: 22),
        headlineSmall: heading(size: 18),
        titleLarge: heading(size: 18),
        titleMedium: heading(size: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.elevated,
        hintStyle: body(size: 13, color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textDark,
        contentTextStyle: body(size: 13, color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  /// Heading bulat, ramah, dan manis (`Fredoka`).
  static TextStyle heading({
    double size = 20,
    FontWeight w = FontWeight.w700,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.fredoka(
        fontSize: size,
        fontWeight: w,
        color: color ?? AppColors.textDark,
        letterSpacing: -0.01 * size,
        height: height,
      );

  /// Paragraf & teks UI bersih (`Plus Jakarta Sans`).
  static TextStyle body({
    double size = 13,
    FontWeight w = FontWeight.w500,
    Color? color,
    double height = 1.6,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: w,
        color: color ?? AppColors.textDark,
        height: height,
      );

  /// Aksen tulisan tangan untuk stiker catatan kecil (`Patrick Hand`).
  static TextStyle sticker({
    double size = 13,
    FontWeight w = FontWeight.w400,
    Color? color,
  }) =>
      GoogleFonts.patrickHand(
        fontSize: size,
        fontWeight: w,
        color: color ?? AppColors.textDark,
      );

  /// Font monospace untuk plat nomor & kode sesi (`JetBrains Mono`).
  static TextStyle mono({
    double size = 14,
    FontWeight w = FontWeight.w700,
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
