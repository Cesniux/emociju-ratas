import 'package:flutter/material.dart';

abstract final class Fonts {
  /// Nunito: one soft, rounded family for every word in the app, from the
  /// smallest word on the wheel to the page titles.
  static const body = 'Nunito';
  static const heading = 'Nunito';

  /// Height of Nunito's capital letters, in em. Wheel words are capitals, so
  /// they are centred on this band rather than on the whole line box.
  static const capHeight = 0.71;
}

/// Type scale (design/SYSTEM.md). Reading text 17/1.5, sentence case.
TextTheme buildTextTheme({required Color ink, required Color muted}) {
  TextStyle heading(double size, double height) => TextStyle(
    fontFamily: Fonts.heading,
    fontSize: size,
    height: height,
    fontWeight: FontWeight.w800,
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
    displaySmall: heading(27, 1.2),
    headlineSmall: heading(25, 1.2),
    titleLarge: heading(23, 1.25),
    titleMedium: heading(19, 1.3),
    titleSmall: body(16.5, 1.3, weight: FontWeight.w700),
    bodyLarge: body(17, 1.5),
    bodyMedium: body(16, 1.45),
    bodySmall: body(14, 1.4, color: muted),
    labelLarge: body(16, 1.25, weight: FontWeight.w700),
    labelMedium: body(14, 1.25, weight: FontWeight.w600),
    labelSmall: body(12.5, 1.25, weight: FontWeight.w600, color: muted),
  );
}
