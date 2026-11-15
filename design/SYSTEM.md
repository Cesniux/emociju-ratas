# Emocijų ratas — design system

Token spec for `lib/theme/`. Evidence for each choice: `design/RATIONALE.md`.

## Problem
A person often opens this app while upset. Stress shrinks working memory, so the interface has
to be quiet, predictable and large: colour must mean *feeling*, never decoration, and nothing may
compete with the wheel for attention.

## Principles
1. **Colour belongs to feelings.** The interface itself is warm ink on paper. Buttons, links,
   switches and focus use ink; only wheel segments, chips and the tray carry hue.
2. **One calm filter for every hue.** Each feeling family has three tints (strong / medium / soft),
   all light and low in saturation (light theme) or deep and muted (dark theme).
3. **Readable or hidden.** Text is drawn only where it reaches its minimum size. No 6 dp labels.
4. **Soft geometry, slow motion.** Rounded corners, small gaps, petals; motion short and eased,
   and off when the system asks for less motion.

## Colour tokens

### Neutrals
| Token | Light | Dark | Use |
|---|---|---|---|
| `background` | `#FAF6F0` | `#1C1A17` | page, gaps between wheel segments |
| `surface` | `#FFFDF9` | `#262320` | sheets, cards, chips (idle) |
| `sunken` | `#F2ECE3` | `#302C28` | tray, inset areas |
| `ink` | `#2B2724` | `#F1EBE3` | text, icons, primary buttons, outlines of chosen segments |
| `inkMuted` | `#5E5650` | `#C4BAAE` | secondary text, hints |
| `outline` | `#DDD3C7` | `#3E3934` | hairlines, card borders (decorative) |

### Feeling tints (strong / medium / soft)
| Hue | Used by | Light | Dark |
|---|---|---|---|
| yellow | Nuostaba · Plutchik joy · honey of the energy circle | `#E6C35C` `#F0D891` `#F8EBC4` | `#6E5A1E` `#574A22` `#3F3824` |
| olive | Džiaugsmas | `#B7BC6A` `#D2D59C` `#E8EAC8` | `#5A5E26` `#484B26` `#363824` |
| blue | Liūdesys · sadness | `#93ACD3` `#B9CAE5` `#DCE5F2` | `#3D5680` `#334563` `#2A3447` |
| mauve | Pasibjaurėjimas · disgust | `#B89FCB` `#D3C2DF` `#E9DFF0` | `#5E4775` `#4A3B5B` `#382F42` |
| clay | Pyktis · anger | `#DC8D78` `#EAB1A2` `#F5D6CD` | `#7E3F31` `#613A31` `#46302B` |
| orange | Baimė · anticipation | `#E9A86A` `#F2C69A` `#F9E2CA` | `#7A4A1F` `#5F4026` `#453326` |
| sage | trust | `#A9C78A` `#C8DCB2` `#E3EDD6` | `#4B6634` `#3E5230` `#313D29` |
| green | fear (Plutchik) | `#7FB59A` `#AFD0BD` `#D7E9DE` | `#2F6149` `#2B4E3D` `#253C31` |
| sky | surprise (Plutchik) | `#8CC3D2` `#B5D9E2` `#DAEDF1` | `#2F5F6E` `#2B4D58` `#253B43` |
| rose | Meilė | `#E3A0AF` `#EEC2CB` `#F7E2E6` | `#7A3D4C` `#5F3540` `#452B32` |

Tiers: wheel core / Plutchik intense = strong, middle / basic = medium, outer / mild = soft.
Chosen segment = strong tint + 2 dp ink outline. Label colour = `ink` on every tint.
Measured: ink on any tint ≥ 5.46:1 (both themes); `test/theme/contrast_test.dart` enforces 4.5:1.

## Typography
| Role | Family | Size / line height | Weight |
|---|---|---|---|
| Display (prompt "Kaip dabar jautiesi?") | Lora | 26 / 1.25 | 600 |
| Title (sheet, page) | Lora | 22 / 1.3 | 600 |
| Heading (card) | Lora | 19 / 1.3 | 600 |
| Body (reading page) | Atkinson Hyperlegible Next | 17 / 1.5 | 400 |
| Label (buttons, chips) | Atkinson Hyperlegible Next | 16 / 1.25 | 500 |
| Small (hints, sources) | Atkinson Hyperlegible Next | 14 / 1.4 | 400 |
| Wheel core | Atkinson Hyperlegible Next | 13–18, fitted | 600 |
| Wheel middle/outer | Atkinson Hyperlegible Next | fitted, shown only ≥ 10 on screen | 500 |

Sentence case everywhere. Reading column max 640 dp (~65 characters). Sheets/pages follow the
system text size; the painted wheel does not (its core may grow up to 1.3×).

## Space, shape, size
- Spacing scale (dp): 4, 8, 12, 16, 24, 32, 48.
- Radius: chip = stadium, card 20, sheet 28, wheel segment corners ≤ 4, gap between segments
  ≈ 0.8% of the radius (1.5–3 dp).
- Touch targets ≥ 48 × 48 dp, ≥ 8 dp apart. Wheel max diameter 560 dp; sheets max 640 dp wide.

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
| Wheel pill (top bar) | idle, pressed | button "Ratas: ‹name›. Pakeisti ratą" |
| Text button (ink) | idle, pressed, focus | ≥ 48 dp, label always visible |
| Feeling chip | idle (surface + outline), chosen (strong tint + check), pressed | button, selected state, label = word |
| Tray chip | chosen word + remove | "Pašalinti ‹word›" |
| Sheet | drag handle, 62% → 94% | scrim light (ink 18%) so the wheel stays visible |
| Wheel | base + highlight overlay | one semantic node per family/petal/dyad/quadrant, Lithuanian locale |
