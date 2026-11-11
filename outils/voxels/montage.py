"""Montage GIF : toutes les créatures d'un groupe jouent leurs animations
à la suite (repos, marche, course, plaquage, drôle), en grille, avec titres."""

import os
import sys

from PIL import Image, ImageDraw, ImageFont, ImageSequence

from generer import ANIMS, BUILD


def montage(noms, chemin, colonnes=3, case=240):
    try:
        police = ImageFont.truetype("DejaVuSans-Bold.ttf", 17)
    except OSError:
        police = ImageFont.load_default()
    seqs = {}
    for n in noms:
        images = []
        for a in ANIMS:
            g = Image.open(os.path.join(BUILD, n, f"anim_{a}.gif"))
            for fr in ImageSequence.Iterator(g):
                images.append((a, fr.convert("RGB").resize((case, case), Image.LANCZOS)))
        seqs[n] = images
    total = min(len(v) for v in seqs.values())
    lignes = (len(noms) + colonnes - 1) // colonnes
    frames = []
    for i in range(total):
        img = Image.new("RGB", (colonnes * case, lignes * (case + 28)), (246, 248, 255))
        d = ImageDraw.Draw(img)
        for k, n in enumerate(noms):
            a, fr = seqs[n][i]
            x, y = (k % colonnes) * case, (k // colonnes) * (case + 28)
            img.paste(fr, (x, y))
            d.text((x + case / 2, y + case + 12), f"{n} · {a}", fill=(45, 40, 70), font=police, anchor="mm")
        frames.append(img)
    frames[0].save(chemin, save_all=True, append_images=frames[1:], duration=55, loop=0)
    return chemin


if __name__ == "__main__":
    print(montage(sys.argv[2:], sys.argv[1]))
