#!/usr/bin/env python3
"""
ascii_to_img.py — Render ASCII art text as a transparent PNG for terminal image protocols.

Usage:
    python ascii_to_img.py [input.ascii.txt] [--output out.png] [--font PATH] [--size 14]
"""

import argparse
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

DEFAULT_FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
FOREGROUND = (255, 34, 34, 255)   # #FF2222 — Bad Blood theme
BACKGROUND = (4, 0, 0, 0)        # transparent


def ascii_to_image(
    art: str,
    font_path: str,
    font_size: int,
) -> Image.Image:
    lines = art.splitlines()
    font = ImageFont.truetype(font_path, font_size)

    char_width = font.getlength("M")
    char_height = font_size * 1.2

    max_line_len = max(len(line) for line in lines) if lines else 0
    img_width = int(char_width * max_line_len)
    img_height = int(char_height * len(lines))

    img = Image.new("RGBA", (img_width, img_height), BACKGROUND)
    draw = ImageDraw.Draw(img)

    for i, line in enumerate(lines):
        y = int(i * char_height)
        draw.text((0, y), line, font=font, fill=FOREGROUND)

    return img


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Convert ASCII art text to a transparent PNG.")
    p.add_argument(
        "input",
        nargs="?",
        default="doomguy-logo.ascii.txt",
        help="ASCII art text file (default: doomguy-logo.ascii.txt)",
    )
    p.add_argument(
        "--output", "-o",
        default=None,
        help="Output PNG path (default: <input-stem>-ascii.png)",
    )
    p.add_argument("--font", default=DEFAULT_FONT, help="Monospace font path")
    p.add_argument("--size", type=int, default=14, help="Font size in points")
    return p.parse_args()


def main() -> None:
    args = parse_args()

    src = Path(args.input)
    if not src.exists():
        print(f"[error] File not found: {src}", file=sys.stderr)
        sys.exit(1)

    out = Path(args.output) if args.output else src.with_name(f"{src.stem.rsplit('.ascii', 1)[0]}-ascii.png")

    art = src.read_text(encoding="utf-8")
    img = ascii_to_image(art, args.font, args.size)
    img.save(out)

    w, h = img.size
    print(f"Saved → {out}", file=sys.stderr)
    print(f"Image size: {w}x{h}, aspect ratio: {w / h:.3f}")


if __name__ == "__main__":
    main()