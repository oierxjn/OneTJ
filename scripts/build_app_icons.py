#!/usr/bin/env python3
"""Rebuild every app-icon artifact from the artist master.

Source of truth: assets/icon/origin.png (square, RGBA, ~1254px).

Nothing here is hand-edited downstream: run this script after replacing
origin.png and every platform icon is regenerated consistently.

    python scripts/build_app_icons.py

Outputs
-------
Flutter / installer
  assets/icon/logo.png              256px asset used in-app (about page)
  assets/icon/logo.ico              multi-size .ico for the app + installer
  windows/runner/resources/logo.ico copy referenced by windows/runner/Runner.rc

Android
  the legacy mipmap-*/launcher_icon.png fallback is generated separately by
  `dart run flutter_launcher_icons` (see pubspec.yaml); it reads origin.png
  directly. The adaptive icon (API 26+) is built here, because
  flutter_launcher_icons cannot derive a foreground layer on its own:
    drawable-*/ic_launcher_foreground.png   artwork, field colour removed
    mipmap-anydpi-v26/launcher_icon.xml     background colour + foreground
    values/colors.xml                       ic_launcher_background = field

iOS / macOS / web
  Regenerated in place under their existing filenames. The asset-catalog
  Contents.json files are parsed rather than guessed, so this script never
  writes a file the catalogs do not already reference (and never adds orphans,
  unlike the flutter_launcher_icons iOS generator).

HarmonyOS
  ohos/entry/src/main/resources/base/media/logo.jpg      startWindowIcon
  ohos/AppScope/resources/base/media/background.png      layered icon, back
  ohos/AppScope/resources/base/media/foreground.png      layered icon, front

Rationale for per-platform treatment
------------------------------------
Android ships both a legacy icon and an adaptive icon. Without the adaptive
icon, Android 8+ applies the legacy fallback: it shrinks the whole badge into
the centre of a white rounded-square plate, which buries the artwork in white
padding. The adaptive icon instead draws the artwork alone on a full-bleed
brand-coloured field, so the launcher mask (circle / squircle / rounded
square) crops the field, not the emblem. The ~66/108 inner safe area keeps the
artwork clear of every mask shape.

iOS, macOS and web get the badge flattened onto the badge's own border colour,
so the rounded frame blends into a seamless full-bleed tile. iOS applies its
own squircle mask and forbids alpha in App Store icons, so a full-bleed tile
avoids both a double-rounded artefact and a validation failure.
"""
from __future__ import annotations

import json
import os
import shutil
import sys

import numpy as np
from PIL import Image

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(REPO)

MASTER = "assets/icon/origin.png"
IN_APP_ASSET = "assets/icon/logo.png"
ICO_SIZES = (16, 24, 32, 48, 64, 128, 256)
ICO_SIZES_OUT = ["assets/icon/logo.ico"]
ICO_COPY = "windows/runner/resources/logo.ico"

IOS_DIR = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
MACOS_DIR = "macos/Runner/Assets.xcassets/AppIcon.appiconset"

# web/icons/Icon-*.png are square already; favicon is a standalone png.
WEB_FILES = {
    "web/favicon.png": 64,
    "web/icons/Icon-192.png": 192,
    "web/icons/Icon-512.png": 512,
    "web/icons/Icon-maskable-192.png": 192,
    "web/icons/Icon-maskable-512.png": 512,
}
# maskable icons need their art inside the inner 80% so launcher masks
# (circle / squircle / rounded square) cannot clip the emblem.
WEB_MASKABLE = {"web/icons/Icon-maskable-192.png", "web/icons/Icon-maskable-512.png"}

OHOS_START_WINDOW = "ohos/entry/src/main/resources/base/media/logo.jpg"
OHOS_LAYER_BACK = "ohos/AppScope/resources/base/media/background.png"
OHOS_LAYER_FRONT = "ohos/AppScope/resources/base/media/foreground.png"
OHOS_LAYER_SIZE = 1024
# Share of the layered-icon canvas the foreground emblem may occupy.
OHOS_FOREGROUND_SAFE = 0.72

