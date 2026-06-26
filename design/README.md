# Emociju Ratas — branding assets

Source artwork and generator for the app launcher icon and splash mark.

## Concept

An 8-petal **flower wheel** echoing the app's own Plutchik emotion wheel
(`assets/R. Plutchiko emocijų ratas 2.png`): a bloom of eight rounded petals in the
eight Plutchik emotion colours, around a clean white hub, on a white background.

| Petal (clockwise from top) | Emotion | Colour |
|---|---|---|
| 1 | Joy | `#FFD43B` |
| 2 | Anticipation | `#FF922B` |
| 3 | Anger | `#FA5252` |
| 4 | Disgust | `#BE4BDB` |
| 5 (bottom) | Sadness | `#4C6EF5` |
| 6 | Surprise | `#22B8CF` |
| 7 | Fear | `#20C997` |
| 8 | Trust | `#94D82D` |

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
