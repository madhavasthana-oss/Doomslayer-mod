#!/usr/bin/env python3
"""
img_to_ascii.py — Convert any image to ASCII art
Usage:
    python img_to_ascii.py <image_path> [--width 100] [--output out.txt] [--invert] [--charset simple|detailed|blocks]
"""

import argparse
import sys
from pathlib import Path
from PIL import Image

# ── Character sets ────────────────────────────────────────────────────────────

CHARSETS = {
    "simple":   " .:-=+*#%@",
    "detailed": " .'`^\",:;Il!i><~+_-?][}{1)(|\\/tfjrxnuvczXYUJCLQ0OZmwqpdbkhao*#MW&8%B@$",
    "blocks":   " ░▒▓█",
}

# ── Core logic ────────────────────────────────────────────────────────────────

# Terminal characters are roughly twice as tall as wide.
# We compress height by this factor so the output looks proportional.
CHAR_ASPECT = 0.45


def image_to_ascii(
    image_path: str,
    width: int = 100,
    charset: str = "detailed",
    invert: bool = False,
) -> str:
    """Return ASCII art string for the given image file."""
    chars = CHARSETS.get(charset, CHARSETS["detailed"])
    if invert:
        chars = chars[::-1]

    img = Image.open(image_path).convert("L")  # grayscale

    orig_w, orig_h = img.size
    height = int(orig_h / orig_w * width * CHAR_ASPECT)
    img = img.resize((width, height), Image.LANCZOS)

    px = img.load()
    pixels = [px[x, y] for y in range(height) for x in range(width)]
    n = len(chars) - 1

    lines = []
    for row in range(height):
        row_pixels = pixels[row * width : (row + 1) * width]
        line = "".join(chars[int(p / 255 * n)] for p in row_pixels)
        lines.append(line)

    return "\n".join(lines)


# ── CLI ───────────────────────────────────────────────────────────────────────

def parse_args():
    p = argparse.ArgumentParser(
        description="Convert an image to ASCII art with correct aspect ratio."
    )
    p.add_argument("image", help="Path to the input image")
    p.add_argument(
        "--width", type=int, default=100,
        help="Width in characters (default: 100)"
    )
    p.add_argument(
        "--output", "-o", default=None,
        help="Save result to this file instead of printing to stdout"
    )
    p.add_argument(
        "--charset", choices=list(CHARSETS.keys()), default="detailed",
        help="Character density set to use (default: detailed)"
    )
    p.add_argument(
        "--invert", action="store_true",
        help="Invert brightness (useful for dark-background terminals)"
    )
    return p.parse_args()


def main():
    args = parse_args()

    path = Path(args.image)
    if not path.exists():
        print(f"[error] File not found: {path}", file=sys.stderr)
        sys.exit(1)

    print(f"Converting '{path.name}'  width={args.width}  charset={args.charset}", file=sys.stderr)

    art = image_to_ascii(
        str(path),
        width=args.width,
        charset=args.charset,
        invert=args.invert,
    )

    if args.output:
        out = Path(args.output)
        out.write_text(art, encoding="utf-8")
        print(f"Saved → {out}", file=sys.stderr)
    else:
        print(art)


if __name__ == "__main__":
    main()