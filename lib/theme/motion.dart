import 'package:flutter/material.dart';

/// Calm motion tokens. Everything is instant when the person asked the
/// system for less motion (WCAG 2.3.3).
@immutable
class Motion {
  const Motion._(this.reduced);

  /// For tests and previews.
  const Motion.forTesting({required this.reduced});

  /// True when Android "Remove animations" or iOS "Reduce Motion" is on.
  final bool reduced;

  static const Duration _short = Duration(milliseconds: 250);
  static const Duration _medium = Duration(milliseconds: 350);
  static const Duration _long = Duration(milliseconds: 450);

  static const Curve ease = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;

  Duration get short => reduced ? Duration.zero : _short;
  Duration get medium => reduced ? Duration.zero : _medium;
  Duration get long => reduced ? Duration.zero : _long;

  /// Bottom sheets: soft rise, or none.
  AnimationStyle get sheet => reduced
      ? AnimationStyle.noAnimation
      : AnimationStyle(duration: _medium, reverseDuration: _short, curve: ease);

  /// `MediaQuery.disableAnimations` only reflects Android; iOS Reduce Motion
  /// comes from the platform's accessibility features, so check both.
  static Motion of(BuildContext context) {
    final disable = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final reduce =
        View.maybeOf(
          context,
        )?.platformDispatcher.accessibilityFeatures.reduceMotion ??
        false;
    return Motion._(disable || reduce);
  }
}

/// Page change: a soft fade with a 4% rise, or nothing under reduced motion.
class CalmPageTransitionsBuilder extends PageTransitionsBuilder {
  const CalmPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (Motion.of(context).reduced) return child;
    final curved = CurvedAnimation(parent: animation, curve: Motion.ease);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
