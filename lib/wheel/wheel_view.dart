import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../copy/strings.dart';
import '../data/models.dart';
import '../theme/colors.dart';
import '../theme/motion.dart';
import '../theme/tokens.dart';
import 'wheel_layout.dart';
import 'wheel_painters.dart';
import 'wheel_targets.dart';

/// Zoom state shared between the wheel and the "Atstatyti" button, which
/// lives low on the screen next to the other buttons.
class WheelZoom extends ChangeNotifier {
  bool _zoomed = false;
  VoidCallback? _reset;

  bool get zoomed => _zoomed;

  void _set(bool value) {
    if (value == _zoomed) return;
    _zoomed = value;
    notifyListeners();
  }

  /// Animates the wheel back to its full view.
  void reset() => _reset?.call();
}

/// "Atstatyti": a round icon that shows only while the wheel is zoomed in.
/// The word lives in the tooltip and for screen readers.
class ResetZoomButton extends StatelessWidget {
  const ResetZoomButton({super.key, required this.zoom, this.size = 56});

  final WheelZoom zoom;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final motion = Motion.of(context);
    return ListenableBuilder(
      listenable: zoom,
      builder: (context, _) => AnimatedSwitcher(
        duration: motion.short,
        switchInCurve: Motion.ease,
        switchOutCurve: Motion.ease,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: 0.85, end: 1.0).animate(animation),
            child: child,
          ),
        ),
        child: !zoom.zoomed
            ? const SizedBox.shrink()
            : IconButton.outlined(
                key: const ValueKey('reset'),
                tooltip: S.resetZoom,
                iconSize: 26,
                constraints: BoxConstraints.tightFor(width: size, height: size),
                style: IconButton.styleFrom(
                  backgroundColor: colors.surface,
                  foregroundColor: colors.ink,
                  side: BorderSide(color: colors.outline),
                ),
                onPressed: zoom.reset,
                icon: const Icon(Icons.zoom_out_map_rounded),
              ),
      ),
    );
  }
}

/// The wheel, for looking: pinch to read small words, drag to move around.
/// The zoom area fills all the space it gets, so a zoomed wheel can use the
/// height of a tall phone, not only a square.
class WheelView extends StatefulWidget {
  const WheelView({
    super.key,
    required this.wheel,
    required this.form,
    this.maxSide = Sizes.wheelMax,
    this.zoom,
    this.coverTop,
    this.coverBottomRight = Size.zero,
  });

  final WheelModel wheel;
  final WordForm form;
  final double maxSide;

  /// A see-through copy of what lies over the top of the wheel's area at
  /// full view (the question and hint). It takes the same room, so the whole
  /// wheel starts below it, while a zoomed wheel can use the full height.
  final Widget? coverTop;

  /// Buttons over the bottom right corner: the full wheel moves up so it
  /// never runs under them.
  final Size coverBottomRight;

  /// Reports zoom and accepts "Atstatyti" from outside.
  final WheelZoom? zoom;

  @override
  State<WheelView> createState() => WheelViewState();
}

