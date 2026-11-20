import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../copy/strings.dart';
import '../data/models.dart';
import '../state/app_scope.dart';
import '../theme/colors.dart';
import '../theme/motion.dart';
import '../theme/tokens.dart';
import '../wheel/wheel_view.dart';
import 'flower_icon.dart';
import 'how_to_screen.dart';
import 'settings_sheet.dart';
import 'wheel_menu_sheet.dart';

/// Home is the wheel, for looking. The question and the settings icon sit on
/// top and step aside while the wheel is zoomed in; three round buttons wait
/// at the bottom right, where a right thumb rests.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const wheelKey = ValueKey('home-wheel');

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _zoom = WheelZoom();

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final c = AppColors.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: c.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: ListenableBuilder(
            listenable: scope.settings,
            builder: (context, _) {
              final wheel = scope.settings.wheel;
              final actions = _Actions(zoom: _zoom);

              return LayoutBuilder(
                builder: (context, box) {
                  final landscape =
                      box.maxWidth > box.maxHeight && box.maxHeight < 600;
                  if (landscape) {
                    return Row(
                      children: [
                        Expanded(
                          child: WheelView(
                            key: HomeScreen.wheelKey,
                            wheel: wheel,
                            form: scope.settings.wordForm,
                            zoom: _zoom,
                          ),
                        ),
                        SizedBox(
                          width: 340,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _Heading(wheel: wheel),
                              const Spacer(),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: actions,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  // Very large text on a small phone: let the page scroll
                  // rather than squeeze the wheel to nothing.
                  final scale = MediaQuery.textScalerOf(context).scale(1);
                  if (scale > 1.3) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: ListView(
                            padding: const EdgeInsets.only(
                              bottom: _Actions.height + Space.l,
                            ),
                            children: [
                              _Heading(wheel: wheel),
                              SizedBox(
                                height: box.maxWidth.clamp(200.0, 420.0),
                                child: WheelView(
                                  key: HomeScreen.wheelKey,
                                  wheel: wheel,
                                  form: scope.settings.wordForm,
                                  zoom: _zoom,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(right: 0, bottom: 0, child: actions),
                      ],
                    );
                  }
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: WheelView(
                          key: HomeScreen.wheelKey,
                          wheel: wheel,
                          form: scope.settings.wordForm,
                          zoom: _zoom,
                          coverTop: _Heading(wheel: wheel, ghost: true),
                          coverBottomRight: const Size(
                            _Actions.width,
                            _Actions.height,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: _StepsAside(
                          zoom: _zoom,
                          child: _Heading(wheel: wheel),
                        ),
                      ),
                      Positioned(right: 0, bottom: 0, child: actions),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Fades its child away while the wheel is zoomed in, so the wheel can use
/// the whole screen, and brings it back when the wheel is whole again.
class _StepsAside extends StatelessWidget {
  const _StepsAside({required this.zoom, required this.child});

  final WheelZoom zoom;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    return ListenableBuilder(
      listenable: zoom,
      builder: (context, child) => IgnorePointer(
        ignoring: zoom.zoomed,
        child: ExcludeSemantics(
          excluding: zoom.zoomed,
          child: AnimatedOpacity(
            opacity: zoom.zoomed ? 0 : 1,
            duration: motion.medium,
            curve: Motion.ease,
            child: child,
          ),
        ),
      ),
      child: child,
    );
  }
}

/// "Kaip dabar jautiesi?", the wheel's hint and the settings icon.
class _Heading extends StatelessWidget {
  const _Heading({required this.wheel, this.ghost = false});

  final WheelModel wheel;

  /// A see-through stand-in that only takes the same room.
  final bool ghost;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.l, Space.m, Space.xs, Space.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  header: true,
                  child: Text(S.prompt, style: text.headlineSmall),
                ),
                const SizedBox(height: 2),
                Text(
                  wheel.hint,
                  style: text.bodyMedium?.copyWith(color: c.inkMuted),
                ),
              ],
            ),
          ),
          if (ghost)
            const SizedBox.square(dimension: Sizes.minTarget)
          else
            IconButton(
              tooltip: S.settings,
              iconSize: 26,
              onPressed: () => showSettings(context),
              icon: const Icon(Icons.settings_outlined),
            ),
        ],
      ),
    );
  }
}

/// Bottom right, for the right thumb: the flower that changes the wheel,
/// help above it, and "Atstatyti" to the left of help while zoomed in.
class _Actions extends StatelessWidget {
  const _Actions({required this.zoom});

  final WheelZoom zoom;

  static const double _button = 56;
  static const double _flower = 64;
  static const double _gap = Space.m;
  static const double _margin = Space.s;

  /// Room the buttons take at full view (reset hidden).
  static const double width = _flower + 2 * _margin;
  static const double height = _flower + _gap + _button + 2 * _margin;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final round = IconButton.styleFrom(
      backgroundColor: c.surface,
      foregroundColor: c.ink,
      side: BorderSide(color: c.outline),
    );
    return Padding(
      padding: const EdgeInsets.all(_margin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ResetZoomButton(zoom: zoom, size: _button),
              ListenableBuilder(
                listenable: zoom,
                builder: (context, _) =>
                    SizedBox(width: zoom.zoomed ? _gap : 0),
              ),
              Padding(
                // Centred over the flower.
                padding: const EdgeInsets.only(right: (_flower - _button) / 2),
                child: IconButton.outlined(
                  tooltip: S.howToUse,
                  iconSize: 26,
                  constraints: const BoxConstraints.tightFor(
                    width: _button,
                    height: _button,
                  ),
                  style: round,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const HowToScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.question_mark_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: _gap),
          IconButton.outlined(
            tooltip: S.changeWheel,
            constraints: const BoxConstraints.tightFor(
              width: _flower,
              height: _flower,
            ),
            style: round,
            onPressed: () => showWheelMenu(context),
            icon: const FlowerIcon(size: 40),
          ),
        ],
      ),
    );
  }
}
