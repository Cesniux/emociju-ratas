# Emocijų ratas — design system

Token spec for `lib/theme/`. Evidence for each choice: `design/RATIONALE.md`.

## Problem
A person often opens this app while upset. Stress shrinks working memory, so the interface has
to be quiet, predictable and large: colour must mean *feeling*, never decoration, and nothing may
compete with the wheel for attention.

## Principles
1. **Colour belongs to feelings.** The interface itself is warm ink on paper. Buttons, links,
   switches and focus use ink; only wheel segments carry hue.
2. **One calm filter for every hue.** Each feeling family has three tints (strong / medium / soft),
   all light and low in saturation (light theme) or deep and muted (dark theme).
3. **Every word, as large as the screen allows.** Every outermost word gets the same slice, the
   ring widths are fitted to the screen, and wheel words are heavy capitals. Pinch to read.
4. **Soft geometry, slow motion.** Rounded corners, small gaps, petals; motion short and eased,
   and off when the system asks for less motion.

## Colour tokens

### Neutrals
| Token | Light | Dark | Use |
|---|---|---|---|
| `background` | `#FAF6F0` | `#202A3D` | page, gaps between wheel segments |
| `surface` | `#FFFDF9` | `#293449` | sheets, cards, round buttons |
| `sunken` | `#F2ECE3` | `#333F54` | inset areas |
| `ink` | `#2B2724` | `#ECE9E2` | text, icons, primary buttons |
| `inkMuted` | `#5E5650` | `#B7BECA` | secondary text, hints |
| `outline` | `#DDD3C7` | `#485469` | hairlines, card borders (decorative) |

Dark is an evening blue (OKLCH L 0.285, C 0.038, h 262), never near-black; its ink is a soft
moonlight white.

### Feeling tints (strong / medium / soft)
| Hue | Used by | Light | Dark |
|---|---|---|---|
| yellow | Nuostaba · Plutchik joy · honey of the energy circle | `#E6C35C` `#F0D891` `#F8EBC4` | `#79621A` `#635220` `#4F4320` |
| olive | Džiaugsmas | `#B7BC6A` `#D2D59C` `#E8EAC8` | `#666933` `#55572F` `#44462A` |
| blue | Liūdesys · sadness | `#93ACD3` `#B9CAE5` `#DCE5F2` | `#55667F` `#485568` `#3B4452` |
| mauve | Pasibjaurėjimas · disgust | `#B89FCB` `#D3C2DF` `#E9DFF0` | `#6D5D7A` `#5A4E64` `#48404F` |
| clay | Pyktis · anger | `#DC8D78` `#EAB1A2` `#F5D6CD` | `#895547` `#70483E` `#583C34` |
| orange | Baimė · anticipation | `#E9A86A` `#F2C69A` `#F9E2CA` | `#845A31` `#6C4C2E` `#553E29` |
| sage | trust | `#A9C78A` `#C8DCB2` `#E3EDD6` | `#596C45` `#4B5A3C` `#3D4833` |
| green | fear (Plutchik) | `#7FB59A` `#AFD0BD` `#D7E9DE` | `#4A6E5C` `#405B4D` `#36493F` |
| sky | surprise (Plutchik) | `#8CC3D2` `#B5D9E2` `#DAEDF1` | `#476B75` `#3E5960` `#34474D` |
| rose | Meilė | `#E3A0AF` `#EEC2CB` `#F7E2E6` | `#825760` `#6A4951` `#543C41` |

Tiers: wheel core / Plutchik intense = strong, middle / basic = medium, outer / mild = soft.
Dark tints keep each hue's angle and step down in OKLCH lightness (0.505 / 0.445 / 0.385) and
chroma (72 / 56 / 42% of the light strong tint). Label colour = `ink` on every tint. The
wheel is drawn once and kept, so it always takes the finished light or dark colours
(`AppColors.settledOf`), never the blend the theme passes through while it switches.
Measured: ink on any tint ≥ 4.7:1 (both themes); `test/theme/contrast_test.dart` enforces 4.5:1.

