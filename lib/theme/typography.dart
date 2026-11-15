import 'package:flutter/material.dart';

abstract final class Fonts {
  /// Atkinson Hyperlegible Next: look-alike letters are drawn apart.
  static const body = 'Atkinson';

  /// Lora: a calm, warm serif for titles.
  static const heading = 'Lora';
}

/// Type scale (design/SYSTEM.md). Reading text 17/1.5, sentence case.
TextTheme buildTextTheme({required Color ink, required Color muted}) {
  TextStyle heading(double size, double height) => TextStyle(
    fontFamily: Fonts.heading,
    fontSize: size,
    height: height,
    fontWeight: FontWeight.w600,
    color: ink,
    letterSpacing: 0,
  );
  TextStyle body(
    double size,
    double height, {
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) => TextStyle(
    fontFamily: Fonts.body,
    fontSize: size,
    height: height,
    fontWeight: weight,
    color: color ?? ink,
    letterSpacing: 0,
  );

  return TextTheme(
    displaySmall: heading(26, 1.25),
    headlineSmall: heading(24, 1.25),
    titleLarge: heading(22, 1.3),
    titleMedium: heading(19, 1.3),
    titleSmall: body(16, 1.3, weight: FontWeight.w600),
    bodyLarge: body(17, 1.5),
    bodyMedium: body(16, 1.45),
    bodySmall: body(14, 1.4, color: muted),
    labelLarge: body(16, 1.25, weight: FontWeight.w500),
    labelMedium: body(14, 1.25, weight: FontWeight.w500),
    labelSmall: body(12.5, 1.25, weight: FontWeight.w500, color: muted),
  );
}