# Adaptive icon: the canvas is 108x108dp but only the central 66dp is
# guaranteed visible; a circular mask keeps the inscribed square of the
# canvas (1/sqrt(2) = 0.707). 0.70 therefore survives every launcher mask
# shape (circle / squircle / rounded square / teardrop) without clipping the
# emblem, while still reading as a full-bleed badge.
ANDROID_FOREGROUND_DIRS = {
    "android/app/src/main/res/drawable-mdpi": 108,
    "android/app/src/main/res/drawable-hdpi": 162,
    "android/app/src/main/res/drawable-xhdpi": 216,
    "android/app/src/main/res/drawable-xxhdpi": 324,
    "android/app/src/main/res/drawable-xxxhdpi": 432,
}
ANDROID_FOREGROUND_SAFE = 0.70
ANDROID_FOREGROUND_NAME = "ic_launcher_foreground.png"
ANDROID_ADAPTIVE_XML = "android/app/src/main/res/mipmap-anydpi-v26/launcher_icon.xml"
ANDROID_COLORS_XML = "android/app/src/main/res/values/colors.xml"
ANDROID_ICON_NAME = "launcher_icon"
ANDROID_BACKGROUND_COLOR_NAME = "ic_launcher_background"

# Distance-from-field thresholds for the soft key that separates artwork from
# the badge's blue field. The field is flat to within ~3/255, so 24 sits well
# clear of noise while keeping faint artwork (e.g. pale-blue clouds) intact.
KEY_LO, KEY_HI = 24.0, 56.0

DEFAULT_FIELD = (1, 91, 171)  # #015BAB, badge border; overridden by measurement


def load_master() -> Image.Image:
    if not os.path.isfile(MASTER):
        sys.exit(f"master not found: {MASTER}")
    im = Image.open(MASTER)
    if im.width != im.height:
        sys.exit(f"master must be square, got {im.size}")
    return im.convert("RGBA")


def resize(im: Image.Image, size: int) -> Image.Image:
    return im.resize((size, size), Image.LANCZOS, reducing_gap=3.0)


def measure_field_colour(master: Image.Image) -> tuple[int, int, int]:
    """Median colour of the outermost opaque ring of the badge."""
    a = np.asarray(master)
    alpha = a[..., 3]
    opaque = alpha > 200
    # erode 1px, the ring is everything opaque that erosion removed
    eroded = opaque.copy()
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            eroded &= np.roll(np.roll(opaque, dy, 0), dx, 1)
    ring = opaque & ~eroded
    px = a[..., :3][ring]
    if not len(px):
        return DEFAULT_FIELD
    med = np.median(px, axis=0).astype(int)
    return int(med[0]), int(med[1]), int(med[2])