class WheelViewState extends State<WheelView>
    with SingleTickerProviderStateMixin {
  final _controller = TransformationController();
  late final AnimationController _reset = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  Animation<Matrix4>? _resetAnimation;

  WheelLayout? _layout;
  Object? _layoutKey;

  /// Current layout (tests and screenshots).
  @visibleForTesting
  WheelLayout? get layout => _layout;

  @override
  void initState() {
    super.initState();
    widget.zoom?._reset = _resetZoom;
    _controller.addListener(_onTransform);
    _reset.addListener(() {
      final a = _resetAnimation;
      if (a != null) _controller.value = a.value;
    });
  }

  @override
  void didUpdateWidget(WheelView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.wheel.id != widget.wheel.id) {
      _controller.value = Matrix4.identity();
    }
  }

  @override
  void dispose() {
    if (widget.zoom?._reset == _resetZoom) widget.zoom?._reset = null;
    _controller.dispose();
    _reset.dispose();
    _layout?.dispose();
    super.dispose();
  }

  void _onTransform() {
    widget.zoom?._set(_controller.value.getMaxScaleOnAxis() > 1.02);
  }

  void _resetZoom() {
    final motion = Motion.of(context);
    if (motion.reduced) {
      _controller.value = Matrix4.identity();
      return;
    }
    _reset.duration = motion.long;
    _resetAnimation = Matrix4Tween(
      begin: _controller.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(parent: _reset, curve: Motion.easeInOut));
    _reset.forward(from: 0);
  }

  WheelLayout _layoutFor(double side, AppColors colors, double coreScale) {
    final key = (
      widget.wheel.id,
      side,
      widget.form,
      colors.brightness,
      coreScale,
    );
    if (key != _layoutKey || _layout == null) {
      _layout?.dispose();
      _layout = WheelLayout.create(
        widget.wheel,
        side: side,
        colors: colors,
        form: widget.form,
        coreScale: coreScale,
      );
      _layoutKey = key;
    }
    return _layout!;
  }

  @override
  Widget build(BuildContext context) {
    // Settled colours: the layout is kept, so a passing blend would stay.
    final colors = AppColors.settledOf(context);
    final coreScale = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 1, maxScaleFactor: 1.3).scale(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final full = Size(constraints.maxWidth, constraints.maxHeight);
        final place = LayoutBuilder(
          builder: (context, box) {
            final rect = _placeWheel(box.biggest);
            if (rect == null) return const SizedBox.shrink();
            final layout = _layoutFor(rect.width, colors, coreScale);
            return Stack(
              children: [
                Positioned.fromRect(
                  rect: rect,
                  child: Stack(
                    children: [
                      RepaintBoundary(
                        child: CustomPaint(
                          size: rect.size,
                          isComplex: true,
                          painter: WheelBasePainter(
                            layout: layout,
                            zoomStep: 1,
                          ),
                        ),
                      ),
                      WheelTargets(layout: layout),
                    ],
                  ),
                ),
              ],
            );
          },
        );
        return SizedBox.fromSize(
          size: full,
          child: InteractiveViewer(
            transformationController: _controller,
            minScale: 1,
            maxScale: 4,
            boundaryMargin: EdgeInsets.zero,
            clipBehavior: Clip.hardEdge,
            child: SizedBox.fromSize(
              size: full,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.coverTop case final cover?)
                    ExcludeFocus(
                      child: ExcludeSemantics(
                        child: IgnorePointer(
                          child: Opacity(opacity: 0, child: cover),
                        ),
                      ),
                    ),
                  Expanded(child: place),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Where the full wheel goes in [space]: as large as fits, centred, and
  /// lifted only as much as needed to stay clear of the corner buttons.
  Rect? _placeWheel(Size space) {
    final side = math
        .min(math.min(space.width, space.height), widget.maxSide)
        .floorToDouble();
    if (side < 40) return null;
    final left = ((space.width - side) / 2).floorToDouble();
    var top = ((space.height - side) / 2).floorToDouble();
    final corner = widget.coverBottomRight;
    if (corner != Size.zero) {
      final r = side / 2;
      final box = Rect.fromLTRB(
        space.width - corner.width,
        space.height - corner.height,
        space.width,
        space.height,
      );
      bool clear(double t) {
        final c = Offset(left + r, t + r);
        final nearest = Offset(
          c.dx.clamp(box.left, box.right),
          c.dy.clamp(box.top, box.bottom),
        );
        return (nearest - c).distance >= r + 4;
      }

      while (top > 0 && !clear(top)) {
        top = math.max(0, top - 2);
      }
    }
    return Rect.fromLTWH(left, top, side, side);
  }
}

/// A small, silent picture of a wheel (wheel menu cards).
class WheelThumbnail extends StatefulWidget {
  const WheelThumbnail({super.key, required this.wheel, this.size = 72});

  final WheelModel wheel;
  final double size;

  @override
  State<WheelThumbnail> createState() => _WheelThumbnailState();
}

class _WheelThumbnailState extends State<WheelThumbnail> {
  WheelLayout? _layout;
  Object? _key;

  @override
  void dispose() {
    _layout?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.settledOf(context);
    final key = (widget.wheel.id, widget.size, colors.brightness);
    if (key != _key) {
      _layout?.dispose();
      _layout = WheelLayout.create(
        widget.wheel,
        side: widget.size,
        colors: colors,
        form: WordForm.masculine,
      );
      _key = key;
    }
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _ThumbPainter(_layout!),
      ),
    );
  }
}

class _ThumbPainter extends CustomPainter {
  _ThumbPainter(this.layout);

  final WheelLayout layout;

  @override
  void paint(Canvas canvas, Size size) => layout.paintBase(canvas, 0);

  @override
  bool shouldRepaint(_ThumbPainter oldDelegate) => oldDelegate.layout != layout;
}
