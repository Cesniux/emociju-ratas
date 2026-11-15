# Emociju Ratas — branding assets

Source artwork and generator for the app launcher icon and splash mark.

## Concept

An 8-petal **flower wheel** echoing Plutchik's flower inside the app: eight rounded petals in
the app's calm feeling tints (the "strong" tier of `lib/theme/palette.dart`), around a soft
hub, on warm paper `#FAF6F0` (the app's background, so icon, splash and app feel like one).

| Petal (clockwise from top) | Emotion | Colour |
|---|---|---|
| 1 | Joy | `#E6C35C` |
| 2 | Trust | `#A9C78A` |
| 3 | Fear | `#7FB59A` |
| 4 | Surprise | `#8CC3D2` |
| 5 (bottom) | Sadness | `#93ACD3` |
| 6 | Disgust | `#B89FCB` |
| 7 | Anger | `#DC8D78` |
| 8 | Anticipation | `#E9A86A` |

The splash colour lives in `android/app/src/main/res/values{,-night}/colors.xml`
(`splash_background`, light `#FAF6F0`, dark `#1C1A17`) and in the iOS colour set
`ios/Runner/Assets.xcassets/LaunchBackground.colorset`.

## How to regenerate

`generate.mjs` is the source of truth. Edit the colours / petal path / scales there,
then:

```bash
cd design
npm install        # @resvg/resvg-js + sharp + png-to-ico (prebuilt binaries)
node generate.mjs
```

This rewrites every platform asset in place:

- **iOS** — `ios/Runner/Assets.xcassets/AppIcon.appiconset/*` (opaque, no alpha) and the
  `LaunchImage.imageset` splash.
- **Android** — adaptive foreground (`mipmap-*/ic_launcher_foreground.png`) + legacy
  (`mipmap-*/ic_launcher.png`) icons and `drawable-*/splash_logo.png`.
- **Web** — `web/icons/Icon-{192,512}.png`, maskable variants, `web/favicon.png`.
- **macOS** — `macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_*.png`.
- **Windows** — `windows/runner/resources/app_icon.ico`.

It also dumps the resolved vectors (`design/icon.svg`, `icon-foreground.svg`, `splash.svg`,
`icon-macos.svg`) and a `design/preview.png` contact sheet for inspection.

The XML wiring (Android adaptive-icon descriptors, `launch_background.xml`, `values-v31`
splash, web manifest/index) is committed separately and does not need regenerating.

> No Flutter toolchain is required — assets are rasterized directly. To see them on a device,
> build normally: `flutter pub get && flutter run`.
