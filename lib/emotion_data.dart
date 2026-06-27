import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Outer-ring (tertiary) emotion — a leaf node of the wheel.
class TertiaryEmotion {
  const TertiaryEmotion(this.label);

  final String label;
}

/// Middle-ring (secondary) emotion together with its tertiary children.
class SecondaryEmotion {
  const SecondaryEmotion(this.label, this.children);

  final String label;
  final List<TertiaryEmotion> children;

  /// Number of outer-ring slots this branch occupies.
  int get leafCount => children.isEmpty ? 1 : children.length;
}

/// Inner-ring (core) emotion with its secondary children and base colour.
class CoreEmotion {
  const CoreEmotion({
    required this.label,
    required this.color,
    required this.children,
  });

  final String label;
  final Color color;
  final List<SecondaryEmotion> children;

  /// Total number of outer-ring slots under this core, used to size its wedge.
  int get leafCount =>
      children.fold(0, (sum, child) => sum + child.leafCount);
}

/// A radial band expressed as fractions (0..1) of the wheel's outer radius.
typedef RadialBand = ({double inner, double outer});

/// A single segment positioned and ready to be painted.
class WheelSegment {
  const WheelSegment({
    required this.label,
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
    required this.band,
    required this.ring,
    required this.shadeT,
    required this.coreMidAngle,
  });

  final String label;
  final Color color;
  final double startAngle;
  final double sweepAngle;
  final RadialBand band;

  /// 0 = core, 1 = secondary, 2 = tertiary.
  final int ring;

  /// Mid-angle of the parent core wedge. Used to flip labels consistently
  /// across a whole section (so a section straddling the top/bottom doesn't get
  /// its tiles pointing in opposite directions).
  final double coreMidAngle;

  /// 0..1 position within the core, used for the watercolour lightness wobble.
  final double shadeT;
}

/// Pre-computed layout for the whole wheel.
///
/// Every ring shares the same angular boundaries because all angles are derived
/// from a single leaf-count cursor walked depth-first — a core wedge, its
/// secondaries and their tertiaries always line up.
class WheelLayout {
  const WheelLayout(this.segments, this.holeRadiusFraction);

  final List<WheelSegment> segments;
  final double holeRadiusFraction;

  /// Builds the layout from [cores].
  ///
  /// [ringStops] are fractions of the outer radius:
  /// `[hole edge, core|secondary, secondary|tertiary, rim]`.
  static WheelLayout build(
    List<CoreEmotion> cores, {
    List<double> ringStops = const [0.15, 0.40, 0.64, 1.0],
  }) {
    final totalLeaves = cores.fold(0, (sum, core) => sum + core.leafCount);
    final fullCircle = 2 * math.pi;

    // Centre the first core on the top of the wheel.
    final firstCoreSweep = fullCircle * cores.first.leafCount / totalLeaves;
    var coreCursor = -math.pi / 2 - firstCoreSweep / 2;

    final segments = <WheelSegment>[];
    for (final core in cores) {
      final coreSweep = fullCircle * core.leafCount / totalLeaves;
      final coreMid = coreCursor + coreSweep / 2;
      segments.add(
        WheelSegment(
          label: core.label,
          color: core.color,
          startAngle: coreCursor,
          sweepAngle: coreSweep,
          band: (inner: ringStops[0], outer: ringStops[1]),
          ring: 0,
          shadeT: 0.5,
          coreMidAngle: coreMid,
        ),
      );

      var leafIndex = 0;
      var secCursor = coreCursor;
      for (final secondary in core.children) {
        final secSweep = fullCircle * secondary.leafCount / totalLeaves;
        segments.add(
          WheelSegment(
            label: secondary.label,
            color: core.color,
            startAngle: secCursor,
            sweepAngle: secSweep,
            band: (inner: ringStops[1], outer: ringStops[2]),
            ring: 1,
            shadeT: 0.5,
            coreMidAngle: coreMid,
          ),
        );

        var leafCursor = secCursor;
        final leaves = secondary.children.isEmpty
            ? const [TertiaryEmotion('')]
            : secondary.children;
        for (final leaf in leaves) {
          final leafSweep = fullCircle / totalLeaves;
          segments.add(
            WheelSegment(
              label: leaf.label,
              color: core.color,
              startAngle: leafCursor,
              sweepAngle: leafSweep,
              band: (inner: ringStops[2], outer: ringStops[3]),
              ring: 2,
              shadeT: core.leafCount <= 1
                  ? 0.5
                  : leafIndex / (core.leafCount - 1),
              coreMidAngle: coreMid,
            ),
          );
          leafCursor += leafSweep;
          leafIndex++;
        }
        secCursor += secSweep;
      }
      coreCursor += coreSweep;
    }

    return WheelLayout(segments, ringStops[0]);
  }
}

