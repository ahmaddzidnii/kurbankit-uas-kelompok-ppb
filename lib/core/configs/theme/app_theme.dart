import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: AppColors.backgroundBase,
      colorScheme: const ColorScheme.light(
        primary: AppColors.essentialBrightAccent,
        secondary: AppColors.essentialAnnouncement,
        surface: AppColors.backgroundElevatedBase,
        error: AppColors.essentialNegative,
        onPrimary: Colors.white,
        onSurface: AppColors.textBase,
      ),

      textTheme: const TextTheme(
        // Display - Hero text & judul besar
        displayLarge: TextStyle(
          fontSize: AppTypography.displayLarge,
          fontWeight: AppTypography.bold,
          color: AppColors.textBase,
        ),
        displayMedium: TextStyle(
          fontSize: AppTypography.displayMedium,
          fontWeight: AppTypography.bold,
          color: AppColors.textBase,
        ),
        displaySmall: TextStyle(
          fontSize: AppTypography.displaySmall,
          fontWeight: AppTypography.semiBold,
          color: AppColors.textBase,
        ),

        // Heading - Judul section/card
        headlineLarge: TextStyle(
          fontSize: AppTypography.headingLarge,
          fontWeight: AppTypography.semiBold,
          color: AppColors.textBase,
        ),
        headlineMedium: TextStyle(
          fontSize: AppTypography.headingMedium,
          fontWeight: AppTypography.semiBold,
          color: AppColors.textBase,
        ),
        headlineSmall: TextStyle(
          fontSize: AppTypography.headingSmall,
          fontWeight: AppTypography.medium,
          color: AppColors.textBase,
        ),

        // Title - Judul komponen kecil
        titleLarge: TextStyle(
          fontSize: AppTypography.headingSmall,
          fontWeight: AppTypography.semiBold,
          color: AppColors.textBase,
        ),
        titleMedium: TextStyle(
          fontSize: AppTypography.bodyMedium,
          fontWeight: AppTypography.medium,
          color: AppColors.textBase,
        ),
        titleSmall: TextStyle(
          fontSize: AppTypography.bodySmall,
          fontWeight: AppTypography.medium,
          color: AppColors.textBase,
        ),

        // Body - Teks paragraf/konten
        bodyLarge: TextStyle(
          fontSize: AppTypography.bodyLarge,
          fontWeight: AppTypography.regular,
          color: AppColors.textBase,
        ),
        bodyMedium: TextStyle(
          fontSize: AppTypography.bodyMedium,
          fontWeight: AppTypography.regular,
          color: AppColors.textSubdued,
        ),
        bodySmall: TextStyle(
          fontSize: AppTypography.bodySmall,
          fontWeight: AppTypography.regular,
          color: AppColors.textSubdued,
        ),

        // Label - Text tombol, form label, chip
        labelLarge: TextStyle(
          fontSize: AppTypography.labelLarge,
          fontWeight: AppTypography.medium,
          color: AppColors.textBase,
        ),
        labelMedium: TextStyle(
          fontSize: AppTypography.labelMedium,
          fontWeight: AppTypography.medium,
          color: AppColors.textBase,
        ),
        labelSmall: TextStyle(
          fontSize: AppTypography.labelSmall,
          fontWeight: AppTypography.medium,
          color: AppColors.textSubdued,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundBase,
        foregroundColor: AppColors.textBase,
        elevation: 0,
        centerTitle: true,
      ),

      cardTheme: CardThemeData(
        color: AppColors.backgroundElevatedBase,
        surfaceTintColor: Colors.transparent, // Mematikan tint ungu Material 3
        elevation: 0, // Dibuat 0 karena hierarki visual murni dari warna
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(
            color: AppColors.decorativeSubdued,
            width: 1,
          ), // Border tipis
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.decorativeSubdued,
        thickness: 1,
        space: AppSpacing.lg, // Menggunakan Token Spacing
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          // Warna dasar tombol (diam)
          backgroundColor: WidgetStateProperty.all(
            AppColors.backgroundElevatedBase,
          ),
          foregroundColor: WidgetStateProperty.all(AppColors.textBase),

          // Efek Press saat jari menyentuh layar
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.backgroundElevatedPress;
            }
            return null;
          }),

          // Bentuk dan garis batas tombol
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              side: const BorderSide(color: AppColors.decorativeSubdued),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundElevatedBase,
        hintStyle: const TextStyle(color: AppColors.textSubdued),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.decorativeSubdued),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(
            color: AppColors.essentialBrightAccent,
            width: 2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.essentialNegative),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(
            color: AppColors.essentialNegative,
            width: 2,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundElevatedBase,
        selectedColor: AppColors.essentialBrightAccent,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.backgroundElevatedBase,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.backgroundElevatedBase,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
