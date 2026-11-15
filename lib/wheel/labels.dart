import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart' show StringCharacters;

import '../theme/typography.dart';
import 'geometry.dart';

/// "liūdesys" → "Liūdesys".
String sentenceCase(String text) => text.isEmpty
    ? text
    : text.characters.first.toUpperCase() + text.characters.skip(1).string;

TextStyle wheelLabelStyle(
  Color color,
  double size, {
  FontWeight weight = FontWeight.w500,
}) => TextStyle(
  fontFamily: Fonts.body,
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: 1.15,
  letterSpacing: 0,
);

TextPainter layoutText(String text, TextStyle style) => TextPainter(
  text: TextSpan(text: text, style: style),
  textDirection: TextDirection.ltr,
  maxLines: 1,
)..layout();

/// Width and line height of [text] at font size 100, for linear scaling.
({double width, double height}) measure100(String text, TextStyle base) {
  final p = layoutText(text, base.copyWith(fontSize: 100));
  final r = (width: p.width, height: p.preferredLineHeight);
  p.dispose();
  return r;
}

const _vowels = 'aąeęėiįyouųū';

/// Two-consonant starts a Lithuanian syllable can have (smagu, stalas,
/// bloga…); "dž" and "ch" are one sound and stay together.
const _onsets = {
  'st',
  'sk',
  'sp',
  'sm',
  'sn',
  'sl',
  'sv',
  'šk',
  'šl',
  'šm',
  'šn',
  'šp',
  'št',
  'šv',
  'žl',
  'žm',
  'žv',
  'bl',
  'br',
  'dr',
  'gl',
  'gr',
  'kl',
  'kr',
  'kv',
  'pl',
  'pr',
  'tr',
  'tv',
  'dv',
  'gv',
  'zv',
  'dž',
  'ch',
  'fl',
  'fr',
};

/// Splits a Lithuanian word in two at a syllable boundary near its middle
/// (pa-sib-jau-rė-ji-mas → "Pasibjau-" + "rėjimas"). Null for short words.
(String, String)? splitSyllables(String word) {
  final chars = word.characters.toList();
  if (chars.length < 7) return null;
  bool isVowel(int i) => _vowels.contains(chars[i].toLowerCase());
  final groups = <(int, int)>[];
  for (var i = 0; i < chars.length;) {
    if (isVowel(i)) {
      var j = i;
      while (j < chars.length && isVowel(j)) {
        j++;
      }
      groups.add((i, j));
      i = j;
    } else {
      i++;
    }
  }
  final boundaries = <int>[];
  for (var g = 0; g + 1 < groups.length; g++) {
    final from = groups[g].$2;
    final to = groups[g + 1].$1;
    final k = to - from;
    if (k <= 0) continue;
    final lastTwo = k >= 2
        ? '${chars[to - 2]}${chars[to - 1]}'.toLowerCase()
        : '';
    boundaries.add(_onsets.contains(lastTwo) ? to - 2 : to - 1);
  }
  boundaries.removeWhere((b) => b < 3 || chars.length - b < 3);
  if (boundaries.isEmpty) return null;
  final mid = chars.length / 2;
  boundaries.sort((a, b) => (a - mid).abs().compareTo((b - mid).abs()));
  final at = boundaries.first;
  return ('${chars.take(at).join()}-', chars.skip(at).join());
}

/// A horizontal or rotated label, one or two lines, laid out once.
class PlacedLabel {
  PlacedLabel({
    required this.lines,
    required this.anchor,
    required this.rotation,
    required this.fontSize,
  });

  final List<TextPainter> lines;
  final Offset anchor;

  /// Canvas rotation in radians (0 = horizontal).
  final double rotation;
  final double fontSize;

  double get width => lines.fold(0, (w, l) => math.max(w, l.width));
  double get height => lines.fold(0, (h, l) => h + l.height);

  void paint(Canvas canvas) {
    canvas.save();
    canvas.translate(anchor.dx, anchor.dy);
    if (rotation != 0) canvas.rotate(rotation);
    var y = -height / 2;
    for (final l in lines) {
      l.paint(canvas, Offset(-l.width / 2, y));
      y += l.height;
    }
    canvas.restore();
  }

  void dispose() {
    for (final l in lines) {
      l.dispose();
    }
  }
}

/// Text that follows an arc, always reading left to right: on the top half
/// glyph tops point outward, on the bottom half inward.
class ArcLabel {
  ArcLabel._(
    this._glyphs,
    this._advances,
    this.lineRadii,
    this.centerAngle,
    this.bottom,
    this.fontSize,
  );

  final List<List<TextPainter>> _glyphs;
  final List<List<double>> _advances;
  final List<double> lineRadii;
  final double centerAngle;
  final bool bottom;
  final double fontSize;

  /// Lays out [lines] (1 or 2) along a circle around the label's centre
  /// radius [radius] at clock angle [angle].
  factory ArcLabel.layout({
    required List<String> lines,
    required TextStyle style,
    required double radius,
    required double angle,
  }) {
    final a = normalize(angle);
    final bottom = a > math.pi / 2 && a < 3 * math.pi / 2;
    final glyphs = <List<TextPainter>>[];
    final advances = <List<double>>[];
    double lineHeight = 0;
    for (final line in lines) {
      final row = <TextPainter>[];
      final adv = <double>[];
      for (final ch in line.characters) {
        final p = layoutText(ch, style);
        row.add(p);
        adv.add(p.width);
        lineHeight = math.max(lineHeight, p.height);
      }
      glyphs.add(row);
      advances.add(adv);
    }
    final n = lines.length;
    // Line 1 sits visually above line 2: further out on the top half,
    // further in on the bottom half.
    final radii = <double>[
      for (var i = 0; i < n; i++)
        radius +
            (bottom ? -1 : 1) *
                (n == 1 ? 0 : (i == 0 ? 0.5 : -0.5) * lineHeight),
    ];
    return ArcLabel._(glyphs, advances, radii, a, bottom, style.fontSize ?? 14);
  }

  void paint(Canvas canvas, Offset center) {
    for (var li = 0; li < _glyphs.length; li++) {
      final r = lineRadii[li];
      final total = _advances[li].fold<double>(0, (s, w) => s + w);
      var run = -total / 2;
      for (var gi = 0; gi < _glyphs[li].length; gi++) {
        final g = _glyphs[li][gi];
        final w = _advances[li][gi];
        final s = run + w / 2;
        run += w;
        final delta = s / r;
        final theta = bottom ? centerAngle - delta : centerAngle + delta;
        final p = polar(center, theta, r);
        canvas.save();
        canvas.translate(p.dx, p.dy);
        canvas.rotate(bottom ? theta + math.pi : theta);
        g.paint(canvas, Offset(-w / 2, -g.height / 2));
        canvas.restore();
      }
    }
  }

  void dispose() {
    for (final row in _glyphs) {
      for (final g in row) {
        g.dispose();
      }
    }
  }
}
