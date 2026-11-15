import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../copy/strings.dart';
import '../data/models.dart';
import '../state/selection.dart';
import '../theme/colors.dart';
import '../theme/motion.dart';
import '../theme/tokens.dart';
import 'wheel_layout.dart';
import 'wheel_painters.dart';

/// The interactive wheel: tap to open a family, pinch to see more words.
class WheelView extends StatefulWidget {
  const WheelView({
    super.key,
    required this.wheel,
    required this.form,
    required this.selection,
    this.onHit,
    this.maxSide = Sizes.wheelMax,
  });

  final WheelModel wheel;
  final WordForm form;
  final Selection selection;
  final ValueChanged<WheelHit>? onHit;
  final double maxSide;

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

  double _zoomStep = 1;
  bool _zoomed = false;
  String? _hover;
  Offset? _probe;

  WheelLayout? _layout;
  Object? _layoutKey;

  /// Current layout (tests and screenshots).
  @visibleForTesting
  WheelLayout? get layout => _layout;

  @override
  void initState() {
    super.initState();
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
      _probe = null;
      _hover = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _reset.dispose();
    _layout?.dispose();
    super.dispose();
  }

  void _onTransform() {
    final scale = _controller.value.getMaxScaleOnAxis();
    final step = scale >= 2.6
        ? 3.0
        : scale >= 1.8
        ? 2.0
        : scale >= 1.3
        ? 1.5
        : 1.0;
    final zoomed = scale > 1.02;
    if (step != _zoomStep || zoomed != _zoomed) {
      setState(() {
        _zoomStep = step;
        _zoomed = zoomed;
      });
    }
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
      _probe = null;
    }
    return _layout!;
  }

  void _handleHit(WheelHit hit) {
    if (hit is CircumplexHit) setState(() => _probe = hit.position);
    widget.onHit?.call(hit);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final coreScale = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 1, maxScaleFactor: 1.3).scale(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math
            .min(
              math.min(constraints.maxWidth, constraints.maxHeight),
              widget.maxSide,
            )
            .floorToDouble();
        if (side < 40) return const SizedBox.shrink();
        final layout = _layoutFor(side, colors, coreScale);

        final wheel = SizedBox.square(
          dimension: side,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onHover: (e) {
              final id = layout.hitTest(e.localPosition)?.familyId;
              if (id != _hover) setState(() => _hover = id);
            },
            onExit: (_) {
              if (_hover != null) setState(() => _hover = null);
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTapUp: (d) {
                final hit = layout.hitTest(d.localPosition);
                if (hit != null) _handleHit(hit);
              },
              child: Stack(
                children: [
                  ListenableBuilder(
                    listenable: widget.selection,
                    builder: (context, _) => RepaintBoundary(
                      child: CustomPaint(
                        size: Size.square(side),
                        isComplex: true,
                        painter: WheelBasePainter(
                          layout: layout,
                          zoomStep: _zoomStep,
                          chosenCounts: {
                            for (final f in widget.wheel.families)
                              f.id: widget.selection.countIn(
                                widget.wheel.feelings.where(
                                  (x) => x.familyId == f.id,
                                ),
                              ),
                          },
                          onTarget: _handleHit,
                        ),
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: CustomPaint(
                      size: Size.square(side),
                      painter: WheelHighlightPainter(
                        layout: layout,
                        selection: widget.selection,
                        zoomStep: _zoomStep,
                        hoverFamilyId: _hover,
                        probe: _probe,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        return Center(
          child: SizedBox.square(
            dimension: side,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                InteractiveViewer(
                  transformationController: _controller,
                  minScale: 1,
                  maxScale: 3,
                  boundaryMargin: EdgeInsets.zero,
                  clipBehavior: Clip.hardEdge,
                  child: wheel,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: AnimatedOpacity(
                    opacity: _zoomed ? 1 : 0,
                    duration: Motion.of(context).short,
                    child: IgnorePointer(
                      ignoring: !_zoomed,
                      child: ExcludeSemantics(
                        excluding: !_zoomed,
                        child: FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.surface,
                            foregroundColor: colors.ink,
                            side: BorderSide(color: colors.outline),
                          ),
                          onPressed: _resetZoom,
                          icon: const Icon(
                            Icons.zoom_out_map_rounded,
                            size: 20,
                          ),
                          label: const Text(S.resetZoom),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
    final colors = AppColors.of(context);
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
