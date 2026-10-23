import 'package:flutter/material.dart';

/// Design tokens from design/DESIGN.md that Material's ColorScheme has no slot for.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surface2,
    required this.track,
    required this.outline,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.income,
    required this.expenseAccent,
    required this.transfer,
    required this.warning,
    required this.danger,
    required this.accentText,
    required this.glowPrimary,
    required this.glowSecondary,
  });

  final Color background;
  final Color surface;
  final Color surface2;
  final Color track;
  final Color outline;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;

  /// Amount colors (never the only signal: amounts always carry a sign).
  final Color income;
  final Color expenseAccent;
  final Color transfer;
  final Color warning;
  final Color danger;

  /// Active tab / links.
  final Color accentText;
  final Color glowPrimary;
  final Color glowSecondary;

  // Brand palette (same in both themes).
  static const ink = Color(0xFF6A5AF9);
  static const inkLight = Color(0xFF8A7CFF);
  static const inkDark = Color(0xFF4636D8);
  static const inkDeep = Color(0xFF24195F);
  static const dollar = Color(0xFF85BB65);
  static const dollarLight = Color(0xFFA6D987);
  static const dollarDark = Color(0xFF5E9C45);
  static const gold = Color(0xFFF2C14E);
  static const coral = Color(0xFFFF8A5B);
  static const ruby = Color(0xFFFF6B7F);
  static const sky = Color(0xFF5CC8FF);
  static const onBright = Color(0xFF0B0D12);

  static const dark = AppColors(
    background: Color(0xFF0B0D12),
    surface: Color(0xFF141821),
    surface2: Color(0xFF1B2030),
    track: Color(0xFF232938),
    outline: Color(0xFF232938),
    divider: Color(0xFF1F2432),
    textPrimary: Color(0xFFEEF1F6),
    textSecondary: Color(0xFF98A1B3),
    income: Color(0xFFA8D98A),
    expenseAccent: Color(0xFFFFA37E),
    transfer: Color(0xFFC3BBFF),
    warning: Color(0xFFF2C14E),
    danger: Color(0xFFFF8E9D),
    accentText: Color(0xFFB4AAFF),
    glowPrimary: Color(0x476A5AF9),
    glowSecondary: Color(0x2485BB65),
  );

  static const light = AppColors(
    background: Color(0xFFF4F5F1),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFECEEE8),
    track: Color(0xFFECEEE8),
    outline: Color(0xFFE4E7E0),
    divider: Color(0xFFEEF0EA),
    textPrimary: Color(0xFF12151C),
    textSecondary: Color(0xFF5B6474),
    income: Color(0xFF3E7A2A),
    expenseAccent: Color(0xFFC2521F),
    transfer: Color(0xFF4A3AD6),
    warning: Color(0xFF9A6B00),
    danger: Color(0xFFC53048),
    accentText: Color(0xFF4A3AD6),
    glowPrimary: Color(0x246A5AF9),
    glowSecondary: Color(0x1F85BB65),
  );

  static AppColors of(BuildContext context) => Theme.of(context).extension<AppColors>()!;

  /// Category tile background: the color at ~14% alpha.
  static Color tile(Color color) => color.withValues(alpha: 0.14);

  static Color parse(String? hex, {Color fallback = const Color(0xFF98A1B3)}) {
    if (hex == null || !hex.startsWith('#')) return fallback;
    final value = int.tryParse(hex.substring(1), radix: 16);
    if (value == null) return fallback;
    return hex.length == 7 ? Color(0xFF000000 | value) : Color(((value & 0xFF) << 24) | (value >> 8));
  }

  static const heroGradient = LinearGradient(
    begin: Alignment(-0.77, -0.64),
    end: Alignment(0.77, 0.64),
    colors: [ink, inkDark, inkDeep],
    stops: [0, 0.48, 1],
  );

  static const fabGradient = LinearGradient(
    begin: Alignment(-0.77, -0.64),
    end: Alignment(0.77, 0.64),
    colors: [dollarLight, dollar, Color(0xFF4E9A3A)],
    stops: [0, 0.45, 1],
  );

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [inkLight, ink, inkDark],
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) => t < 0.5 ? this : (other ?? this);
}
