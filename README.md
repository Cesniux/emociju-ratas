# Emocijų ratas

A calm Lithuanian emotion-wheel app (Flutter). Open it and the wheel you used last is already
there: start from the colour closest to what you feel and move outward to the exact word; pinch
to read the small words. Every word on the wheel gets the same slice, in Nunito capitals.
Nothing leaves the phone.

## The four wheels

| Wheel | Model | Lithuanian words from |
|---|---|---|
| Jausmų ratas (default) | G. Roberts' Feelings Wheel (2015), after G. Willcox (1982) | Pokalbių gidas "Kaip dabar jautiesi?" |
| Plutchiko gėlė | R. Plutchik (1980, 2001): 8 petals × 3 intensities + 8 mixtures | Lithuanian Plutchik picture (verslas.in 2013), K. Paradnikė / LKETA poster |
| Energija ir malonumas | J. Russell's circumplex (1980), Affect Grid (1989), Posner et al. (2005) | Lithuanian PANAS-X (Vilnius University, 2022) |
| Jausmų šeimos | P. Shaver et al. (1987), W. G. Parrott (2001), with Meilė | L. Matulionienė's feeling list, LKETA |

Every Lithuanian word comes from an existing Lithuanian wheel or list, and each records its
source. `design/WORDS.md` lists all words with both grammatical forms for proofreading.

## Design

- `design/SYSTEM.md`: design tokens (colour, type, space, motion, components).
- `design/RATIONALE.md`: every design decision with the research behind it.
- "Kaip naudotis" in the app: how to use a wheel, help lines, and why naming feelings helps,
  with numbered sources.

## Run

```bash
F=~/fvm/versions/3.44.0/bin/flutter   # or your Flutter 3.44 install
$F pub get
$F run                                # pick a simulator or device
```

## Test

```bash
$F analyze
$F test                               # data, geometry, contrast, widget and a11y tests
# Review screenshots of every screen into .context/shots/ (not a check):
$F test --tags shots --run-skipped --update-goldens test/shots
```

## Words

Edit the data in `lib/data/` (`jausmu_ratas.dart`, `plutchik.dart`, `energija.dart`,
`jausmu_seimos.dart`; sources in `sources.dart`), then regenerate the proofreading file:

```bash
~/fvm/versions/3.44.0/bin/dart run tool/print_wheels.dart > design/WORDS.md
```

## Icon and splash

`design/generate.mjs` draws the flower icon and splash for every platform (see
`design/README.md`): `cd design && npm install && node generate.mjs`.
