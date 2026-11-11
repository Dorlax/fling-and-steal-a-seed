"""Monstres de la Prairie Pétillante, en voxels fins.

Ils sont grognons mais drôles (jeu kid friendly) : sourcils froncés, petits
crocs, bouille ronde. Ils ne blessent pas : ils plaquent et propulsent le
joueur. Même découpage en membres que les créatures, pour les animations.
"""

import math

from especes import _joues, _pattes4
from sculpteur import BLANC, Sculpteur, rgb

SOURCIL = rgb("2b1d33")


def _sourcils(t, y, z, ecart, longueur=0.06, angle=22, couleur=SOURCIL):
    """Sourcils froncés (penchés vers le nez) : la touche « grognon »."""
    for c in (-1, 1):
        t.boite((c * ecart, y, z), (longueur / 2, 0.012, 0.012), couleur, arrondi=0.008,
                rot=(0, 0, c * angle), fondu=0.0, plat=True)


def _crocs(t, y, z, ecart, taille=0.025, couleur=BLANC, vers_haut=False):
    for c in (-1, 1):
        a = (c * ecart, y, z)
        b = (c * ecart, y + (taille if vers_haut else -taille), z - 0.005)
        t.cone(a, b, taille * 0.45, 0.004, couleur, fondu=0.0, plat=True)


# ---------------------------------------------------------------- Gloupinou

def gloupinou():
    s = Sculpteur("Gloupinou")
    GELEE, CLAIR, FONCE = rgb("6fe0ff"), rgb("c8f6ff"), rgb("2f9fd0")
    c = s.membre("Corps")
    c.boite((0, -0.21, 0.0), (0.3, 0.24, 0.28), GELEE, arrondi=0.19)
    c.boule((0, -0.06, 0.0), (0.24, 0.13, 0.22), GELEE, fondu=0.08)
    c.boule((0, -0.44, 0.0), (0.33, 0.07, 0.31), GELEE, fondu=0.06)
    # Gouttes qui coulent le long des flancs.
    for x, z, h in ((-0.26, -0.18, 0.1), (0.24, 0.08, 0.13), (-0.1, -0.27, 0.08), (0.2, -0.24, 0.07)):
        c.cone((x, -0.3, z), (x * 1.08, -0.3 - h, z * 1.08), 0.04, 0.03, GELEE, fondu=0.03)
    # Reflets et bulles (couleur claire), coeur sombre visible à travers.
    c.boule((-0.15, 0.0, -0.16), (0.07, 0.04, 0.05), CLAIR, mode="peint")
    for x, y, z in ((0.18, -0.08, -0.22), (-0.2, -0.3, -0.2), (0.22, -0.32, 0.1), (0.05, 0.03, 0.2)):
        c.boule((x, y, z), (0.03, 0.03, 0.03), CLAIR, mode="peint")
    c.boule((0.06, -0.2, 0.12), (0.12, 0.1, 0.12), FONCE, mode="peint")
    c.oeil((-0.1, -0.1, -0.29), 0.055)
    c.oeil((0.1, -0.1, -0.29), 0.055)
    _sourcils(c, -0.02, -0.29, 0.1)
    # Bouche ouverte de travers, avec la langue.
    c.boule((0.01, -0.25, -0.28), (0.07, 0.035, 0.03), rgb("2a1030"), mode="creux")
    c.boule((0.01, -0.27, -0.26), (0.06, 0.028, 0.03), rgb("2a1030"), fondu=0.0, plat=True)
    c.boule((0.03, -0.285, -0.27), (0.03, 0.015, 0.02), rgb("ff6f9a"), mode="peint", plat=True)
    # Deux gouttes sur la tête qui tremblotent (rôle Oreille).
    for cc, nom in ((-1, "GoutteG"), (1, "GoutteD")):
        o = s.membre(nom, "Oreille", (cc * 0.1, 0.05, 0.0), cc)
        o.cone((cc * 0.1, 0.04, 0.0), (cc * 0.15, 0.17, 0.02), 0.05, 0.015, GELEE, fondu=0.0)
        o.boule((cc * 0.12, 0.11, -0.02), (0.015, 0.015, 0.012), CLAIR, mode="peint")
    return s


# --------------------------------------------------------------- Piquerelle

