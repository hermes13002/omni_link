import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.getFont(
        'Geist',
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.02 * 48,
      ),
      headlineLarge: GoogleFonts.getFont(
        'Geist',
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      headlineMedium: GoogleFonts.getFont(
        'Geist',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      labelMedium: GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      // Using labelSmall to represent label-xs from design since Flutter only has Small/Medium/Large
      // Alternatively, we could define custom extensions, but for simplicity, we map it to bodySmall
      bodySmall: GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
    );
  }
}
