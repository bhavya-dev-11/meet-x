// lib/theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  AppColors._();

  // ────── Core Brand Colors ──────
  static const Color primary = Color(0xFF4F46E5); // Royal Indigo
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color accent = Color(0xFF00D9B5); // Teal accent for dark mode
  static const Color accentGold = Color(0xFFF1D16E); // Secondary warm accent

  // ────── Dark Mode Surfaces (Refined) ──────
  static const Color background = Color(0xFF0A0E14);
  static const Color backgroundLight = Color(0xFF0F1419);
  static const Color surface = Color(0xFF151B23);
  static const Color surfaceLight = Color(0xFF1C242D);
  static const Color surfaceCard = Color(0xFF1A222C);
  static const Color surfaceBorder = Color(0xFF2A3441);

  // ────── Text Colors (Dark Mode) ──────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB4C1D0);
  static const Color textTertiary = Color(0xFF7A8999);
  static const Color textMuted = Color(0xFF5A6677);

  // ────── Feedback ──────
  static const Color success = Color(0xFF00D9B5);
  static const Color error = Color(0xFFFF6B8A);
  static const Color warning = Color(0xFFFBBF24);
  static const Color info = Color(0xFF5BA4FF);

  // Legacy compatibility (used in some views)
  static const Color onboardBgStart = Color(0xFF0A0E14);
  static const Color onboardBgMiddle = Color(0xFF0F1419);
  static const Color onboardBgEnd = Color(0xFF151B23);
  static const Color softGray = Color(0xFF1C242D);
  static const Color textOnLight = Color(0xFFFFFFFF);
  static const Color textMutedLight = Color(0xFF7A8999);
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
    color: Colors.black.withValues(alpha: 0.25),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  static final BoxShadow soft = BoxShadow(
    color: Colors.black.withValues(alpha: 0.4),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );

  static final BoxShadow glow = BoxShadow(
    color: AppColors.primary.withValues(alpha: 0.35),
    blurRadius: 40,
    offset: const Offset(0, 12),
  );

  static final BoxShadow lg = BoxShadow(
    color: Colors.black.withValues(alpha: 0.5),
    blurRadius: 32,
    offset: const Offset(0, 16),
  );

  // Dark mode specific - subtle glows
  static final BoxShadow primaryGlow = BoxShadow(
    color: AppColors.primary.withValues(alpha: 0.2),
    blurRadius: 24,
    spreadRadius: 0,
  );

  static final BoxShadow accentGlow = BoxShadow(
    color: AppColors.accent.withValues(alpha: 0.15),
    blurRadius: 20,
    spreadRadius: 0,
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

// ────── Final Theme (Dark Professional) ──────
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: AppTextStyles.fontFamily,

  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.surface,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: AppColors.background,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceLight,
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
    fillColor: AppColors.surfaceLight,
    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
      borderSide: BorderSide(color: AppColors.surfaceBorder, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    hintStyle: TextStyle(color: AppColors.textMuted),
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
    color: AppColors.surfaceCard,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      side: BorderSide(color: AppColors.surfaceBorder, width: 1),
    ),
  ),

  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    dragHandleColor: AppColors.textMuted,
    dragHandleSize: const Size(40, 4),
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.lg),
    ),
  ),

  dividerColor: AppColors.surfaceBorder,
  iconTheme: const IconThemeData(color: AppColors.textSecondary),
);