## Typography
| Role | Family | Size / line height | Weight |
|---|---|---|---|
| Display (prompt "Kaip dabar jautiesi?") | Nunito | 25 / 1.2 | 800 |
| Title (sheet, page) | Nunito | 23 / 1.25 | 800 |
| Heading (card) | Nunito | 19 / 1.3 | 800 |
| Body (reading page) | Nunito | 17 / 1.5 | 400 |
| Label (buttons) | Nunito | 16 / 1.25 | 700 |
| Small (hints, sources) | Nunito | 14 / 1.4 | 400 |
| Wheel family names | Nunito | one fitted size, never broken, in the middle of the slice; ≈ 1.2× the other words | 900 |
| Wheel middle/outer words | Nunito | one fitted size for both rings, always shown (pinch to read) | 800 |

Nunito static instances (400–900) cut from the variable font and subset to Latin + Latin
Extended-A (all Lithuanian letters), OFL. Wheel capitals are centred on the cap height (0.71 em),
not the line box.

Sentence case everywhere except feeling words on the wheel, which are in capitals. Reading column max 640 dp (~65 characters). Sheets/pages follow the
system text size; the painted wheel does not (its core may grow up to 1.3×).

## Space, shape, size
- Spacing scale (dp): 4, 8, 12, 16, 24, 32, 48.
- Radius: chip = stadium, card 20, sheet 28. Ring wheels (Jausmų ratas, Jausmų šeimos): words
  parted by thin lines ≈ 0.4% of the radius (0.75–1.5 dp), segment corners 1 dp. Plutchik's
  flower: gaps ≈ 0.8% of the radius (1.5–3 dp), corners 3 dp.
- Touch targets ≥ 48 × 48 dp, ≥ 8 dp apart. The wheel fills the width (tablets too); sheets max
  640 dp wide.

## Motion
| Token | Duration | Curve | Use |
|---|---|---|---|
| `short` | 250 ms | easeOutCubic | chip select, fades |
| `medium` | 350 ms | easeOutCubic | sheet, page fade + 4% rise |
| `long` | 450 ms | easeInOutCubic | zoom reset |
No bounce, no looping animation. **Reduced motion** (`MediaQuery.disableAnimationsOf` on Android
or `accessibilityFeatures.reduceMotion` on iOS) → every duration is zero.

## Components (summary)
| Component | Variants / states | Accessibility |
|---|---|---|
| Corner buttons | bottom right, for the right thumb: the flower (64 dp) opens the wheel drawer "Pasirink emocijų ratą"; "?" (56 dp) just left of it opens "Kaip naudotis"; "Atstatyti" (56 dp) appears above the flower only while zoomed | tooltips "Keisti ratą", "Kaip naudotis", "Atstatyti" |
| Heading | "Kaip dabar jautiesi?", the wheel's hint (first opening, then every third) and the gear; fades away while the wheel is zoomed in | header; hidden from screen readers while faded |
| Reading pages | "Kaip naudotis": how-to card, the "why" tile, help lines. "Kodėl emocijų ratas gali būti naudingas?": six numbered fold cards, then "Apie programėlę" and "Šaltiniai"; "Grįžti" at the bottom of both | page title is the first header |
| Why tile | book icon, title, "Šeši trumpi skyreliai…", chevron; ink border 1.5 dp so it reads as a door | one button with title and lead |
| Fold card | closed: number, title, first sentence (2 lines max, muted), chevron; open: the whole card at full width, then "Toliau: …" (or "Grįžti prie rato" after the last). One open at a time; an opened card scrolls its title to the top | one button "title. first sentence" with a folded / open hint |
| Settings | gear icon top right of home; drawer with word form and colours (light, dark, like the phone) | tooltip "Nustatymai" |
| Text button (ink) | idle, pressed, focus | ≥ 48 dp, label always visible |
| Wheel | base + highlight overlay | one read-only semantic node per word, clockwise; Lithuanian locale |
