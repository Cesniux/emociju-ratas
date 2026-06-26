// Emociju Ratas — app icon + splash generator.
//
// This file is the *source of truth* for the brand mark: an 8-petal "flower wheel"
// echoing the app's Plutchik emotion wheel (assets/R. Plutchiko emocijų ratas 2.png),
// drawn in the 8 emotion colours on a clean white background.
//
// It builds the vector artwork (also dumped to design/*.svg for inspection) and
// rasterizes it into every platform slot:
//   iOS app icons + launch image, Android adaptive + legacy icons + splash,
//   web (incl. maskable) + favicon, macOS appiconset, Windows .ico.
//
// Renderer: @resvg/resvg-js (crisp SVG->PNG) + sharp (alpha/resize) + png-to-ico.
// Run:  cd design && npm install && node generate.mjs

import { Resvg } from '@resvg/resvg-js';
import sharp from 'sharp';
import pngToIco from 'png-to-ico';
import { mkdir, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(HERE, '..'); // repo root
const p = (...s) => resolve(ROOT, ...s);

// ---------------------------------------------------------------------------
// Design constants
// ---------------------------------------------------------------------------

// 8 Plutchik emotions, clockwise from 12 o'clock. SVG rotate() is clockwise.
const EMOTIONS = [
  ['joy', '#FFD43B'],
  ['anticipation', '#FF922B'],
  ['anger', '#FA5252'],
  ['disgust', '#BE4BDB'],
  ['sadness', '#4C6EF5'],
  ['surprise', '#22B8CF'],
  ['fear', '#20C997'],
  ['trust', '#94D82D'],
];

// One petal pointing up, on a 1024 canvas centred at (512,512). Tip reaches r~417.
const PETAL = 'M512 470 C396 430 402 175 512 95 C622 175 628 430 512 470 Z';

// --- colour helpers ---------------------------------------------------------
const hexToRgb = (h) => {
  h = h.replace('#', '');
  return [0, 2, 4].map((i) => parseInt(h.slice(i, i + 2), 16));
};
const rgbToHex = (rgb) =>
  '#' + rgb.map((v) => Math.max(0, Math.min(255, Math.round(v))).toString(16).padStart(2, '0')).join('');
const mix = (hex, target, t) => {
  const a = hexToRgb(hex);
  const b = hexToRgb(target);
  return rgbToHex(a.map((v, i) => v + (b[i] - v) * t));
};
const lighten = (h, t) => mix(h, '#ffffff', t);
const darken = (h, t) => mix(h, '#000000', t);

// ---------------------------------------------------------------------------
// SVG building blocks
// ---------------------------------------------------------------------------

function defs() {
  const grads = EMOTIONS.map(
    ([, col], i) => `
    <linearGradient id="grad${i}" gradientUnits="userSpaceOnUse" x1="512" y1="470" x2="512" y2="95">
      <stop offset="0" stop-color="${darken(col, 0.05)}"/>
      <stop offset="0.55" stop-color="${col}"/>
      <stop offset="1" stop-color="${lighten(col, 0.32)}"/>
    </linearGradient>`
  ).join('');

  return `<defs>${grads}
    <radialGradient id="hub" cx="0.5" cy="0.42" r="0.65">
      <stop offset="0" stop-color="#ffffff"/>
      <stop offset="0.80" stop-color="#ffffff"/>
      <stop offset="1" stop-color="#eef1f5"/>
    </radialGradient>
    <filter id="softshadow" x="-25%" y="-25%" width="150%" height="150%">
      <feGaussianBlur in="SourceAlpha" stdDeviation="13"/>
      <feOffset dy="9"/>
      <feComponentTransfer><feFuncA type="linear" slope="0.18"/></feComponentTransfer>
      <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <filter id="cardshadow" x="-15%" y="-15%" width="130%" height="130%">
      <feGaussianBlur in="SourceAlpha" stdDeviation="18"/>
      <feOffset dy="14"/>
      <feComponentTransfer><feFuncA type="linear" slope="0.22"/></feComponentTransfer>
      <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>`;
}

function bloom() {
  const petals = EMOTIONS.map(
    (_, i) =>
      `<g transform="rotate(${i * 45} 512 512)"><path d="${PETAL}" fill="url(#grad${i})" stroke="#ffffff" stroke-width="7" stroke-linejoin="round"/></g>`
  ).join('');
  return `<g filter="url(#softshadow)">${petals}
    <circle cx="512" cy="512" r="120" fill="url(#hub)" stroke="#e6e9ee" stroke-width="5"/>
    <circle cx="512" cy="512" r="78" fill="none" stroke="#eef1f5" stroke-width="4"/>
  </g>`;
}

// Full bloom, optionally on a background, scaled about the centre.
function iconSvg({ scale = 1, bg = null } = {}) {
  const bgRect = bg ? `<rect width="1024" height="1024" fill="${bg}"/>` : '';
  const inner = `<g transform="translate(512 512) scale(${scale}) translate(-512 -512)">${bloom()}</g>`;
  return `<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">${defs()}${bgRect}${inner}</svg>`;
}

// macOS: rounded white card with margin (native macOS icon grid), bloom inside.
function macSvg() {
  const inset = 100;
  const size = 1024 - 2 * inset;
  const card = `<g filter="url(#cardshadow)"><rect x="${inset}" y="${inset}" width="${size}" height="${size}" rx="190" ry="190" fill="#ffffff"/></g>`;
  const inner = `<g transform="translate(512 512) scale(0.60) translate(-512 -512)">${bloom()}</g>`;
  return `<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">${defs()}${card}${inner}</svg>`;
}

// Three reusable compositions.
const SVG = {
  full: iconSvg({ scale: 1, bg: '#ffffff' }),       // full-bleed, white background
  foreground: iconSvg({ scale: 0.7 }),              // transparent, inside adaptive/maskable safe zone
  splash: iconSvg({ scale: 0.86 }),                 // transparent, prominent centred mark
  mac: macSvg(),
};

// ---------------------------------------------------------------------------
// Rasterization helpers
// ---------------------------------------------------------------------------

function renderPng(svg, size) {
  const r = new Resvg(svg, { fitTo: { mode: 'width', value: size }, background: 'rgba(0,0,0,0)' });
  return Buffer.from(r.render().asPng());
}

async function write(buf, ...path) {
  const out = p(...path);
  await mkdir(dirname(out), { recursive: true });
  await writeFile(out, buf);
  return out;
}

// PNG with no alpha channel, composited over white (required for iOS marketing icon).
async function flat(svg, size) {
  return sharp(renderPng(svg, size)).flatten({ background: '#ffffff' }).png().toBuffer();
}

const log = (label, file) => console.log(`  ${label.padEnd(22)} ${file.replace(ROOT + '/', '')}`);

// ---------------------------------------------------------------------------
// Per-platform generation
// ---------------------------------------------------------------------------

async function genIOS() {
  console.log('iOS');
  const dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
  const icons = {
    'Icon-App-20x20@1x.png': 20, 'Icon-App-20x20@2x.png': 40, 'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29, 'Icon-App-29x29@2x.png': 58, 'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40, 'Icon-App-40x40@2x.png': 80, 'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120, 'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76, 'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167, 'Icon-App-1024x1024@1x.png': 1024,
  };
  for (const [name, size] of Object.entries(icons)) {
    const f = await write(await flat(SVG.full, size), dir, name); // iOS icons: opaque, no alpha
    log(name, f);
  }
  // Launch image (splash) — centred by storyboard on white; transparent png.
  const li = 'ios/Runner/Assets.xcassets/LaunchImage.imageset';
  for (const [name, size] of [['LaunchImage.png', 220], ['LaunchImage@2x.png', 440], ['LaunchImage@3x.png', 660]]) {
    const f = await write(renderPng(SVG.splash, size), li, name);
    log(name, f);
  }
}

async function genAndroid() {
  console.log('Android');
  const base = 'android/app/src/main/res';
  const legacy = { mdpi: 48, hdpi: 72, xhdpi: 96, xxhdpi: 144, xxxhdpi: 192 };
  const fg = { mdpi: 108, hdpi: 162, xhdpi: 216, xxhdpi: 324, xxxhdpi: 432 };
  const splash = { mdpi: 200, hdpi: 300, xhdpi: 400, xxhdpi: 600, xxxhdpi: 800 };

  for (const [d, s] of Object.entries(legacy)) {
    const f = await write(await flat(SVG.full, s), base, `mipmap-${d}`, 'ic_launcher.png');
    log(`ic_launcher ${d}`, f);
  }
  for (const [d, s] of Object.entries(fg)) {
    const f = await write(renderPng(SVG.foreground, s), base, `mipmap-${d}`, 'ic_launcher_foreground.png');
    log(`foreground ${d}`, f);
  }
  for (const [d, s] of Object.entries(splash)) {
    const f = await write(renderPng(SVG.splash, s), base, `drawable-${d}`, 'splash_logo.png');
    log(`splash ${d}`, f);
  }
}

async function genWeb() {
  console.log('Web');
  for (const [name, size] of [['Icon-192.png', 192], ['Icon-512.png', 512]]) {
    const f = await write(await flat(SVG.full, size), 'web/icons', name);
    log(name, f);
  }
  // Maskable: safe-zone mark composited on white (opaque) so launchers can crop any shape.
  for (const [name, size] of [['Icon-maskable-192.png', 192], ['Icon-maskable-512.png', 512]]) {
    const f = await write(await flat(SVG.foreground, size), 'web/icons', name);
    log(name, f);
  }
  log('favicon.png', await write(await flat(SVG.full, 64), 'web/favicon.png'));
}

async function genMac() {
  console.log('macOS');
  const dir = 'macos/Runner/Assets.xcassets/AppIcon.appiconset';
  // Keep alpha: macOS icons have transparent corners around the rounded card.
  for (const size of [16, 32, 64, 128, 256, 512, 1024]) {
    const f = await write(renderPng(SVG.mac, size), dir, `app_icon_${size}.png`);
    log(`app_icon_${size}`, f);
  }
}

async function genWindows() {
  console.log('Windows');
  const sizes = [16, 24, 32, 48, 64, 128, 256];
  const buffers = await Promise.all(sizes.map((s) => flat(SVG.full, s)));
  const ico = await pngToIco(buffers);
  log('app_icon.ico', await write(ico, 'windows/runner/resources/app_icon.ico'));
}

async function genSources() {
  console.log('SVG sources (design/)');
  log('icon.svg', await write(Buffer.from(SVG.full), 'design/icon.svg'));
  log('icon-foreground.svg', await write(Buffer.from(SVG.foreground), 'design/icon-foreground.svg'));
  log('splash.svg', await write(Buffer.from(SVG.splash), 'design/splash.svg'));
  log('icon-macos.svg', await write(Buffer.from(SVG.mac), 'design/icon-macos.svg'));
}

async function genPreview() {
  console.log('Preview');
  const pad = 40;
  const big = 320;
  const smalls = [16, 24, 32, 48, 64, 96];
  const width = big * 2 + pad * 3;
  const height = big + pad * 3 + 96;
  const checker = `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}"><rect width="100%" height="100%" fill="#cfd4da"/></svg>`;
  const layers = [];
  // full-bleed (with white bg) and foreground-on-grey, side by side
  layers.push({ input: await sharp(renderPng(SVG.full, big)).png().toBuffer(), left: pad, top: pad });
  layers.push({ input: renderPng(SVG.foreground, big), left: pad * 2 + big, top: pad });
  // a row of small full-bleed icons to check legibility
  let x = pad;
  const rowTop = big + pad * 2;
  for (const s of smalls) {
    layers.push({ input: await flat(SVG.full, s), left: x, top: rowTop + (96 - s) });
    x += s + 24;
  }
  const buf = await sharp(Buffer.from(checker)).composite(layers).png().toBuffer();
  log('preview.png', await write(buf, 'design/preview.png'));
}

// ---------------------------------------------------------------------------

async function main() {
  await genSources();
  await genIOS();
  await genAndroid();
  await genWeb();
  await genMac();
  await genWindows();
  await genPreview();
  console.log('\nDone.');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
