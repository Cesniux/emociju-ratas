import 'package:flutter/material.dart';

/// Warm paper-and-ink neutrals (design/SYSTEM.md). Colour belongs to
/// feelings; the interface itself uses only these.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.sunken,
    required this.ink,
    required this.inkMuted,
    required this.outline,
  });

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color sunken;
  final Color ink;
  final Color inkMuted;
  final Color outline;

  static const light = AppColors(
    brightness: Brightness.light,
    background: Color(0xFFFAF6F0),
    surface: Color(0xFFFFFDF9),
    sunken: Color(0xFFF2ECE3),
    ink: Color(0xFF2B2724),
    inkMuted: Color(0xFF5E5650),
    outline: Color(0xFFDDD3C7),
  );

  /// Evening blue, like the sky a while after sunset: dark enough to rest
  /// the eyes, never black. Ink is a soft moonlight white, not pure white.
  static const dark = AppColors(
    brightness: Brightness.dark,
    background: Color(0xFF202A3D),
    surface: Color(0xFF293449),
    sunken: Color(0xFF333F54),
    ink: Color(0xFFECE9E2),
    inkMuted: Color(0xFFB7BECA),
    outline: Color(0xFF485469),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  /// Every text-on-background pair the interface uses (contrast-tested).
  List<(String, Color, Color)> get textPairs => [
    ('ink on background', ink, background),
    ('ink on surface', ink, surface),
    ('ink on sunken', ink, sunken),
    ('muted on background', inkMuted, background),
    ('muted on surface', inkMuted, surface),
    ('muted on sunken', inkMuted, sunken),
    ('surface on ink (filled button)', surface, ink),
    ('background on ink (snack bar)', background, ink),
  ];

  @override
  AppColors copyWith({
    Brightness? brightness,
    Color? background,
    Color? surface,
    Color? sunken,
    Color? ink,
    Color? inkMuted,
    Color? outline,
  }) => AppColors(
    brightness: brightness ?? this.brightness,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    sunken: sunken ?? this.sunken,
    ink: ink ?? this.ink,
    inkMuted: inkMuted ?? this.inkMuted,
    outline: outline ?? this.outline,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      sunken: Color.lerp(sunken, other.sunken, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
    );
  }
}
