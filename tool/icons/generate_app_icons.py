#!/usr/bin/env python3
"""Regenerate Daylight app launcher icons for all platforms from the source artwork."""
import os
from PIL import Image, ImageDraw

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(SCRIPT_DIR))
SOURCE_DIR = os.path.join(SCRIPT_DIR, "source")
SOURCE_JPG = os.path.join(SOURCE_DIR, "app_icon_original.jpg")
CIRCLE_PNG = os.path.join(SOURCE_DIR, "app_icon_circle.png")
MASTER_PNG = os.path.join(SOURCE_DIR, "app_icon_master_1024.png")

# Bounding box (left, top, right, bottom) of the blue circle artwork within
# app_icon_original.jpg, measured by color-sampling the source image.
CIRCLE_BBOX = (400, 78, 1006, 686)  # 606 x 608 px

# Dominant blue sampled from the circle interior (#4DA0D6).
BG_COLOR = (77, 160, 214)


def extract_circle():
    """Crop the source JPEG to the circle artwork and apply a circular alpha mask."""
    img = Image.open(SOURCE_JPG).convert("RGB")
    cropped = img.crop(CIRCLE_BBOX)
    w, h = cropped.size
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, w, h), fill=255)
    circle = cropped.convert("RGBA")
    circle.putalpha(mask)
    circle.save(CIRCLE_PNG)
    print(f"Saved {CIRCLE_PNG} ({w}x{h})")


def make_square_master(circle, size):
    """Composite the circular artwork onto a full-bleed square of BG_COLOR.

    Resizing the circle to exactly `size x size` makes its diameter match the
    canvas, so the transparent corners reveal the same BG_COLOR behind it —
    the circle's edge disappears and the result is a seamless solid-color
    square with the artwork centered.
    """
    resized = circle.resize((size, size), Image.LANCZOS)
    master = Image.new("RGB", (size, size), BG_COLOR)
    master.paste(resized, (0, 0), resized)
    return master


def generate_master():
    circle = Image.open(CIRCLE_PNG)
    master = make_square_master(circle, 1024)
    master.save(MASTER_PNG)
    print(f"Saved {MASTER_PNG} (1024x1024)")


IOS_DIR = os.path.join(REPO_ROOT, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
IOS_SIZES = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}


def generate_ios():
    master = Image.open(MASTER_PNG)
    for filename, size in IOS_SIZES.items():
        master.resize((size, size), Image.LANCZOS).save(os.path.join(IOS_DIR, filename))
    print(f"Generated {len(IOS_SIZES)} iOS icons in {IOS_DIR}")


MACOS_DIR = os.path.join(REPO_ROOT, "macos", "Runner", "Assets.xcassets", "AppIcon.appiconset")
MACOS_SIZES = {
    "app_icon_16.png": 16,
    "app_icon_32.png": 32,
    "app_icon_64.png": 64,
    "app_icon_128.png": 128,
    "app_icon_256.png": 256,
    "app_icon_512.png": 512,
    "app_icon_1024.png": 1024,
}


def generate_macos():
    master = Image.open(MASTER_PNG)
    for filename, size in MACOS_SIZES.items():
        master.resize((size, size), Image.LANCZOS).save(os.path.join(MACOS_DIR, filename))
    print(f"Generated {len(MACOS_SIZES)} macOS icons in {MACOS_DIR}")


ANDROID_RES = os.path.join(REPO_ROOT, "android", "app", "src", "main", "res")
ANDROID_LEGACY_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}


def generate_android_legacy():
    master = Image.open(MASTER_PNG)
    for dirname, size in ANDROID_LEGACY_SIZES.items():
        out = master.resize((size, size), Image.LANCZOS)
        out.save(os.path.join(ANDROID_RES, dirname, "ic_launcher.png"))
    print(f"Generated {len(ANDROID_LEGACY_SIZES)} Android legacy icons")


def main():
    extract_circle()
    generate_master()
    generate_ios()
    generate_macos()
    generate_android_legacy()


if __name__ == "__main__":
    main()
