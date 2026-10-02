import 'package:flutter/material.dart';

/// Tokens de color base del ecosistema Joss.
class JossColors {
  JossColors._();

  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5140D8);
  static const Color accent = Color(0xFFE94560);
  static const Color backgroundDark = Color(0xFF10131E);
  static const Color surfaceDark = Color(0xFF1B1F33);
  static const Color cardDark = Color(0xFF222842);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Colors.white70;
  static const Color textMutedDark = Colors.white38;

  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFFF7675);
}

/// Contrato y tema visual adaptable para cualquier aplicación del ecosistema Joss.
class JossTheme {
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final BorderRadius borderRadius;

  const JossTheme({
    this.primaryColor = JossColors.primary,
    this.accentColor = JossColors.accent,
    this.backgroundColor = JossColors.backgroundDark,
    this.surfaceColor = JossColors.surfaceDark,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  /// ThemeData para aplicaciones con modo oscuro unificado.
  ThemeData toThemeData() {
    final colorScheme = ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        color: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: primaryColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: JossColors.error.withValues(alpha: 0.8), width: 1.5),
        ),
      ),
    );
  }
}
