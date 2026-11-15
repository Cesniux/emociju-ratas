import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../copy/strings.dart';
import '../state/app_scope.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../wheel/wheel_view.dart';
import 'focus_sheet.dart';
import 'how_to_screen.dart';
import 'selection_tray.dart';
import 'wheel_chooser_sheet.dart';

/// Home is the wheel. Nothing else competes with it.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const wheelKey = ValueKey('home-wheel');

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;

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

              final topBar = Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Space.s,
                runSpacing: Space.xs,
                children: [
                  Semantics(
                    hint: S.wheelPillHint,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.only(
                          left: Space.l,
                          right: Space.m,
                        ),
                      ),
                      onPressed: () => showWheelMenu(context),
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.expand_more_rounded),
                      label: Text(wheel.title),
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: Space.m),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const HowToScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.auto_stories_outlined),
                    label: const Text(S.howToUse),
                  ),
                ],
              );

              final heading = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    header: true,
                    child: Text(S.prompt, style: text.displaySmall),
                  ),
                  const SizedBox(height: Space.xs),
                  Text(
                    wheel.hint,
                    style: text.bodyMedium?.copyWith(color: c.inkMuted),
                  ),
                ],
              );

              final wheelView = WheelView(
                key: wheelKey,
                wheel: wheel,
                form: scope.settings.wordForm,
                selection: scope.selection,
                onHit: (hit) => showFocusSheet(context, wheel, hit),
                alignment: const Alignment(0, -0.4),
              );

              return LayoutBuilder(
                builder: (context, box) {
                  final landscape =
                      box.maxWidth > box.maxHeight && box.maxHeight < 600;
                  if (landscape) {
                    return Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(Space.m),
                            child: wheelView,
                          ),
                        ),
                        SizedBox(
                          width: 340,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  Space.l,
                                  Space.s,
                                  Space.l,
                                  0,
                                ),
                                child: topBar,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  Space.xl,
                                  Space.m,
                                  Space.xl,
                                  0,
                                ),
                                child: heading,
                              ),
                              const Spacer(),
                              const SelectionTray(),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  // Very large text on a small phone: let the page scroll
                  // rather than squeeze the wheel to nothing.
                  final scale = MediaQuery.textScalerOf(context).scale(1);
                  if (scale > 1.3 && box.maxHeight < 700) {
                    final wheelSide = (box.maxWidth - 2 * Space.m).clamp(
                      200.0,
                      420.0,
                    );
                    return ListView(
                      padding: const EdgeInsets.only(top: Space.s),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Space.l,
                          ),
                          child: topBar,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            Space.xl,
                            Space.m,
                            Space.xl,
                            Space.s,
                          ),
                          child: heading,
                        ),
                        SizedBox(
                          height: wheelSide,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Space.m,
                            ),
                            child: wheelView,
                          ),
                        ),
                        const SelectionTray(),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Space.l,
                          Space.s,
                          Space.s,
                          0,
                        ),
                        child: topBar,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Space.xl,
                          Space.m,
                          Space.xl,
                          Space.s,
                        ),
                        child: heading,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Space.m,
                            vertical: Space.s,
                          ),
                          child: wheelView,
                        ),
                      ),
                      const SelectionTray(),
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
