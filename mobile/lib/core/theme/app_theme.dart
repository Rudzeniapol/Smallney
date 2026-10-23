
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Material 3 themes built from the "Банкнота" design tokens.
abstract final class AppTheme {
  static const body = 'Onest';
  static const display = 'Unbounded';

  static const tabular = [FontFeature.tabularFigures()];

  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData light() => _build(Brightness.light, AppColors.light);

  static ThemeData _build(Brightness brightness, AppColors c) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.ink,
      onPrimary: Colors.white,
      primaryContainer: brightness == Brightness.dark ? AppColors.inkDeep : const Color(0xFFD4CEFF),
      onPrimaryContainer: brightness == Brightness.dark ? const Color(0xFFD4CEFF) : AppColors.inkDeep,
      secondary: AppColors.dollar,
      onSecondary: AppColors.onBright,
      tertiary: AppColors.gold,
      onTertiary: AppColors.onBright,
      error: AppColors.ruby,
      onError: AppColors.onBright,
      surface: c.surface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerHighest: c.surface2,
      outline: c.outline,
      outlineVariant: c.divider,
    );

    TextStyle t(double size, FontWeight weight, {String family = body, double? spacing}) => TextStyle(
          fontFamily: family,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          color: c.textPrimary,
          fontFeatures: tabular,
        );

    final text = TextTheme(
      displayLarge: t(36, FontWeight.w600, family: display, spacing: -0.72),
      headlineMedium: t(26, FontWeight.w600, family: display, spacing: -0.52),
      headlineSmall: t(22, FontWeight.w600, family: display, spacing: -0.44),
      titleLarge: t(18, FontWeight.w600),
      titleMedium: t(16, FontWeight.w600),
      bodyLarge: t(15, FontWeight.w500),
      bodyMedium: t(14, FontWeight.w400),
      bodySmall: t(13, FontWeight.w400).copyWith(color: c.textSecondary),
      labelLarge: t(14, FontWeight.w600),
      labelMedium: t(13, FontWeight.w500),
      labelSmall: t(11, FontWeight.w600),
    );

    final radius16 = BorderRadius.circular(16);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      fontFamily: body,
      textTheme: text,
      extensions: [c],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        foregroundColor: c.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: text.bodyMedium?.copyWith(color: c.textSecondary),
        labelStyle: text.bodySmall,
        border: OutlineInputBorder(borderRadius: radius16, borderSide: BorderSide(color: c.outline)),
        enabledBorder: OutlineInputBorder(borderRadius: radius16, borderSide: BorderSide(color: c.outline)),
        focusedBorder: OutlineInputBorder(borderRadius: radius16, borderSide: const BorderSide(color: AppColors.inkLight)),
        errorBorder: OutlineInputBorder(borderRadius: radius16, borderSide: BorderSide(color: c.danger)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: c.track,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surface2,
        contentTextStyle: text.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: radius16),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : c.textSecondary),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.ink : c.track),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      datePickerTheme: DatePickerThemeData(backgroundColor: c.surface, surfaceTintColor: Colors.transparent),
    );
  }
}