def piquerelle():
    s = Sculpteur("Piquerelle")
    PIQUE, PIQUE2, PEAU, FONCE = rgb("8a5a3a"), rgb("b07a4a"), rgb("ffd9a8"), rgb("4a2a1a")
    c = s.membre("Corps")
    c.boule((0, -0.18, 0.06), (0.27, 0.23, 0.29), PIQUE)
    c.boule((0, -0.22, -0.08), (0.18, 0.16, 0.18), PEAU, mode="peint")
    # Piquants : rangées de cônes sur le dos.
    rng = [(a, b) for a in range(-3, 4) for b in range(0, 5)]
    for i, (a, b) in enumerate(rng):
        th = a * 0.42
        ph = 0.15 + b * 0.32
        n = (math.sin(th) * math.sin(ph), math.cos(ph), math.cos(th) * math.sin(ph))
        if n[2] < -0.45:  # pas de piquants sur la figure
            continue
        base = (0.24 * n[0], -0.18 + 0.2 * n[1], 0.06 + 0.26 * n[2])
        pointe = (0.37 * n[0], -0.18 + 0.33 * n[1], 0.06 + 0.42 * n[2] + 0.05)
        c.cone(base, pointe, 0.045, 0.006, PIQUE2 if (a + b) % 2 else PIQUE, fondu=0.0)
        c.cone(((base[0] + pointe[0] * 2) / 3, (base[1] + pointe[1] * 2) / 3, (base[2] + pointe[2] * 2) / 3),
               pointe, 0.02, 0.005, rgb("fff0d0"), mode="peint")
    t = s.membre("Tete", "Tete", (0, -0.2, -0.16))
    t.boule((0, -0.18, -0.24), (0.17, 0.14, 0.12), PEAU)
    t.cone((0, -0.2, -0.3), (0, -0.21, -0.39), 0.07, 0.03, PEAU, fondu=0.03)
    t.boule((0, -0.2, -0.4), (0.035, 0.028, 0.025), FONCE, fondu=0.0, plat=True)
    t.oeil((-0.07, -0.14, -0.335), 0.04)
    t.oeil((0.07, -0.14, -0.335), 0.04)
    _sourcils(t, -0.085, -0.345, 0.075, 0.055)
    _crocs(t, -0.265, -0.37, 0.03, 0.022)
    _pattes4(s, PEAU, FONCE, x=0.13, z_av=-0.08, z_ar=0.18, haut=-0.33, r=0.045, corps=c)
    return s


# ------------------------------------------------------------- Ronchonbulle

def ronchonbulle():
    s = Sculpteur("Ronchonbulle")
    ROUX, FONCE, GROIN, DEF = rgb("d8783c"), rgb("6e3820"), rgb("ffb0a0"), rgb("fff6e0")
    c = s.membre("Corps")
    c.boule((0, -0.12, 0.08), (0.24, 0.2, 0.3), ROUX)
    c.boule((0, -0.18, -0.02), (0.14, 0.1, 0.18), rgb("f2a26a"), mode="peint")
    # Crinière en crête sur le dos.
    for i in range(7):
        z = -0.14 + i * 0.065
        y = 0.08 - 0.06 * abs(i - 2) / 3
        c.cone((0, y - 0.04, z), (0, y + 0.09 - i * 0.008, z + 0.04), 0.04, 0.008, FONCE, fondu=0.015)
    _pattes4(s, ROUX, FONCE, x=0.14, z_av=-0.08, z_ar=0.24, haut=-0.24, r=0.06, corps=c)
    q = s.membre("Queue", "Queue", (0, -0.06, 0.37))
    q.courbe([(0, -0.06, 0.36), (0.05, -0.02, 0.43), (0.0, 0.03, 0.46), (-0.03, -0.01, 0.42)], [0.022, 0.02, 0.018, 0.014], ROUX)
    t = s.membre("Tete", "Tete", (0, -0.05, -0.2))
    t.boule((0, -0.04, -0.28), (0.19, 0.17, 0.16), ROUX)
    t.cone((0, -0.08, -0.36), (0, -0.09, -0.44), 0.085, 0.08, GROIN, fondu=0.03)
    t.boule((0, -0.09, -0.455), (0.08, 0.065, 0.02), GROIN, fondu=0.0)
    for cc in (-1, 1):
        t.boule((cc * 0.03, -0.09, -0.47), (0.015, 0.022, 0.01), rgb("8a3a3a"), mode="peint", plat=True)
    t.oeil((-0.085, 0.02, -0.405), 0.04)
    t.oeil((0.085, 0.02, -0.405), 0.04)
    _sourcils(t, 0.075, -0.41, 0.085, 0.07, 28)
    # Défenses recourbées vers le haut.
    for cc in (-1, 1):
        t.courbe([(cc * 0.08, -0.14, -0.42), (cc * 0.12, -0.11, -0.47), (cc * 0.12, -0.04, -0.49)], [0.022, 0.016, 0.006], DEF, fondu=0.0)
    for cc, nom in ((-1, "OreilleG"), (1, "OreilleD")):
        o = s.membre(nom, "Oreille", (cc * 0.13, 0.08, -0.24), cc)
        o.cone((cc * 0.12, 0.07, -0.24), (cc * 0.22, 0.17, -0.22), 0.05, 0.012, ROUX, fondu=0.0)
        o.cone((cc * 0.14, 0.09, -0.26), (cc * 0.2, 0.15, -0.24), 0.025, 0.008, FONCE, mode="peint")
    return s


