# Run from the repository root: python scripts/stickers.py .
"""Draws Kilit's stickers: the brass padlock from the icon, with a face.
Writes app/assets/stickers/<name>.png (384 x 384, transparent). Own work,
under the project's licence; no words, so they read the same in every
language. A sticker travels as its name only; the app draws it."""
import math
import os
import sys

from PIL import Image, ImageDraw, ImageFilter

repo = sys.argv[1]
out_dir = os.path.join(repo, 'app/assets/stickers')
os.makedirs(out_dir, exist_ok=True)

W = 1024  # drawn large, scaled down at the end
OUT = 384
BRASS_HI = (243, 201, 118)
BRASS_LO = (176, 118, 34)
SHACKLE = (150, 100, 30)
INK = (34, 26, 18)
WHITE = (255, 255, 255)
BLUSH = (232, 120, 96, 120)
TEAR = (96, 170, 235)
HEART = (226, 70, 86)
GREEN = (63, 182, 139)
RED = (229, 83, 75)


def vgrad(w, h, top, bot):
    g = Image.new('RGB', (1, h))
    for y in range(h):
        t = y / max(1, h - 1)
        g.putpixel((0, y), tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)))
    return g.resize((w, h))


class Sticker:
    def __init__(self):
        self.img = Image.new('RGBA', (W, W), (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.img)
        # the lock's body; the face sits on it
        self.body = (232, 400, 792, 900)
        self.cx = (self.body[0] + self.body[2]) / 2
        self.eye_y = 590
        self.mouth_y = 720

    # ---- the lock
    def shackle(self, open_=False):
        d = self.d
        w = 74
        if open_:
            # popped up and turned a little, like a wave
            box = (300, 70, 640, 470)
            d.arc(box, 180, 360, fill=SHACKLE, width=w)
            d.rectangle((box[0], 270, box[0] + w, 330), fill=SHACKLE)
            d.rectangle((box[2] - w, 270, box[2], 420), fill=SHACKLE)
        else:
            box = (340, 160, 684, 560)
            d.arc(box, 180, 360, fill=SHACKLE, width=w)
            mid = (box[1] + box[3]) / 2
            for x in (box[0], box[2] - w):
                d.rectangle((x, mid, x + w, self.body[1] + 20), fill=SHACKLE)

    def lock_body(self):
        b = self.body
        mask = Image.new('L', (W, W), 0)
        ImageDraw.Draw(mask).rounded_rectangle(b, radius=90, fill=255)
        g = vgrad(b[2] - b[0], b[3] - b[1], BRASS_HI, BRASS_LO).convert('RGBA')
        layer = Image.new('RGBA', (W, W), (0, 0, 0, 0))
        layer.paste(g, (b[0], b[1]))
        self.img = Image.composite(layer, self.img, mask)
        self.d = ImageDraw.Draw(self.img)
        self.d.rounded_rectangle(b, radius=90, outline=INK, width=14)
        # a shine along the top
        self.d.rounded_rectangle((b[0] + 40, b[1] + 30, b[2] - 160, b[1] + 52), radius=12,
                                 fill=(255, 236, 190, 150))

    # ---- faces
    def eyes_dots(self, r=34, dy=0, dx=120):
        for s in (-1, 1):
            x, y = self.cx + s * dx, self.eye_y + dy
            self.d.ellipse((x - r, y - r * 1.2, x + r, y + r * 1.2), fill=INK)
            self.d.ellipse((x - r * 0.25, y - r * 0.8, x + r * 0.35, y - r * 0.2), fill=WHITE)

    def eyes_wide(self):
        for s in (-1, 1):
            x, y = self.cx + s * 125, self.eye_y
            self.d.ellipse((x - 62, y - 70, x + 62, y + 70), fill=WHITE, outline=INK, width=12)
            self.d.ellipse((x - 26, y - 26, x + 26, y + 26), fill=INK)

    def eyes_happy(self):
        for s in (-1, 1):
            x, y = self.cx + s * 120, self.eye_y + 10
            self.d.arc((x - 55, y - 45, x + 55, y + 55), 200, 340, fill=INK, width=18)

    def eyes_closed(self):
        for s in (-1, 1):
            x, y = self.cx + s * 120, self.eye_y + 10
            self.d.arc((x - 55, y - 60, x + 55, y + 20), 20, 160, fill=INK, width=16)

    def eyes_hearts(self):
        for s in (-1, 1):
            self.heart(self.cx + s * 120, self.eye_y, 62, HEART)

    def brows(self, kind):
        for s in (-1, 1):
            x, y = self.cx + s * 120, self.eye_y - 95
            # s points away from the middle: the inner end is at x - s * 60
            if kind == 'angry':
                self.d.line((x - s * 60, y + 25, x + s * 50, y - 20), fill=INK, width=20)
            elif kind == 'sad':
                self.d.line((x - s * 60, y - 20, x + s * 50, y + 15), fill=INK, width=18)
            elif kind == 'raised' and s == 1:
                self.d.arc((x - 60, y - 50, x + 60, y + 30), 200, 340, fill=INK, width=18)
            elif kind == 'raised':
                self.d.line((x - 55, y + 10, x + 55, y + 10), fill=INK, width=18)

    def mouth(self, kind):
        d, cx, y = self.d, self.cx, self.mouth_y
        if kind == 'smile':
            d.arc((cx - 110, y - 90, cx + 110, y + 60), 20, 160, fill=INK, width=20)
        elif kind == 'grin':
            d.chord((cx - 120, y - 70, cx + 120, y + 110), 0, 180, fill=INK)
            d.chord((cx - 70, y + 30, cx + 70, y + 108), 180, 360, fill=(230, 90, 90))
        elif kind == 'o':
            d.ellipse((cx - 42, y - 30, cx + 42, y + 62), fill=INK)
        elif kind == 'small-o':
            d.ellipse((cx - 22, y, cx + 22, y + 40), fill=INK)
        elif kind == 'frown':
            d.arc((cx - 95, y + 10, cx + 95, y + 150), 200, 340, fill=INK, width=20)
        elif kind == 'flat':
            d.line((cx - 80, y + 40, cx + 70, y + 30), fill=INK, width=20)
        elif kind == 'smirk':
            d.arc((cx - 120, y - 60, cx + 90, y + 60), 20, 120, fill=INK, width=20)
        elif kind == 'zip':
            d.line((cx - 130, y + 30, cx + 130, y + 30), fill=INK, width=18)
            for i in range(-5, 6):
                x = cx + i * 22
                d.line((x, y + 14, x, y + 46), fill=INK, width=8)
            # the pull, a tiny keyhole tab
            d.ellipse((cx + 120, y + 10, cx + 170, y + 60), fill=SHACKLE, outline=INK, width=8)

    def blush(self):
        layer = Image.new('RGBA', (W, W), (0, 0, 0, 0))
        ld = ImageDraw.Draw(layer)
        for s in (-1, 1):
            x = self.cx + s * 210
            ld.ellipse((x - 50, self.mouth_y - 60, x + 50, self.mouth_y), fill=BLUSH)
        self.img = Image.alpha_composite(self.img, layer.filter(ImageFilter.GaussianBlur(10)))
        self.d = ImageDraw.Draw(self.img)

    # ---- extras
    def heart(self, x, y, r, color, outline=True):
        d = self.d
        pts = []
        for i in range(60):
            t = math.pi * 2 * i / 60
            hx = 16 * math.sin(t) ** 3
            hy = -(13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t))
            pts.append((x + hx * r / 16, y + hy * r / 16))
        d.polygon(pts, fill=color, outline=INK if outline else None, width=10 if outline else 0)

    def drop(self, x, y, r, color=TEAR):
        self.d.polygon([(x, y - r * 1.8), (x - r, y), (x + r, y)], fill=color)
        self.d.ellipse((x - r, y - r, x + r, y + r), fill=color)

    def sparkle(self, x, y, r, color=(255, 230, 150)):
        self.d.polygon([(x, y - r), (x + r * 0.25, y - r * 0.25), (x + r, y), (x + r * 0.25, y + r * 0.25),
                        (x, y + r), (x - r * 0.25, y + r * 0.25), (x - r, y), (x - r * 0.25, y - r * 0.25)],
                       fill=color, outline=INK, width=8)

    def zzz(self):
        d = self.d
        for (x, y, s) in ((760, 300, 60), (850, 200, 80), (930, 80, 100)):
            d.line([(x, y), (x + s, y), (x, y + s), (x + s, y + s)], fill=INK, width=int(s / 5), joint='curve')

    def question(self):
        d = self.d
        d.arc((790, 120, 950, 290), 200, 90, fill=INK, width=34)
        d.line((870, 290, 870, 350), fill=INK, width=34)
        d.ellipse((850, 385, 890, 425), fill=INK)

    def bangs(self):
        for x, h in ((830, 220), (910, 180)):
            self.d.rounded_rectangle((x - 18, 120, x + 18, 120 + h), radius=18, fill=RED, outline=INK, width=6)
            self.d.ellipse((x - 20, 120 + h + 25, x + 20, 120 + h + 65), fill=RED, outline=INK, width=6)

    def anger(self):
        # the cross-shaped vein of comics: four bent strokes around a gap
        x, y, r = 850, 230, 95
        for ax, ay in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
            cx, cy = x + ax * r * 0.55, y + ay * r * 0.55
            box = (cx - r * 0.5, cy - r * 0.5, cx + r * 0.5, cy + r * 0.5)
            start = {(-1, -1): 0, (1, -1): 90, (1, 1): 180, (-1, 1): 270}[(ax, ay)]
            self.d.arc(box, start, start + 90, fill=RED, width=30)

    def check(self):
        x, y, r = 830, 830, 120
        self.d.ellipse((x - r, y - r, x + r, y + r), fill=GREEN, outline=INK, width=14)
        self.d.line([(x - 55, y + 5), (x - 12, y + 50), (x + 60, y - 45)], fill=WHITE, width=30, joint='curve')

    def sunglasses(self):
        d, y = self.d, self.eye_y
        for s in (-1, 1):
            x = self.cx + s * 125
            d.rounded_rectangle((x - 95, y - 55, x + 95, y + 65), radius=40, fill=(25, 25, 30), outline=INK, width=10)
            d.line((x - 60, y - 25, x - 20, y - 25), fill=(120, 140, 170), width=12)
        d.line((self.cx - 30, y - 20, self.cx + 30, y - 20), fill=INK, width=16)

    def party(self):
        d = self.d
        d.polygon([(560, 40), (440, 330), (690, 330)], fill=(91, 140, 230), outline=INK, width=12)
        for i, c in enumerate(((255, 230, 120), (240, 110, 120), WHITE)):
            yy = 120 + i * 70
            d.line((560 - (yy - 40) * 0.42 + 10, yy, 560 + (yy - 40) * 0.43 - 10, yy), fill=c, width=16)
        d.ellipse((530, 10, 590, 70), fill=(255, 230, 120), outline=INK, width=8)
        colors = [(240, 110, 120), (120, 200, 160), (255, 210, 90), (110, 160, 240)]
        for i, (x, y) in enumerate(((150, 250), (870, 300), (120, 600), (900, 620), (200, 120), (820, 140))):
            c = colors[i % 4]
            d.rounded_rectangle((x - 22, y - 12, x + 22, y + 12), radius=6, fill=c, outline=INK, width=5)

    # ---- finishing: a white die-cut edge and a soft shadow
    def done(self, name):
        alpha = self.img.getchannel('A')
        edge = alpha.filter(ImageFilter.MaxFilter(41))
        shadow = edge.filter(ImageFilter.GaussianBlur(18)).point(lambda a: int(a * 0.35))
        base = Image.new('RGBA', (W, W), (0, 0, 0, 0))
        sh = Image.new('RGBA', (W, W), (0, 0, 0, 255))
        sh.putalpha(shadow)
        base.alpha_composite(sh, (0, 12))
        white = Image.new('RGBA', (W, W), (255, 255, 255, 255))
        white.putalpha(edge)
        base.alpha_composite(white)
        base.alpha_composite(self.img)
        # keep everything inside the frame
        base = base.resize((OUT, OUT), Image.LANCZOS)
        base.save(os.path.join(out_dir, f'{name}.png'), optimize=True)


