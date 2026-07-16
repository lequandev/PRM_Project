import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// AppTheme — ThemeData chính thức cho Coffee Shop.
/// Dùng brand palette: Gold #D4A017, Brown #5A3E2B, Beige #F8F3EA
/// Dev 2, 3, 4, 5: dùng `Theme.of(context)` — không hardcode màu.
/// Dev 1 owns — không tự sửa ngoài core_module.
abstract class AppTheme {
  // ─────────────────────────────────────────────
  // Light Theme (dùng cho app_customer, app_staff)
  // ─────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Inter',

        // Color Scheme
        colorScheme: const ColorScheme.light(
          primary: AppColors.goldPrimary,
          onPrimary: AppColors.textOnGold,
          primaryContainer: AppColors.goldLight,
          secondary: AppColors.brownAccent,
          onSecondary: AppColors.white,
          surface: AppColors.cardBackground,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
          onError: AppColors.white,
        ),

        // Scaffold
        scaffoldBackgroundColor: AppColors.backgroundLight,

        // AppBar — Beige ấm theo brand
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.beigeWarm,
          foregroundColor: AppColors.brownAccent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.brownAccent,
          ),
          iconTheme: IconThemeData(color: AppColors.brownAccent),
        ),

        // ElevatedButton — Gold Primary
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.goldPrimary,
            foregroundColor: AppColors.textOnGold,
            textStyle: AppTypography.button,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            elevation: 2,
          ),
        ),

        // OutlinedButton — Gold border
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.goldPrimary,
            textStyle: AppTypography.button,
            side: const BorderSide(color: AppColors.goldPrimary, width: 1.5),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        ),

        // TextButton
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.goldPrimary,
            textStyle: AppTypography.button,
          ),
        ),

        // InputDecoration (TextField)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.backgroundAlt,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 4,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide:
                const BorderSide(color: AppColors.goldPrimary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          hintStyle:
              AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
          labelStyle: AppTypography.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),

        // Card — trắng tinh, viền nhẹ
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),

        // BottomNavigationBar — Gold active
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.cardBackground,
          selectedItemColor: AppColors.goldPrimary,
          unselectedItemColor: AppColors.textHint,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),

        // Chip — Beige background
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.beigeLight,
          selectedColor: AppColors.goldLight,
          labelStyle: AppTypography.label,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),

        // Divider — border nhẹ
        dividerTheme: const DividerThemeData(
          color: AppColors.borderLight,
          thickness: 1,
          space: 0,
        ),

        // Text theme
        textTheme: TextTheme(
          displayLarge: AppTypography.displayLarge
              .copyWith(color: AppColors.textPrimary),
          displayMedium: AppTypography.displayMedium
              .copyWith(color: AppColors.textPrimary),
          headlineLarge:
              AppTypography.h1.copyWith(color: AppColors.textPrimary),
          headlineMedium:
              AppTypography.h2.copyWith(color: AppColors.textPrimary),
          headlineSmall:
              AppTypography.h3.copyWith(color: AppColors.textPrimary),
          titleLarge:
              AppTypography.h4.copyWith(color: AppColors.textPrimary),
          bodyLarge:
              AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
          bodyMedium: AppTypography.bodyMedium
              .copyWith(color: AppColors.textSecondary),
          bodySmall:
              AppTypography.bodySmall.copyWith(color: AppColors.textHint),
          labelLarge: AppTypography.button.copyWith(color: AppColors.textPrimary),
          labelSmall:
              AppTypography.caption.copyWith(color: AppColors.textHint),
        ),
      );

  // ─────────────────────────────────────────────
  // Admin Theme (Brown header, darker)
  // ─────────────────────────────────────────────
  static ThemeData get admin => light.copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.brownAccent,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
          iconTheme: IconThemeData(color: AppColors.white),
        ),
      );

  // ─────────────────────────────────────────────
  // Staff Theme (similar to light, slightly darker AppBar)
  // ─────────────────────────────────────────────
  static ThemeData get staff => light.copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.brownAccent,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
          iconTheme: IconThemeData(color: AppColors.white),
        ),
      );
}
