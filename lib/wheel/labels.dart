import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart' show StringCharacters;

import '../theme/typography.dart';

/// "liūdesys" → "Liūdesys".
String sentenceCase(String text) => text.isEmpty
    ? text
    : text.characters.first.toUpperCase() + text.characters.skip(1).string;

/// Words on the wheel are written in capitals: "liūdesys" → "LIŪDESYS".
String wheelWord(String text) => text.toUpperCase();

TextStyle wheelLabelStyle(
  Color color,
  double size, {
  FontWeight weight = FontWeight.w700,
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

/// Fitting a word along a radius, in a slice of the wheel: the sunburst
/// rings and the centre of Plutchik's flower.
class RadialFit {
  const RadialFit({required this.across, this.pad = 3.5, this.lineEm = 1.1});

  /// Room lost across a slice: the gap to the neighbour and a hairline (dp).
  final double across;

  /// Room kept free at each end of a word, along the radius (dp).
  final double pad;

  /// Height of a line of capitals with Lithuanian accents and ogoneks (em).
  final double lineEm;

  /// Largest font size (dp) for a word [em] wide placed along the radius
  /// between [a] and [b] in a slice [sweep] wide. The word may slide outward
  /// within the ring, where the slice is wider.
  double size(double em, double sweep, double a, double b, [int lines = 1]) {
    final room = b - a - 2 * pad;
    if (room <= 0 || em <= 0) return 0;
    final byLength = room / em;
    // The inner end (b - pad - em·f) must leave room for the lines:
    // (b - pad - em·f)·sweep - across >= lines·lineEm·f.
    final byWidth =
        ((b - pad) * sweep - across) / (lines * lineEm + em * sweep);
    return math.max(0, math.min(byLength, byWidth));
  }

  /// Where the centre of a word [fontSize] large sits along the radius: in
  /// the middle of the part of the ring where it fits.
  double anchor(
    double em,
    double fontSize,
    double sweep,
    double a,
    double b, [
    int lines = 1,
  ]) {
    final length = em * fontSize;
    final lo = math.max(a + pad, (lines * lineEm * fontSize + across) / sweep);
    final hi = b - pad;
    if (hi - lo < length) return hi - length / 2;
    return (lo + hi) / 2;
  }

  /// Canvas rotation that keeps a word along the radius at clock angle
  /// [theta] upright: on the right half it reads outward, on the left half
  /// inward. [left] decides words that stand exactly at 12 or 6 o'clock.
  static double rotation(double theta, {bool? left}) {
    final isLeft = left ?? math.sin(theta) < 0;
    return isLeft ? theta + math.pi / 2 : theta - math.pi / 2;
  }
}

/// A horizontal or rotated label, one or two lines, laid out once.
class PlacedLabel {
  PlacedLabel({
    required this.lines,
    required this.anchor,
    required this.rotation,
    required this.fontSize,
    this.capCentered = false,
  });

  final List<TextPainter> lines;
  final Offset anchor;

  /// Canvas rotation in radians (0 = horizontal).
  final double rotation;
  final double fontSize;

  /// Centre the capital letters, not the line box, on [anchor]. Wheel words
  /// are all capitals, and this keeps them exactly in the middle of their
  /// slice.
  final bool capCentered;

  double get width => lines.fold(0, (w, l) => math.max(w, l.width));
  double get height => lines.fold(0, (h, l) => h + l.height);

  void paint(Canvas canvas) {
    canvas.save();
    canvas.translate(anchor.dx, anchor.dy);
    if (rotation != 0) canvas.rotate(rotation);
    var y = -height / 2;
    if (capCentered && lines.isNotEmpty) {
      // Average capital centre of all lines at y = 0.
      final first = lines.first;
      final baseline = first.computeDistanceToActualBaseline(
        TextBaseline.alphabetic,
      );
      y =
          Fonts.capHeight * fontSize / 2 -
          baseline -
          (lines.length - 1) * first.height / 2;
    }
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
