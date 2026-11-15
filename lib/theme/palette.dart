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

/// Calm feeling tints (design/SYSTEM.md). Ink on every tint is ≥ 5.4:1;
/// `test/theme/contrast_test.dart` guards it.
abstract final class Palette {
  static const Map<FamilyHue, HueTints> light = {
    FamilyHue.yellow: HueTints(Color(0xFFE6C35C), Color(0xFFF0D891), Color(0xFFF8EBC4)),
    FamilyHue.olive: HueTints(Color(0xFFB7BC6A), Color(0xFFD2D59C), Color(0xFFE8EAC8)),
    FamilyHue.blue: HueTints(Color(0xFF93ACD3), Color(0xFFB9CAE5), Color(0xFFDCE5F2)),
    FamilyHue.mauve: HueTints(Color(0xFFB89FCB), Color(0xFFD3C2DF), Color(0xFFE9DFF0)),
    FamilyHue.clay: HueTints(Color(0xFFDC8D78), Color(0xFFEAB1A2), Color(0xFFF5D6CD)),
    FamilyHue.orange: HueTints(Color(0xFFE9A86A), Color(0xFFF2C69A), Color(0xFFF9E2CA)),
    FamilyHue.sage: HueTints(Color(0xFFA9C78A), Color(0xFFC8DCB2), Color(0xFFE3EDD6)),
    FamilyHue.green: HueTints(Color(0xFF7FB59A), Color(0xFFAFD0BD), Color(0xFFD7E9DE)),
    FamilyHue.sky: HueTints(Color(0xFF8CC3D2), Color(0xFFB5D9E2), Color(0xFFDAEDF1)),
    FamilyHue.rose: HueTints(Color(0xFFE3A0AF), Color(0xFFEEC2CB), Color(0xFFF7E2E6)),
  };

  static const Map<FamilyHue, HueTints> dark = {
    FamilyHue.yellow: HueTints(Color(0xFF6E5A1E), Color(0xFF574A22), Color(0xFF3F3824)),
    FamilyHue.olive: HueTints(Color(0xFF5A5E26), Color(0xFF484B26), Color(0xFF363824)),
    FamilyHue.blue: HueTints(Color(0xFF3D5680), Color(0xFF334563), Color(0xFF2A3447)),
    FamilyHue.mauve: HueTints(Color(0xFF5E4775), Color(0xFF4A3B5B), Color(0xFF382F42)),
    FamilyHue.clay: HueTints(Color(0xFF7E3F31), Color(0xFF613A31), Color(0xFF46302B)),
    FamilyHue.orange: HueTints(Color(0xFF7A4A1F), Color(0xFF5F4026), Color(0xFF453326)),
    FamilyHue.sage: HueTints(Color(0xFF4B6634), Color(0xFF3E5230), Color(0xFF313D29)),
    FamilyHue.green: HueTints(Color(0xFF2F6149), Color(0xFF2B4E3D), Color(0xFF253C31)),
    FamilyHue.sky: HueTints(Color(0xFF2F5F6E), Color(0xFF2B4D58), Color(0xFF253B43)),
    FamilyHue.rose: HueTints(Color(0xFF7A3D4C), Color(0xFF5F3540), Color(0xFF452B32)),
  };

  static HueTints tints(FamilyHue hue, Brightness brightness) =>
      (brightness == Brightness.dark ? dark : light)[hue]!;

  static Color fill(FamilyHue hue, Tier tier, Brightness brightness) =>
      tints(hue, brightness).of(tier);
}
