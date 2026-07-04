from PIL import Image, ImageDraw, ImageFont

art = open("ultra-nightmare.ascii.txt").read()
lines = art.split("\n")

font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
font_size = 14
font = ImageFont.truetype(font_path, font_size)

char_width = font.getlength("M")
char_height = font_size * 1.2

max_line_len = max(len(l) for l in lines) if lines else 0
img_width = int(char_width * max_line_len)
img_height = int(char_height * len(lines))

# Bad Blood theme colors
FOREGROUND = (255, 34, 34, 255)   # #FF2222 - main text color
BACKGROUND = (4, 0, 0, 0)         # #040000 - kept fully transparent (alpha=0)
                                    # since it's a background image already

img = Image.new("RGBA", (img_width, img_height), BACKGROUND)
draw = ImageDraw.Draw(img)

for i, line in enumerate(lines):
    y = int(i * char_height)
    draw.text((0, y), line, font=font, fill=FOREGROUND)

img.save("ultra-nightmare-ascii.png")
print(f"Image size: {img_width}x{img_height}, aspect ratio: {img_width/img_height:.3f}")