# --------------------------------------------------------------- Croquelune

def croquelune():
    s = Sculpteur("Croquelune")
    GRIS, CLAIR, NUIT, LUNE = rgb("6f7ac0"), rgb("cfd6f5"), rgb("3e4580"), rgb("ffe58a")
    c = s.membre("Corps")
    c.boule((0, -0.12, 0.1), (0.18, 0.17, 0.27), GRIS)
    c.boule((0, -0.04, -0.08), (0.17, 0.16, 0.14), CLAIR, fondu=0.05)  # collerette touffue
    c.boule((0, -0.2, 0.06), (0.12, 0.08, 0.18), CLAIR, mode="peint")
    for z in (0.02, 0.12, 0.22):
        c.cone((0, 0.02, z), (0, 0.08, z + 0.05), 0.035, 0.006, NUIT, fondu=0.01)
    _pattes4(s, GRIS, NUIT, x=0.11, z_av=-0.06, z_ar=0.25, haut=-0.24, r=0.05, corps=c)
    q = s.membre("Queue", "Queue", (0, -0.06, 0.35))
    q.courbe([(0, -0.06, 0.34), (0, 0.0, 0.44), (0.02, 0.1, 0.48), (0.03, 0.17, 0.44)], [0.05, 0.08, 0.075, 0.03], GRIS)
    q.boule((0.025, 0.14, 0.46), (0.06, 0.06, 0.06), CLAIR, mode="peint")
    t = s.membre("Tete", "Tete", (0, 0.02, -0.12))
    t.boule((0, 0.1, -0.2), (0.18, 0.16, 0.15), GRIS)
    t.cone((0, 0.06, -0.28), (0, 0.045, -0.39), 0.085, 0.055, GRIS, fondu=0.03)
    t.cone((0, 0.03, -0.28), (0, 0.025, -0.38), 0.07, 0.045, CLAIR, mode="peint")
    t.boule((0, 0.07, -0.4), (0.034, 0.026, 0.024), rgb("1d1626"), fondu=0.0, plat=True)
    t.oeil((-0.075, 0.13, -0.32), 0.045, iris=LUNE)
    t.oeil((0.075, 0.13, -0.32), 0.045, iris=LUNE)
    _sourcils(t, 0.19, -0.33, 0.075, 0.06, 25)
    _crocs(t, -0.005, -0.4, 0.035, 0.025)
    # Croissant de lune lumineux sur le front.
    t.boule((0, 0.215, -0.3), (0.05, 0.05, 0.08), LUNE, mode="peint", plat=True)
    t.boule((0.025, 0.23, -0.3), (0.04, 0.04, 0.09), GRIS, mode="peint")
    for cc, nom in ((-1, "OreilleG"), (1, "OreilleD")):
        o = s.membre(nom, "Oreille", (cc * 0.1, 0.22, -0.18), cc)
        o.cone((cc * 0.1, 0.2, -0.18), (cc * 0.15, 0.38, -0.16), 0.06, 0.01, GRIS, fondu=0.0)
        o.cone((cc * 0.105, 0.22, -0.21), (cc * 0.14, 0.33, -0.19), 0.03, 0.008, NUIT, mode="peint")
    return s


