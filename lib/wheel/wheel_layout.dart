import 'package:flutter/painting.dart';
import 'package:flutter/services.dart' show Brightness;

import '../data/models.dart';
import '../theme/colors.dart';
import 'circumplex_layout.dart';
import 'petal_layout.dart';
import 'sunburst_layout.dart';

/// What a tap on the wheel landed on.
sealed class WheelHit {
  const WheelHit(this.familyId, {this.feelingId});

  final String familyId;

  /// The tapped word, if the tap landed on one. Tapping a word chooses it.
  final String? feelingId;
}

final class SunburstHit extends WheelHit {
  const SunburstHit(super.familyId, {super.feelingId});
}

final class PetalHit extends WheelHit {
  const PetalHit(super.familyId, {required this.petal, super.feelingId});

  final int petal;
}

final class DyadHit extends WheelHit {
  const DyadHit(
    super.familyId, {
    required this.dyad,
    required String super.feelingId,
  });

  final int dyad;
}

final class CircumplexHit extends WheelHit {
  const CircumplexHit(
    super.familyId, {
    required this.valence,
    required this.arousal,
    required this.position,
    super.feelingId,
  });

  /// −1 (unpleasant) … +1 (pleasant).
  final double valence;

  /// −1 (low energy) … +1 (high energy).
  final double arousal;

  /// Tap position in wheel coordinates (for the probe dot).
  final Offset position;
}

/// One screen-reader node on the painted wheel.
class SemanticTarget {
  const SemanticTarget({
    required this.rect,
    required this.label,
    required this.familyId,
    required this.hit,
    required this.order,
  });

  /// At least 48 × 48, centred on the visible label.
  final Rect rect;

  /// The word this target chooses.
  String get feelingId => hit.feelingId!;
  final String label;
  final String familyId;
  final WheelHit hit;
  final int order;
}

/// Every word is drawn at every zoom, even when it is small, so people can
/// see there is more to find and pinch to read it. Only thumbnails
/// (zoomStep 0) stay colour only.
abstract final class LabelMin {
  static const double core = 13;
  static const double word = 10;

  static bool visible(double fontSize, double min, double zoomStep) =>
      fontSize > 0 && zoomStep > 0;
}

/// Geometry, labels and hit testing for one wheel at one size. Built once
/// per (wheel, size, word form, theme); painters only draw it.
abstract class WheelLayout {
  WheelLayout({required this.side, required this.colors, required this.form});

  final double side;
  final AppColors colors;
  final WordForm form;

  Offset get center => Offset(side / 2, side / 2);
  double get radius => side / 2 - 1;
  Brightness get brightness => colors.brightness;

  WheelModel get wheel;

  /// Paints segments and every label readable at [zoomStep].
  void paintBase(Canvas canvas, double zoomStep);

  WheelHit? hitTest(Offset p);

  List<SemanticTarget> get semanticTargets;

  /// The family's thumbnail-free colour sample (wheel menu).
  void dispose();

  static WheelLayout create(
    WheelModel wheel, {
    required double side,
    required AppColors colors,
    required WordForm form,
    double coreScale = 1,
  }) => switch (wheel) {
    SunburstWheel() => SunburstLayout(
      wheel,
      side: side,
      colors: colors,
      form: form,
      coreScale: coreScale,
    ),
    PetalWheel() => PetalLayout(wheel, side: side, colors: colors, form: form),
    CircumplexWheel() => CircumplexLayout(
      wheel,
      side: side,
      colors: colors,
      form: form,
    ),
  };
}
