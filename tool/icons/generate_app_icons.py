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


def main():
    extract_circle()


if __name__ == "__main__":
    main()
