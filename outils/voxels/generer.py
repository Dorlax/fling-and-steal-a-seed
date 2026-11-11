"""Génère les créatures : python3 generer.py [nom ...|prairie] [--cubes] [--export]

Sortie dans build/voxels/<Nom>/ (aperçu, et OBJ si --export) et une planche.
"""

import os
import sys
import time

from PIL import Image, ImageDraw, ImageFont

import especes

ICI = os.path.dirname(os.path.abspath(__file__))
BUILD = os.path.join(ICI, "..", "..", "build", "voxels")


def produire(nom, style="arrondi", exporter=False):
    s = especes.ESPECES[nom]()
    s.style = style
    s.peindre()
    racine = os.path.join(BUILD, nom)
    chemin = s.apercu(os.path.join(racine, f"apercu_{style}.png"))
    if exporter:
        man = s.exporter(racine)
        print(nom, sum(m["triangles"] for m in man["membres"]), "triangles")
    return nom, chemin


def planche(images, chemin, colonnes=5, case=340):
    lignes = (len(images) + colonnes - 1) // colonnes
    img = Image.new("RGB", (colonnes * case, lignes * (case + 36)), (246, 248, 255))
    d = ImageDraw.Draw(img)
    try:
        police = ImageFont.truetype("DejaVuSans-Bold.ttf", 21)
    except OSError:
        police = ImageFont.load_default()
    for i, (titre, ch) in enumerate(images):
        x, y = (i % colonnes) * case, (i // colonnes) * (case + 36)
        img.paste(Image.open(ch).resize((case, case), Image.LANCZOS), (x, y))
        d.text((x + case / 2, y + case + 16), titre, fill=(45, 40, 70), font=police, anchor="mm")
    img.save(chemin)
    return chemin


if __name__ == "__main__":
    t0 = time.time()
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    style = "cubes" if "--cubes" in sys.argv else "arrondi"
    noms = list(especes.ESPECES) if not args or args == ["prairie"] else args
    res = [produire(n, style, "--export" in sys.argv) for n in noms]
    if len(res) > 1:
        print(planche(res, os.path.join(BUILD, f"planche_prairie_{style}.png")))
    print(f"{time.time() - t0:.0f}s")
