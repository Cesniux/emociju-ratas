import 'package:flutter/material.dart';

import 'colors.dart';
import 'motion.dart';
import 'tokens.dart';
import 'typography.dart';

/// Builds the light or dark theme from tokens. No `fromSeed`: hues stay
/// exactly as specified and testable.
ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  final text = buildTextTheme(ink: c.ink, muted: c.inkMuted);

  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.ink,
    onPrimary: c.surface,
    primaryContainer: c.sunken,
    onPrimaryContainer: c.ink,
    secondary: c.inkMuted,
    onSecondary: c.surface,
    secondaryContainer: c.sunken,
    onSecondaryContainer: c.ink,
    tertiary: c.inkMuted,
    onTertiary: c.surface,
    error: brightness == Brightness.dark
        ? const Color(0xFFE6A584)
        : const Color(0xFF8C4A32),
    onError: c.surface,
    surface: c.background,
    onSurface: c.ink,
    onSurfaceVariant: c.inkMuted,
    surfaceContainerLowest: c.surface,
    surfaceContainerLow: c.surface,
    surfaceContainer: c.surface,
    surfaceContainerHigh: c.sunken,
    surfaceContainerHighest: c.sunken,
    outline: c.outline,
    outlineVariant: c.outline,
    inverseSurface: c.ink,
    onInverseSurface: c.background,
    inversePrimary: c.background,
    scrim: c.ink,
    shadow: const Color(0xFF000000),
    surfaceTint: Colors.transparent,
  );

  final stadium = const StadiumBorder();
  const minSize = Size(Sizes.minTarget, Sizes.minTarget);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.background,
    canvasColor: c.background,
    fontFamily: Fonts.body,
    textTheme: text,
    splashFactory: InkRipple.splashFactory,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    iconTheme: IconThemeData(color: c.ink, size: 22),
    dividerTheme: DividerThemeData(color: c.outline, thickness: 1, space: 1),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.ink,
        minimumSize: minSize,
        padding: const EdgeInsets.symmetric(horizontal: Space.l),
        textStyle: text.labelLarge,
        shape: stadium,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.ink,
        foregroundColor: c.surface,
        minimumSize: minSize,
        padding: const EdgeInsets.symmetric(horizontal: Space.xl),
        textStyle: text.labelLarge,
        shape: stadium,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.ink,
        minimumSize: minSize,
        side: BorderSide(color: c.outline),
        padding: const EdgeInsets.symmetric(horizontal: Space.l),
        textStyle: text.labelLarge,
        shape: stadium,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: c.ink, minimumSize: minSize),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        foregroundColor: c.ink,
        selectedForegroundColor: c.surface,
        selectedBackgroundColor: c.ink,
        side: BorderSide(color: c.outline),
        minimumSize: minSize,
        textStyle: text.labelLarge,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      modalBackgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: c.inkMuted.withValues(alpha: 0.45),
      modalBarrierColor: c.ink.withValues(alpha: 0.10),
      elevation: 0,
      modalElevation: 0,
      constraints: const BoxConstraints(maxWidth: Sizes.readingMax),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.ink,
      contentTextStyle: text.bodyMedium?.copyWith(color: c.background),
      actionTextColor: c.background,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      foregroundColor: c.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: c.ink,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: text.bodySmall?.copyWith(color: c.background),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CalmPageTransitionsBuilder(),
        TargetPlatform.iOS: CalmPageTransitionsBuilder(),
        TargetPlatform.macOS: CalmPageTransitionsBuilder(),
        TargetPlatform.windows: CalmPageTransitionsBuilder(),
        TargetPlatform.linux: CalmPageTransitionsBuilder(),
        TargetPlatform.fuchsia: CalmPageTransitionsBuilder(),
      },
    ),
    extensions: [c],
  );
}