def flattened(master: Image.Image, size: int, field: tuple[int, int, int],
              safe: float = 1.0) -> Image.Image:
    """Badge composited onto `field`, emblem optionally inset to `safe`."""
    tile = Image.new("RGBA", (size, size), field + (255,))
    inner = max(1, int(size * safe))
    tile.alpha_composite(resize(master, inner), ((size - inner) // 2,) * 2)
    return tile


def write_ico(master: Image.Image) -> None:
    path = ICO_SIZES_OUT[0]
    master.save(path, format="ICO", sizes=[(s, s) for s in ICO_SIZES])
    os.makedirs(os.path.dirname(ICO_COPY), exist_ok=True)
    shutil.copyfile(path, ICO_COPY)
    print(f"  ico  {path} ({os.path.getsize(path)} B) sizes={list(ICO_SIZES)}")
    print(f"       -> {ICO_COPY}")


def read_catalog_filenames(contents_path: str) -> list[tuple[str, int]]:
    """Parse (filename, pixel size) pairs out of an appiconset Contents.json."""
    with open(contents_path, encoding="utf-8") as fh:
        data = json.load(fh)
    out: list[tuple[str, int]] = []
    for entry in data.get("images", []):
        name = entry.get("filename")
        spec = entry.get("size")  # e.g. "83.5x83.5"
        scale = entry.get("scale")  # e.g. "2x"
        if not name or not spec or not scale:
            continue
        side = float(spec.split("x")[0])
        px = round(side * float(scale.rstrip("x")))
        out.append((name, px))
    return out


def rebuild_catalog(dir_path: str, field: tuple[int, int, int]) -> int:
    contents = os.path.join(dir_path, "Contents.json")
    if not os.path.isfile(contents):
        print(f"  skip {dir_path} (no Contents.json)")
        return 0
    entries = read_catalog_filenames(contents)
    for name, px in entries:
        flattened(master_ref, px, field).convert("RGB").save(
            os.path.join(dir_path, name), optimize=True)
    # Warn about files nothing references, so catalogs stay clean.
    declared = {n for n, _ in entries}
    actual = {f for f in os.listdir(dir_path)
              if f.lower().endswith(".png")}
    orphans = sorted(actual - declared)
    print(f"  {dir_path}: {len(entries)} icons"
          + (f"  ORPHANS={orphans}" if orphans else ""))
    return len(entries)


def rebuild_web(field: tuple[int, int, int]) -> None:
    for path, size in WEB_FILES.items():
        safe = 0.80 if path in WEB_MASKABLE else 1.0
        os.makedirs(os.path.dirname(path), exist_ok=True)
        flattened(master_ref, size, field, safe).convert("RGB").save(
            path, optimize=True)
    print(f"  web: {len(WEB_FILES)} icons")


def measure_interior_field(master: Image.Image) -> tuple[int, int, int]:
    """Median colour of the badge's flat interior field.

    `measure_field_colour` samples the outermost opaque ring, which is the
    anti-aliased rounded-corner edge and therefore slightly darker/noisier
    than the flat fill the artwork sits on. The adaptive background must match
    the artwork's own backdrop exactly, so this samples the interior, where the
    pixel population is a two-mode mix of brand blue and white emblem; taking
    the median over only the blue cluster (blue channel well above red) picks
    the field rather than splitting the difference between the two.
    """
    a = np.asarray(master)
    alpha = a[..., 3]
    rgb = a[..., :3]
    opaque = alpha > 250

    # erode away the anti-aliased rounded border and the transparent surround
    interior = opaque.copy()
    for _ in range(20):
        interior = (interior
                    & np.roll(interior, 1, 0) & np.roll(interior, -1, 0)
                    & np.roll(interior, 1, 1) & np.roll(interior, -1, 1))

    blue = interior & ((rgb[..., 2].astype(int) - rgb[..., 0].astype(int)) > 60)
    px = rgb[blue]
    if not len(px):
        return DEFAULT_FIELD
    med = np.median(px, axis=0).astype(int)
    return int(med[0]), int(med[1]), int(med[2])


def build_android_foreground(master: Image.Image, size: int,
                             field: tuple[int, int, int]) -> Image.Image:
    """One adaptive foreground layer, emblem inset to the mask-safe area."""
    inner = max(1, round(size * ANDROID_FOREGROUND_SAFE))
    # Resize colour and alpha independently at full resolution, then key the
    # field out only once: keying before scaling would let the resize blur the
    # softened edges back into the field colour.
    scaled = resize(master, inner)
    a = np.asarray(scaled).astype(float)
    dist = np.sqrt(((a[..., :3] - np.array(field)) ** 2).sum(-1))
    key = np.clip((dist - KEY_LO) / (KEY_HI - KEY_LO), 0.0, 1.0)
    rgba = a.copy()
    rgba[..., 3] = a[..., 3] * key
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    off = (size - inner) // 2
    layer.alpha_composite(Image.fromarray(rgba.astype(np.uint8), "RGBA"), (off, off))
    return layer


def rebuild_android_adaptive(master: Image.Image, field: tuple[int, int, int]) -> None:
    for dir_path, size in ANDROID_FOREGROUND_DIRS.items():
        os.makedirs(dir_path, exist_ok=True)
        build_android_foreground(master, size, field).save(
            os.path.join(dir_path, ANDROID_FOREGROUND_NAME), optimize=True)

    os.makedirs(os.path.dirname(ANDROID_ADAPTIVE_XML), exist_ok=True)
    with open(ANDROID_ADAPTIVE_XML, "w", encoding="utf-8") as fh:
        fh.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            f'  <background android:drawable="@color/{ANDROID_BACKGROUND_COLOR_NAME}"/>\n'
            f'  <foreground android:drawable="@drawable/ic_launcher_foreground"/>\n'
            '</adaptive-icon>\n')

    _upsert_android_background_colour(field)
    print(f"  adaptive: {len(ANDROID_FOREGROUND_DIRS)} foreground layers "
          f"+ {ANDROID_ADAPTIVE_XML}")


def _upsert_android_background_colour(field: tuple[int, int, int]) -> None:
    """Set ic_launcher_background in values/colors.xml, creating the file."""
    colour = "#FF%02X%02X%02X" % field
    os.makedirs(os.path.dirname(ANDROID_COLORS_XML), exist_ok=True)
    entry = f'    <color name="{ANDROID_BACKGROUND_COLOR_NAME}">{colour}</color>'
    if os.path.isfile(ANDROID_COLORS_XML):
        with open(ANDROID_COLORS_XML, encoding="utf-8") as fh:
            lines = fh.read().splitlines()
        for i, line in enumerate(lines):
            if f'name="{ANDROID_BACKGROUND_COLOR_NAME}"' in line:
                lines[i] = entry
                break
        else:
            # keep </resources> last
            idx = next((i for i, l in enumerate(lines) if "</resources>" in l),
                       len(lines))
            lines.insert(idx, entry)
        text = "\n".join(lines).rstrip("\n") + "\n"
    else:
        text = ('<?xml version="1.0" encoding="utf-8"?>\n'
                '<resources>\n'
                f'{entry}\n'
                '</resources>\n')
    with open(ANDROID_COLORS_XML, "w", encoding="utf-8") as fh:
        fh.write(text)


def rebuild_ohos(master: Image.Image, field: tuple[int, int, int]) -> None:    # start window: plain square thumbnail, matching the old jpg behaviour
    os.makedirs(os.path.dirname(OHOS_START_WINDOW), exist_ok=True)
    flattened(master, 512, field).convert("RGB").save(
        OHOS_START_WINDOW, quality=92)

    # layered icon: solid brand field + emblem in the safe area
    os.makedirs(os.path.dirname(OHOS_LAYER_BACK), exist_ok=True)
    Image.new("RGB", (OHOS_LAYER_SIZE,) * 2, field).save(OHOS_LAYER_BACK,
                                                         optimize=True)
    front = Image.new("RGBA", (OHOS_LAYER_SIZE,) * 2, (0, 0, 0, 0))
    inner = int(OHOS_LAYER_SIZE * OHOS_FOREGROUND_SAFE)
    front.alpha_composite(resize(master, inner), ((OHOS_LAYER_SIZE - inner) // 2,) * 2)
    front.save(OHOS_LAYER_FRONT, optimize=True)
    print(f"  ohos: {OHOS_START_WINDOW} + layered back/foreground")


master_ref: Image.Image  # set in main(), used by helpers


def main() -> None:
    global master_ref
    master = load_master()
    master_ref = master
    field = measure_field_colour(master)
    print(f"master : {MASTER} {master.size}")
    print(f"field  : #{field[0]:02X}{field[1]:02X}{field[2]:02X} "
          f"(badge border, used to flatten opaque platforms)")

    print("flutter / installer")
    os.makedirs(os.path.dirname(IN_APP_ASSET), exist_ok=True)
    resize(master, 256).save(IN_APP_ASSET, optimize=True)
    print(f"  asset {IN_APP_ASSET} 256px ({os.path.getsize(IN_APP_ASSET)} B)")
    write_ico(resize(master, 256))

    print("ios / macos")
    rebuild_catalog(IOS_DIR, field)
    rebuild_catalog(MACOS_DIR, field)

    print("web")
    rebuild_web(field)

    print("android")
    rebuild_android_adaptive(master, measure_interior_field(master))

    print("ohos")
    rebuild_ohos(master, field)

    print("\ndone. android legacy mipmaps are produced by: "
          "fvm dart run flutter_launcher_icons")


if __name__ == "__main__":
    main()
