"""Regenerates every platform app icon from assets/branding/app_icon_source.png.

    python3 tool/generate_icons.py

The source has its squircle baked in (transparent corners). iOS wants an
opaque square and applies its own mask, so its icons are flattened onto the
icon's white. Android gets the squircle as the legacy icon, and an adaptive
icon whose foreground is the flattened square inside the 72dp safe viewport.
"""
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "assets/branding/app_icon_source.png"
WHITE = (255, 255, 255, 255)


def flattened(src: Image.Image) -> Image.Image:
    base = Image.new("RGBA", src.size, WHITE)
    base.alpha_composite(src)
    return base.convert("RGB")


def resized(img: Image.Image, px: int) -> Image.Image:
    return img.resize((px, px), Image.LANCZOS)


def ios(src: Image.Image) -> None:
    folder = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    flat = flattened(src)
    contents = json.loads((folder / "Contents.json").read_text())
    for entry in contents["images"]:
        size = float(entry["size"].split("x")[0])
        scale = int(entry["scale"].rstrip("x"))
        resized(flat, round(size * scale)).save(folder / entry["filename"])


def android(src: Image.Image) -> None:
    res = ROOT / "android/app/src/main/res"
    densities = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
    flat = flattened(src).convert("RGBA")
    for name, scale in densities.items():
        folder = res / f"mipmap-{name}"
        folder.mkdir(exist_ok=True)
        # Legacy launchers: the squircle as drawn.
        resized(src, round(48 * scale)).save(folder / "ic_launcher.png")
        # Adaptive foreground: 108dp canvas, art filling the 72dp viewport.
        canvas_px = round(108 * scale)
        art_px = round(72 * scale)
        canvas = Image.new("RGBA", (canvas_px, canvas_px), (0, 0, 0, 0))
        offset = (canvas_px - art_px) // 2
        canvas.alpha_composite(resized(flat, art_px), (offset, offset))
        canvas.save(folder / "ic_launcher_foreground.png")

    anydpi = res / "mipmap-anydpi-v26"
    anydpi.mkdir(exist_ok=True)
    (anydpi / "ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background" />\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
        "</adaptive-icon>\n"
    )
    (res / "values/ic_launcher_background.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        "<resources>\n"
        '    <color name="ic_launcher_background">#FFFFFF</color>\n'
        "</resources>\n"
    )


if __name__ == "__main__":
    image = Image.open(SOURCE).convert("RGBA")
    ios(image)
    android(image)
    print("Icons regenerated from", SOURCE.relative_to(ROOT))
