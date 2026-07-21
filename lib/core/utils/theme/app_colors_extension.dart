import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color textBody;
  final Color border;
  final Color borderSubtle;
  final Color fieldBg;
  final Color tagBg;
  final Color shimmer;
  final Color iconBg;
  final Color navBarBg;
  final Color shadow;

  const AppColorsExtension({
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.textBody,
    required this.border,
    required this.borderSubtle,
    required this.fieldBg,
    required this.tagBg,
    required this.shimmer,
    required this.iconBg,
    required this.navBarBg,
    required this.shadow,
  });

  static const light = AppColorsExtension(
    cardBg: Colors.white,
    textPrimary: Color(0xFF111418),
    textSecondary: Color(0xFF6B7280),
    textHint: Color(0xFF9CA3AF),
    textBody: Color(0xFF334155),
    border: Color(0xFFE5E7EB),
    borderSubtle: Color(0xFFDBE0E6),
    fieldBg: Colors.white,
    tagBg: Color(0xFFF1F5F9),
    shimmer: Color(0xFFE5E7EB),
    iconBg: Color(0xFFF6F7F8),
    navBarBg: Colors.white,
    shadow: Color(0x0F000000),
  );

  static const dark = AppColorsExtension(
    cardBg: Color(0xFF1E1E1E),
    textPrimary: Color(0xFFE2E8F0),
    textSecondary: Color(0xFF9CA3AF),
    textHint: Color(0xFF6B7280),
    textBody: Color(0xFFCBD5E1),
    border: Color(0xFF374151),
    borderSubtle: Color(0xFF2D3748),
    fieldBg: Color(0xFF1E1E1E),
    tagBg: Color(0xFF2D3748),
    shimmer: Color(0xFF374151),
    iconBg: Color(0xFF1A2332),
    navBarBg: Color(0xFF1E1E1E),
    shadow: Color(0x33000000),
  );

  @override
  AppColorsExtension copyWith({
    Color? cardBg, Color? textPrimary, Color? textSecondary,
    Color? textHint, Color? textBody, Color? border,
    Color? borderSubtle, Color? fieldBg, Color? tagBg,
    Color? shimmer, Color? iconBg, Color? navBarBg, Color? shadow,
  }) {
    return AppColorsExtension(
      cardBg: cardBg ?? this.cardBg,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      textBody: textBody ?? this.textBody,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      fieldBg: fieldBg ?? this.fieldBg,
      tagBg: tagBg ?? this.tagBg,
      shimmer: shimmer ?? this.shimmer,
      iconBg: iconBg ?? this.iconBg,
      navBarBg: navBarBg ?? this.navBarBg,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColorsExtension lerp(covariant ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      textBody: Color.lerp(textBody, other.textBody, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      fieldBg: Color.lerp(fieldBg, other.fieldBg, t)!,
      tagBg: Color.lerp(tagBg, other.tagBg, t)!,
      shimmer: Color.lerp(shimmer, other.shimmer, t)!,
      iconBg: Color.lerp(iconBg, other.iconBg, t)!,
      navBarBg: Color.lerp(navBarBg, other.navBarBg, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
