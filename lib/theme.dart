// lib/theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  AppColors._();

  // ────── Core Brand Colors ──────
  static const Color primary = Color(0xFF8156FF); // #8156FF
  static const Color primaryDark = Color(
    0xFF6F41E8,
  ); // Slightly deeper variant for gradients
  static const Color accent = Color(0xFFF1D16E); // #F1D16E – Warm gold accent

  // ────── Dark Mode Surfaces ──────
  static const Color background = Color(0xFF192029); // #192029
  static const Color surface = Color(0xFF0F1418); // #0F1418
  static const Color surfaceVariant = Color(0xFF1E2529);
  static const Color surfaceMuted = Color(0xFF252C34);

  // ────── Light / Onboarding ──────
  static const Color softGray = Color(0xFFECF0F1); // #ECF0F1
  static const Color onboardBgStart = Color(0xFFF5F3FF);
  static const Color onboardBgMiddle = Color(0xFFE0F2FE);
  static const Color onboardBgEnd = Color(0xFFECFDF5);

  // ────── Text Colors ──────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCBD5DD);
  static const Color textTertiary = Color(0xFF8F99A3);
  static const Color textOnLight = Color(
    0xFF111827,
  ); // For onboarding headlines
  static const Color textMutedLight = Color(0xFF6B7280);

  // ────── Feedback ──────
  static const Color success = Color(0xFF34D399);
  static const Color error = Color(0xFFFB7185);
  static const Color warning = Color(0xFFFBBF24);
}

class AppRadii {
  AppRadii._();
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double pill = 999.0;
}

class AppShadows {
  AppShadows._();

  static final BoxShadow sm = BoxShadow(
    color: Colors.black.withValues(alpha: 0.1),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  static final BoxShadow soft = BoxShadow(
    color: Colors.black.withValues(alpha: 0.4),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );

  static final BoxShadow glow = BoxShadow(
    color: AppColors.primary.withValues(alpha: 0.25),
    blurRadius: 40,
    offset: const Offset(0, 12),
  );

  static final BoxShadow lg = BoxShadow(
    color: Colors.black.withValues(alpha: 0.3),
    blurRadius: 32,
    offset: const Offset(0, 16),
  );
}

class AppTextStyles {
  static const String fontFamily = 'Inter';

  static TextStyle headlineXL = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.5,
  );
  static TextStyle headline = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );
  static TextStyle headlineMd = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static TextStyle title = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static TextStyle body = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static TextStyle caption = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static TextStyle button = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}

// ────── Final Theme (Dark-first) ──────
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: AppTextStyles.fontFamily,

  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.background,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: AppColors.background,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceVariant,
  ),

  scaffoldBackgroundColor: AppColors.background,

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: AppColors.textPrimary),
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      textStyle: AppTextStyles.button,
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceMuted,
    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    hintStyle: TextStyle(color: AppColors.textTertiary),
  ),

  textTheme: TextTheme(
    headlineLarge: AppTextStyles.headlineXL.copyWith(
      color: AppColors.textPrimary,
    ),
    headlineMedium: AppTextStyles.headline.copyWith(
      color: AppColors.textPrimary,
    ),
    titleLarge: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
    bodyLarge: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
    labelLarge: AppTextStyles.button.copyWith(color: Colors.white),
  ),

  cardTheme: CardThemeData(
    color: AppColors.surfaceVariant,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.lg),
    ),
  ),

  dividerColor: Colors.white.withValues(alpha: 0.08),
  iconTheme: const IconThemeData(color: AppColors.textSecondary),
);
