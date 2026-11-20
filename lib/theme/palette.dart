import 'package:flutter/painting.dart';
import 'package:flutter/services.dart' show Brightness;

import '../data/models.dart';

/// Wheel tier → tint strength. Core / Plutchik intense = strong,
/// middle / basic = medium, outer / mild = soft.
enum Tier { strong, medium, soft }

final class HueTints {
  const HueTints(this.strong, this.medium, this.soft);

  final Color strong;
  final Color medium;
  final Color soft;

  Color of(Tier tier) => switch (tier) {
    Tier.strong => strong,
    Tier.medium => medium,
    Tier.soft => soft,
  };
}

/// Calm feeling tints (design/SYSTEM.md). Ink on every tint is ≥ 4.5:1;
/// `test/theme/contrast_test.dart` guards it.
abstract final class Palette {
  static const Map<FamilyHue, HueTints> light = {
    FamilyHue.yellow: HueTints(
      Color(0xFFE6C35C),
      Color(0xFFF0D891),
      Color(0xFFF8EBC4),
    ),
    FamilyHue.olive: HueTints(
      Color(0xFFB7BC6A),
      Color(0xFFD2D59C),
      Color(0xFFE8EAC8),
    ),
    FamilyHue.blue: HueTints(
      Color(0xFF93ACD3),
      Color(0xFFB9CAE5),
      Color(0xFFDCE5F2),
    ),
    FamilyHue.mauve: HueTints(
      Color(0xFFB89FCB),
      Color(0xFFD3C2DF),
      Color(0xFFE9DFF0),
    ),
    FamilyHue.clay: HueTints(
      Color(0xFFDC8D78),
      Color(0xFFEAB1A2),
      Color(0xFFF5D6CD),
    ),
    FamilyHue.orange: HueTints(
      Color(0xFFE9A86A),
      Color(0xFFF2C69A),
      Color(0xFFF9E2CA),
    ),
    FamilyHue.sage: HueTints(
      Color(0xFFA9C78A),
      Color(0xFFC8DCB2),
      Color(0xFFE3EDD6),
    ),
    FamilyHue.green: HueTints(
      Color(0xFF7FB59A),
      Color(0xFFAFD0BD),
      Color(0xFFD7E9DE),
    ),
    FamilyHue.sky: HueTints(
      Color(0xFF8CC3D2),
      Color(0xFFB5D9E2),
      Color(0xFFDAEDF1),
    ),
    FamilyHue.rose: HueTints(
      Color(0xFFE3A0AF),
      Color(0xFFEEC2CB),
      Color(0xFFF7E2E6),
    ),
  };

  /// Dusk versions of the same hues (same hue angle, lower lightness and
  /// chroma in OKLCH), so the wheel rests softly on the evening blue.
  static const Map<FamilyHue, HueTints> dark = {
    FamilyHue.yellow: HueTints(
      Color(0xFF79621A),
      Color(0xFF635220),
      Color(0xFF4F4320),
    ),
    FamilyHue.olive: HueTints(
      Color(0xFF666933),
      Color(0xFF55572F),
      Color(0xFF44462A),
    ),
    FamilyHue.blue: HueTints(
      Color(0xFF55667F),
      Color(0xFF485568),
      Color(0xFF3B4452),
    ),
    FamilyHue.mauve: HueTints(
      Color(0xFF6D5D7A),
      Color(0xFF5A4E64),
      Color(0xFF48404F),
    ),
    FamilyHue.clay: HueTints(
      Color(0xFF895547),
      Color(0xFF70483E),
      Color(0xFF583C34),
    ),
    FamilyHue.orange: HueTints(
      Color(0xFF845A31),
      Color(0xFF6C4C2E),
      Color(0xFF553E29),
    ),
    FamilyHue.sage: HueTints(
      Color(0xFF596C45),
      Color(0xFF4B5A3C),
      Color(0xFF3D4833),
    ),
    FamilyHue.green: HueTints(
      Color(0xFF4A6E5C),
      Color(0xFF405B4D),
      Color(0xFF36493F),
    ),
    FamilyHue.sky: HueTints(
      Color(0xFF476B75),
      Color(0xFF3E5960),
      Color(0xFF34474D),
    ),
    FamilyHue.rose: HueTints(
      Color(0xFF825760),
      Color(0xFF6A4951),
      Color(0xFF543C41),
    ),
  };

  static HueTints tints(FamilyHue hue, Brightness brightness) =>
      (brightness == Brightness.dark ? dark : light)[hue]!;

  static Color fill(FamilyHue hue, Tier tier, Brightness brightness) =>
      tints(hue, brightness).of(tier);
}