/// The Lithuanian "Emocijų ratas" content, ordered clockwise from the top.
///
/// Structure follows the well-known Geoffrey Roberts feelings-wheel layout,
/// adapted to six cores (the "bad" branch is folded into LIŪDESYS). Words are
/// transcribed from the reference image — edit any label here and the wheel
/// re-lays-out automatically.
const List<CoreEmotion> emotionWheelData = [
  CoreEmotion(
    label: 'NUOSTABA',
    color: Color(0xFFE8CD7E),
    children: [
      SecondaryEmotion('NUSTEBĘS', [
        TertiaryEmotion('ŠOKIRUOTAS'),
        TertiaryEmotion('NEMALONIAI NUSTEBĘS'),
      ]),
      SecondaryEmotion('SUGLUMĘS', [
        TertiaryEmotion('SUTRIKĘS'),
        TertiaryEmotion('NUSIVYLĘS'),
      ]),
      SecondaryEmotion('APSTULBĘS', [
        TertiaryEmotion('SUSIŽAVĖJĘS'),
        TertiaryEmotion('NUSTEBINTAS'),
      ]),
    ],
  ),
  CoreEmotion(
    label: 'DŽIAUGSMAS',
    color: Color(0xFFCBA94B),
    children: [
      SecondaryEmotion('OPTIMISTIŠKAS', [
        TertiaryEmotion('VILTINGAS'),
        TertiaryEmotion('ĮKVĖPTAS'),
      ]),
      SecondaryEmotion('PASITIKINTIS', [
        TertiaryEmotion('ARTIMAS'),
        TertiaryEmotion('JAUTRUS'),
      ]),
      SecondaryEmotion('RAMUS', [
        TertiaryEmotion('DĖKINGAS'),
        TertiaryEmotion('MYLINTIS'),
      ]),
      SecondaryEmotion('GALINGAS', [
        TertiaryEmotion('KŪRYBINGAS'),
        TertiaryEmotion('DRĄSUS'),
      ]),
      SecondaryEmotion('PRIIMTAS', [
        TertiaryEmotion('VERTINAMAS'),
        TertiaryEmotion('GERBIAMAS'),
      ]),
      SecondaryEmotion('PASIDIDŽIAVIMAS', [
        TertiaryEmotion('UŽTIKRINTAS'),
        TertiaryEmotion('SĖKMINGAS'),
      ]),
      SecondaryEmotion('SUSIDOMĘS', [
        TertiaryEmotion('ŽINGEIDUS'),
        TertiaryEmotion('SMALSUS'),
      ]),
      SecondaryEmotion('PATENKINTAS', [
        TertiaryEmotion('DŽIUGUS'),
        TertiaryEmotion('LAISVAS'),
      ]),
      SecondaryEmotion('ŽAISMINGAS', [
        TertiaryEmotion('ŠELMIŠKAS'),
        TertiaryEmotion('SUSIJAUDINĘS'),
      ]),
    ],
  ),
  CoreEmotion(
    label: 'LIŪDESYS',
    color: Color(0xFF8295A0),
    children: [
      SecondaryEmotion('NUOBODUS', [
        TertiaryEmotion('APATIŠKAS'),
        TertiaryEmotion('ABEJINGAS'),
      ]),
      SecondaryEmotion('APKRAUTAS', [
        TertiaryEmotion('SKUBINAMAS'),
        TertiaryEmotion('SPAUDŽIAMAS'),
      ]),
      SecondaryEmotion('STRESUOJANTIS', [
        TertiaryEmotion('NEKONTROLIUOJAMAS'),
        TertiaryEmotion('PRIBLOKŠTAS'),
      ]),
      SecondaryEmotion('PAVARGĘS', [
        TertiaryEmotion('IŠSIBLAŠKĘS'),
        TertiaryEmotion('MIEGUISTAS'),
      ]),
      SecondaryEmotion('ĮSKAUDINTAS', [
        TertiaryEmotion('NUSIVYLĘS'),
        TertiaryEmotion('SUGĖDINTAS'),
      ]),
      SecondaryEmotion('DEPRESIŠKAS', [
        TertiaryEmotion('TUŠČIAS'),
        TertiaryEmotion('MENKAVERTIS'),
      ]),
      SecondaryEmotion('KALTAS', [
        TertiaryEmotion('GĖDIJANTIS'),
        TertiaryEmotion('BESIGAILINTIS'),
      ]),
      SecondaryEmotion('BEVILTIŠKA', [
        TertiaryEmotion('SIELVARTAUJANTIS'),
        TertiaryEmotion('BEJĖGIS'),
      ]),
      SecondaryEmotion('PAŽEIDŽIAMAS', [
        TertiaryEmotion('SILPNAS'),
        TertiaryEmotion('TRAPUS'),
      ]),
      SecondaryEmotion('VIENIŠAS', [
        TertiaryEmotion('IZOLIUOTAS'),
        TertiaryEmotion('APLEISTAS'),
      ]),
    ],
  ),
  CoreEmotion(
    label: 'PASIBJAURĖJIMAS',
    color: Color(0xFFA07E8C),
    children: [
      SecondaryEmotion('NEPRITARIANTIS', [
        TertiaryEmotion('PASMERKIANTIS'),
        TertiaryEmotion('SUGĖDINTAS'),
      ]),
      SecondaryEmotion('NUSIVYLĘS', [
        TertiaryEmotion('PASIBAISĖJĘS'),
        TertiaryEmotion('PASIBJAURĖJĘS'),
      ]),
      SecondaryEmotion('BJAURUS', [
        TertiaryEmotion('ŠLYKŠTUS'),
        TertiaryEmotion('NEKENČIANTIS'),
      ]),
      SecondaryEmotion('VENGIANTIS', [
        TertiaryEmotion('SIAUBINGAS'),
        TertiaryEmotion('ABEJOJANTIS'),
      ]),
    ],
  ),
  CoreEmotion(
    label: 'PYKTIS',
    color: Color(0xFFBE6A4F),
    children: [
      SecondaryEmotion('NUVILTAS', [
        TertiaryEmotion('IŠDUOTAS'),
        TertiaryEmotion('ĮSIŽEIDĘS'),
      ]),
      SecondaryEmotion('PAŽEMINTAS', [
        TertiaryEmotion('NEGERBIAMAS'),
        TertiaryEmotion('IŠJUOKTAS'),
      ]),
      SecondaryEmotion('KANDUS', [
        TertiaryEmotion('PASIPIKTINĘS'),
        TertiaryEmotion('PAŽEISTAS'),
      ]),
      SecondaryEmotion('ĮNIRŠĘS', [
        TertiaryEmotion('ĮSIUTĘS'),
        TertiaryEmotion('PAVYDUS'),
      ]),
      SecondaryEmotion('AGRESYVUS', [
        TertiaryEmotion('PROVOKUOJANTIS'),
        TertiaryEmotion('PRIEŠIŠKAS'),
      ]),
      SecondaryEmotion('FRUSTRUOTAS', [
        TertiaryEmotion('SUERZINTAS'),
        TertiaryEmotion('SUDIRGĘS'),
      ]),
      SecondaryEmotion('NUTOLĘS', [
        TertiaryEmotion('ATSIRIBOJĘS'),
        TertiaryEmotion('ABEJINGAS'),
      ]),
      SecondaryEmotion('KRITIŠKAS', [
        TertiaryEmotion('SKEPTIŠKAS'),
        TertiaryEmotion('ATMETANTIS'),
      ]),
    ],
  ),
  CoreEmotion(
    label: 'BAIMĖ',
    color: Color(0xFFDFA05C),
    children: [
      SecondaryEmotion('IŠSIGANDĘS', [
        TertiaryEmotion('BEJĖGIS'),
        TertiaryEmotion('IŠGĄSDINTAS'),
      ]),
      SecondaryEmotion('NERAMUS', [
        TertiaryEmotion('PRIBLOKŠTAS'),
        TertiaryEmotion('SUSIRŪPINĘS'),
      ]),
      SecondaryEmotion('NESAUGUS', [
        TertiaryEmotion('NETINKAMAS'),
        TertiaryEmotion('NEPILNAVERTIS'),
      ]),
      SecondaryEmotion('NERYŽTINGAS', [
        TertiaryEmotion('BEVERTIS'),
        TertiaryEmotion('NESVARBUS'),
      ]),
      SecondaryEmotion('ATSTUMTAS', [
        TertiaryEmotion('IŠSKIRTAS'),
        TertiaryEmotion('PERSEKIOJAMAS'),
      ]),
      SecondaryEmotion('GRĖSMINGAS', [
        TertiaryEmotion('NERVINGAS'),
        TertiaryEmotion('PAŽEIDŽIAMAS'),
      ]),
    ],
  ),
];