# ----------------------------------------------------------------- Grobidou

def grobidou():
    s = Sculpteur("Grobidou")
    VIOLET, FONCE, LILAS, CORNE = rgb("7d41d2"), rgb("4b1e8c"), rgb("d2b4ff"), rgb("fff0c8")
    c = s.membre("Corps")
    c.boule((0, -0.12, 0.02), (0.25, 0.27, 0.21), VIOLET)
    c.boule((0, -0.14, -0.12), (0.17, 0.19, 0.1), LILAS, mode="peint")
    for cc in (-1, 1):
        c.boule((cc * 0.22, 0.04, 0.0), (0.09, 0.08, 0.09), VIOLET, fondu=0.06)  # épaules
    t = s.membre("Tete", "Tete", (0, 0.12, -0.02))
    t.boule((0, 0.24, -0.04), (0.17, 0.15, 0.15), VIOLET)
    t.boule((0, 0.18, -0.16), (0.11, 0.07, 0.06), LILAS, fondu=0.03)
    t.oeil((-0.065, 0.28, -0.17), 0.035)
    t.oeil((0.065, 0.28, -0.17), 0.035)
    _sourcils(t, 0.33, -0.175, 0.065, 0.065, 30)
    t.boule((0, 0.21, -0.215), (0.03, 0.02, 0.015), FONCE, fondu=0.0, plat=True)
    _crocs(t, 0.135, -0.205, 0.045, 0.028, vers_haut=True)
    for cc in (-1, 1):
        t.courbe([(cc * 0.11, 0.33, -0.02), (cc * 0.19, 0.39, -0.01), (cc * 0.22, 0.46, 0.02)], [0.035, 0.024, 0.008], CORNE, fondu=0.01)
        t.boule((cc * 0.15, 0.32, 0.02), (0.045, 0.045, 0.03), VIOLET, fondu=0.02)  # petites oreilles d'ours
        t.boule((cc * 0.15, 0.32, 0.0), (0.022, 0.022, 0.02), LILAS, mode="peint")
    for cc, nom in ((-1, "BrasG"), (1, "BrasD")):
        b = s.membre(nom, "Bras", (cc * 0.25, 0.04, 0.0), cc, 0.0 if cc < 0 else 0.5)
        b.cone((cc * 0.26, 0.03, 0.0), (cc * 0.32, -0.16, -0.02), 0.07, 0.065, VIOLET, fondu=0.0)
        b.boule((cc * 0.33, -0.23, -0.03), (0.1, 0.09, 0.1), VIOLET, fondu=0.03)  # gros poing
        b.boule((cc * 0.33, -0.23, -0.12), (0.06, 0.05, 0.02), LILAS, mode="peint")
    for cc, nom in ((-1, "PatteG"), (1, "PatteD")):
        p = s.membre(nom, "Patte", (cc * 0.12, -0.33, 0.02), cc, 0.0 if cc < 0 else 0.5)
        p.cone((cc * 0.12, -0.3, 0.02), (cc * 0.13, -0.44, 0.0), 0.08, 0.075, VIOLET, fondu=0.0)
        p.boule((cc * 0.13, -0.465, -0.03), (0.09, 0.04, 0.11), FONCE, fondu=0.03)
    return s


# ---------------------------------------------------------------- Brasaurus

