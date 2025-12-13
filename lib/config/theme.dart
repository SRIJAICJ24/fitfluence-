import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';
export 'constants.dart'; // Make AppColors available to anyone importing theme.dart

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepSlate,
      primaryColor: AppColors.volt,
      fontFamily: GoogleFonts.outfit().fontFamily,
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.volt,
        secondary: AppColors.cyan,
        surface: AppColors.midnightBlue,
        background: AppColors.deepSlate,
        error: AppColors.error,
        onPrimary: AppColors.deepSlate,
        onSecondary: AppColors.deepSlate,
        onSurface: AppColors.lightSlate,
        onBackground: AppColors.lightSlate,
        onError: Colors.white,
      ),

      textTheme: TextTheme(
        // Headline XLarge
        displayLarge: GoogleFonts.outfit(
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: AppColors.lightSlate,
        ),
        // Headline Large
        displayMedium: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.lightSlate,
        ),
        // Headline Medium
        displaySmall: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.lightSlate,
        ),
        // Headline Small
        headlineMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.lightSlate,
        ),
        // Headline Tiny
        headlineSmall: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightSlate,
        ),
        
        // Title Large (Button text)
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.lightSlate,
        ),
        // Title Medium
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.lightSlate,
        ),
        // Title Small
        titleSmall: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.lightSlate,
        ),
        
        // Body Large
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.lightSlate,
        ),
        // Body Medium
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.slateGrey,
        ),
        // Body Small
        bodySmall: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.slateGrey,
        ),
        
        // Label Large
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.lightSlate,
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.lightSlate),
      ),
      
      iconTheme: const IconThemeData(
        color: AppColors.lightSlate,
      ),
    );
  }
}
