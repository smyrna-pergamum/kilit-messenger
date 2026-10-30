# Run from the repository root: python scripts/icon.py .
"""Draws Kilit's icon: a brass padlock on night blue. Writes the Android
launcher icons (legacy, adaptive, monochrome) and a large PNG for docs."""
import os, sys
from PIL import Image, ImageDraw, ImageFilter

repo = sys.argv[1]
res = os.path.join(repo, 'app/android/app/src/main/res')
S = 1024  # work size; everything is drawn at 4x and scaled down

NIGHT_TOP = (30, 38, 51)
NIGHT_BOT = (13, 17, 23)
BRASS_HI = (240, 196, 112)
BRASS = (224, 168, 74)
BRASS_LO = (168, 112, 30)
HOLE = (13, 17, 23)


def vgrad(w, h, top, bot):
    g = Image.new('RGB', (1, h))
    for y in range(h):
        t = y / (h - 1)
        g.putpixel((0, y), tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)))
    return g.resize((w, h))


def lock(size, mono=False):
    """The padlock alone on a transparent square of `size`, filling most of it."""
    k = 4
    W = size * k
    img = Image.new('RGBA', (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # proportions in a 100-unit box
    u = W / 100
    body = (18 * u, 44 * u, 82 * u, 92 * u)
    sh_w = 9.5 * u  # shackle thickness
    sh_box = (29 * u, 10 * u, 71 * u, 58 * u)
    fill = (255, 255, 255, 255) if mono else BRASS
    # shackle: a thick arc, then the two legs down into the body
    d.arc(sh_box, 180, 360, fill=fill if mono else BRASS_LO, width=int(sh_w))
    leg_top = (sh_box[1] + sh_box[3]) / 2
    for x in (sh_box[0], sh_box[2] - sh_w):
        d.rectangle((x, leg_top, x + sh_w, body[1] + 2 * u), fill=fill if mono else BRASS_LO)
    # body, with a brass gradient
    mask = Image.new('L', (W, W), 0)
    ImageDraw.Draw(mask).rounded_rectangle(body, radius=10 * u, fill=255)
    if mono:
        img.paste(Image.new('RGBA', (W, W), fill), (0, 0), mask)
    else:
        bh = int(body[3] - body[1])
        g = vgrad(int(body[2] - body[0]), bh, BRASS_HI, BRASS_LO).convert('RGBA')
        layer = Image.new('RGBA', (W, W), (0, 0, 0, 0))
        layer.paste(g, (int(body[0]), int(body[1])))
        img = Image.composite(layer, img, mask)
        d = ImageDraw.Draw(img)
        # a thin highlight along the top edge of the body
        d.rounded_rectangle((body[0] + 3 * u, body[1] + 2.2 * u, body[2] - 3 * u, body[1] + 4 * u),
                            radius=1 * u, fill=(255, 226, 160, 120))
    # keyhole: a circle and a tapering slot
    d = ImageDraw.Draw(img)
    cx, cy, r = 50 * u, 63 * u, 6.2 * u
    hole = (0, 0, 0, 0) if mono else HOLE
    if mono:
        cut = Image.new('L', (W, W), 0)
        cd = ImageDraw.Draw(cut)
        cd.ellipse((cx - r, cy - r, cx + r, cy + r), fill=255)
        cd.polygon([(cx - 3 * u, cy + 2 * u), (cx + 3 * u, cy + 2 * u), (cx + 4.2 * u, 81 * u), (cx - 4.2 * u, 81 * u)], fill=255)
        a = img.getchannel('A')
        a.paste(0, (0, 0), cut)
        img.putalpha(a)
    else:
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=hole)
        d.polygon([(cx - 3 * u, cy + 2 * u), (cx + 3 * u, cy + 2 * u), (cx + 4.2 * u, 81 * u), (cx - 4.2 * u, 81 * u)], fill=hole)
    return img.resize((size, size), Image.LANCZOS)


def full(size, rounded=True):
    """Legacy icon: night-blue square (rounded) with the lock in the middle."""
    k = 4
    W = size * k
    bg = vgrad(W, W, NIGHT_TOP, NIGHT_BOT).convert('RGBA')
    out = Image.new('RGBA', (W, W), (0, 0, 0, 0))
    m = Image.new('L', (W, W), 0)
    if rounded:
        ImageDraw.Draw(m).rounded_rectangle((0, 0, W - 1, W - 1), radius=int(W * 0.22), fill=255)
    else:
        m.paste(255, (0, 0, W, W))
    out.paste(bg, (0, 0), m)
    lk = lock(int(W * 0.62))
    # soft glow under the lock
    glow = Image.new('RGBA', (W, W), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse((W * 0.2, W * 0.25, W * 0.8, W * 0.85), fill=(224, 168, 74, 40))
    glow = glow.filter(ImageFilter.GaussianBlur(W * 0.08))
    out = Image.alpha_composite(out, Image.composite(glow, Image.new('RGBA', (W, W), (0, 0, 0, 0)), m))
    off = int((W - lk.width) / 2)
    out.alpha_composite(lk, (off, int(off * 0.95)))
    return out.resize((size, size), Image.LANCZOS)


def adaptive_fg(size, mono=False):
    """Adaptive foreground: 108dp canvas, the lock inside the 66dp safe zone."""
    out = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    lk = lock(int(size * 0.56), mono=mono)
    off = (size - lk.width) // 2
    out.alpha_composite(lk, (off, off))
    return out


dens = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
for name, f in dens.items():
    d = os.path.join(res, f'mipmap-{name}')
    os.makedirs(d, exist_ok=True)
    full(int(48 * f)).save(os.path.join(d, 'ic_launcher.png'))
    adaptive_fg(int(108 * f)).save(os.path.join(d, 'ic_launcher_foreground.png'))
    adaptive_fg(int(108 * f), mono=True).save(os.path.join(d, 'ic_launcher_monochrome.png'))

any_dir = os.path.join(res, 'mipmap-anydpi-v26')
os.makedirs(any_dir, exist_ok=True)
open(os.path.join(any_dir, 'ic_launcher.xml'), 'w', encoding='utf-8', newline='\n').write(
    '''<?xml version="1.0" encoding="utf-8"?>
<!-- Kilit's icon: a brass padlock on night blue (drawn by
     scripts/icon.py). Monochrome is for Android 13 themed icons. -->
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>
</adaptive-icon>
''')
open(os.path.join(res, 'values', 'ic_launcher_background.xml'), 'w', encoding='utf-8', newline='\n').write(
    '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#0D1117</color>
</resources>
''')

docs = os.path.join(repo, 'docs/assets')
os.makedirs(docs, exist_ok=True)
full(512).save(os.path.join(docs, 'icon.png'))
print('ok')