def brasaurus():
    s = Sculpteur("Brasaurus")
    VERT, VENTRE, PLAQUE, AILE = rgb("5cbe5a"), rgb("ffe0a0"), rgb("ffa03c"), rgb("e63c32")
    c = s.membre("Corps")
    c.boule((0, -0.12, 0.06), (0.19, 0.22, 0.2), VERT)
    c.boule((0, -0.15, -0.07), (0.12, 0.16, 0.08), VENTRE, mode="peint")
    for i in range(4):
        y, z = 0.05 - i * 0.07, 0.13 + i * 0.06
        c.boite((0, y + 0.05, z), (0.012, 0.06 - i * 0.008, 0.045), PLAQUE, arrondi=0.01, rot=(-35 - i * 10, 0, 0), fondu=0.01)
    q = s.membre("Queue", "Queue", (0, -0.25, 0.2))
    q.courbe([(0, -0.24, 0.18), (0, -0.33, 0.3), (0.04, -0.39, 0.4), (0.1, -0.41, 0.47)], [0.1, 0.07, 0.045, 0.02], VERT)
    for i, (y, z) in enumerate(((-0.23, 0.28), (-0.31, 0.37))):
        q.boite((0, y, z), (0.01, 0.04, 0.03), PLAQUE, arrondi=0.008, rot=(-60, 0, 0), fondu=0.01)
    t = s.membre("Tete", "Tete", (0, 0.08, -0.04))
    t.boule((0, 0.2, -0.08), (0.18, 0.16, 0.17), VERT)
    t.boule((0, 0.13, -0.2), (0.14, 0.08, 0.1), VERT, fondu=0.05)
    t.boule((0, 0.1, -0.24), (0.11, 0.025, 0.06), rgb("8a2030"), mode="creux")  # gueule ouverte
    t.boule((0, 0.08, -0.22), (0.1, 0.02, 0.05), rgb("8a2030"), fondu=0.0, plat=True)
    _crocs(t, 0.12, -0.285, 0.06, 0.02)
    # Petite flamme qui sort de la gueule (lumineuse).
    t.cone((0, 0.09, -0.29), (0, 0.13, -0.38), 0.035, 0.008, rgb("ffd23a"), fondu=0.0, plat=True)
    for cc in (-1, 1):
        t.boule((cc * 0.035, 0.17, -0.3), (0.012, 0.01, 0.01), rgb("1d4a1d"), mode="peint", plat=True)
    t.oeil((-0.08, 0.25, -0.21), 0.045, iris=rgb("ffcc33"))
    t.oeil((0.08, 0.25, -0.21), 0.045, iris=rgb("ffcc33"))
    _sourcils(t, 0.305, -0.215, 0.08, 0.065, 25)
    t.cone((0, 0.34, -0.06), (0, 0.42, -0.02), 0.04, 0.01, PLAQUE, fondu=0.01)
    for cc, nom in ((-1, "AileG"), (1, "AileD")):
        a = s.membre(nom, "Aile", (cc * 0.14, 0.02, 0.12), cc)
        a.cone((cc * 0.14, 0.02, 0.12), (cc * 0.28, 0.12, 0.18), 0.022, 0.012, VERT, fondu=0.0)
        a.boule((cc * 0.24, 0.05, 0.19), (0.1, 0.075, 0.012), AILE, rot=(0, cc * -25, cc * 30), fondu=0.02)
    for cc, nom in ((-1, "BrasG"), (1, "BrasD")):
        b = s.membre(nom, "Bras", (cc * 0.13, -0.05, -0.1), cc, 0.0 if cc < 0 else 0.5)
        b.cone((cc * 0.13, -0.05, -0.1), (cc * 0.15, -0.14, -0.19), 0.035, 0.028, VERT, fondu=0.0)
    for cc, nom in ((-1, "PatteG"), (1, "PatteD")):
        p = s.membre(nom, "Patte", (cc * 0.12, -0.28, 0.06), cc, 0.0 if cc < 0 else 0.5)
        c.boule((cc * 0.12, -0.24, 0.07), (0.085, 0.1, 0.1), VERT, fondu=0.07)  # cuisse fondue
        p.cone((cc * 0.12, -0.27, 0.06), (cc * 0.13, -0.44, 0.03), 0.065, 0.06, VERT, fondu=0.0)
        p.boule((cc * 0.13, -0.465, -0.01), (0.075, 0.035, 0.1), VERT, fondu=0.03)
        for dx in (-0.035, 0.0, 0.035):
            p.boule((cc * 0.13 + dx, -0.47, -0.105), (0.016, 0.014, 0.014), VENTRE, mode="peint")
    _joues(t, 0.2, -0.235, 0.13, 0.03)
    return s


MONSTRES = {
    "Gloupinou": gloupinou,
    "Piquerelle": piquerelle,
    "Ronchonbulle": ronchonbulle,
    "Croquelune": croquelune,
    "Grobidou": grobidou,
    "Brasaurus": brasaurus,
}