def make(name, shackle_open=False, face=None, extras=()):
    s = Sticker()
    s.shackle(open_=shackle_open)
    s.lock_body()
    face(s)
    for e in extras:
        e(s)
    s.done(name)


STICKERS = {
    'kilit-hello': dict(shackle_open=True,
                        face=lambda s: (s.eyes_dots(), s.mouth('grin'), s.blush()),
                        extras=(lambda s: s.sparkle(150, 300, 70), lambda s: s.sparkle(880, 420, 50))),
    'kilit-love': dict(face=lambda s: (s.eyes_hearts(), s.mouth('smile'), s.blush()),
                       extras=(lambda s: s.heart(150, 260, 70, HEART), lambda s: s.heart(880, 200, 55, HEART))),
    'kilit-laugh': dict(face=lambda s: (s.eyes_happy(), s.mouth('grin'), s.blush()),
                        extras=(lambda s: s.drop(200, 640, 34), lambda s: s.drop(824, 640, 34))),
    'kilit-ok': dict(face=lambda s: (s.eyes_dots(), s.mouth('smile'), s.blush()),
                     extras=(lambda s: s.check(),)),
    'kilit-sad': dict(face=lambda s: (s.brows('sad'), s.eyes_dots(), s.mouth('frown')),
                      extras=(lambda s: s.drop(395, 700, 30),)),
    'kilit-angry': dict(face=lambda s: (s.brows('angry'), s.eyes_dots(r=30), s.mouth('frown')),
                        extras=(lambda s: s.anger(),)),
    'kilit-wow': dict(face=lambda s: (s.eyes_wide(), s.mouth('o')),
                      extras=(lambda s: s.bangs(),)),
    'kilit-sleepy': dict(face=lambda s: (s.eyes_closed(), s.mouth('small-o'), s.blush()),
                         extras=(lambda s: s.zzz(),)),
    'kilit-cool': dict(face=lambda s: (s.sunglasses(), s.mouth('smirk'))),
    'kilit-think': dict(face=lambda s: (s.brows('raised'), s.eyes_dots(), s.mouth('flat')),
                        extras=(lambda s: s.question(),)),
    'kilit-party': dict(face=lambda s: (s.eyes_happy(), s.mouth('grin'), s.blush()),
                        extras=(lambda s: s.party(),)),
    'kilit-shh': dict(face=lambda s: (s.eyes_dots(), s.mouth('zip'))),
}

for name, spec in STICKERS.items():
    make(name, **spec)
print(len(STICKERS), 'stickers in', out_dir)
