import 'package:flutter/widgets.dart';

/// Spacing scale in dp (design/SYSTEM.md).
abstract final class Space {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

abstract final class Radii {
  static const double card = 20;
  static const double sheet = 28;
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
}

abstract final class Sizes {
  /// Minimum touch target (Android 48 dp; Apple's default 44 pt).
  static const double minTarget = 48;
  static const double wheelMax = 560;
  static const double readingMax = 640;
  static const double trayHeight = 76;
}
