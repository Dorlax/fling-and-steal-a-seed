"""Monstres en voxels : Mécanique, Zen, Cavernes, Jouets."""

import math

from monstres import _crocs, _sourcils
from monstres_aide import BLANC, bras2, jambes2, joues, pattes4, piquants, rgb, visage
from sculpteur import Sculpteur

# --------------------------------------------------------------- Mécanique


def visseur():
    s = Sculpteur("Visseur")
    MANCHE, BANDE, METAL, FONCE = rgb("ff5a2a"), rgb("ffd23a"), rgb("c8d0dc"), rgb("6a7280")
    c = s.membre("Corps")
    c.cylindre((0, -0.1, 0), 0.13, 0.2, MANCHE, arrondi=0.06)
    for y in (-0.2, 0.0):
        c.cylindre((0, y, 0), 0.135, 0.02, BANDE, arrondi=0.01, mode="peint")
    visage(c, -0.08, -0.13, 0.055, 0.035, crocs=True, angle=28, bouche_y=-0.16)
    t = s.membre("Tete", "Tete", (0, 0.1, 0))
    t.cone((0, 0.1, 0), (0, 0.32, 0), 0.04, 0.035, METAL, fondu=0.0)
    t.boite((0, 0.36, 0), (0.045, 0.04, 0.012), METAL, arrondi=0.008, fondu=0.0)
    for i in range(4):
        t.boite((0, 0.15 + i * 0.045, 0), (0.042, 0.006, 0.042), FONCE, arrondi=0.004, rot=(0, 30 * i, 0), mode="peint")
    jambes2(s, METAL, FONCE, x=0.07, haut=-0.3, r=0.035, corps=c)
    bras2(s, METAL, FONCE, x=0.16, y=-0.05, longueur=0.12, r=0.025, poing=0.04, corps=c)
    return s


def pistonard():
    s = Sculpteur("Pistonard")
    METAL, FONCE, CUIVRE, ROUGE = rgb("9aa4b8"), rgb("4a5468"), rgb("d8883a"), rgb("ff3a2a")
    c = s.membre("Corps")
    c.cylindre((0, -0.32, 0), 0.24, 0.1, FONCE, arrondi=0.03)
    c.cylindre((0, -0.15, 0), 0.08, 0.1, METAL, arrondi=0.01)
    for i in range(4):
        c.boule((math.cos(i * math.pi / 2) * 0.2, -0.24, math.sin(i * math.pi / 2) * 0.2), (0.025,) * 3, CUIVRE, fondu=0.0)
    t = s.membre("Tete", "Tete", (0, -0.05, 0))
    t.cylindre((0, 0.12, 0), 0.22, 0.16, METAL, arrondi=0.05)
    t.cylindre((0, 0.26, 0), 0.23, 0.025, CUIVRE, arrondi=0.01)
    visage(t, 0.14, -0.22, 0.08, 0.045, iris=ROUGE, angle=30, bouche_y=0.04)
    for cc in (-1, 1):
        t.cone((cc * 0.12, 0.28, 0.05), (cc * 0.14, 0.38, 0.06), 0.03, 0.025, FONCE, fondu=0.0)
    return s


def broyeurex():
    s = Sculpteur("Broyeurex")
    JAUNE, FONCE, ACIER, DENT = rgb("f2b02a"), rgb("4a4a5a"), rgb("aab4c4"), rgb("e6eaf0")
    c = s.membre("Corps")
    c.boite((0, -0.06, 0.06), (0.28, 0.22, 0.26), JAUNE, arrondi=0.06)
    c.boite((0, -0.06, 0.06), (0.285, 0.03, 0.265), FONCE, arrondi=0.02, mode="peint")
    for cc in (-1, 1):
        c.cylindre((cc * 0.2, 0.2, 0.18), 0.04, 0.06, FONCE, arrondi=0.01)  # cheminées
    c.boule((0, -0.1, -0.22), (0.22, 0.09, 0.05), rgb("2a1a24"), mode="creux")
    for i in range(7):
        a = i / 7 * math.pi
        x = -0.18 + i * 0.06
        c.cone((x, -0.02, -0.21), (x, -0.08, -0.25), 0.025, 0.004, DENT, fondu=0.0)
        c.cone((x + 0.03, -0.18, -0.21), (x + 0.03, -0.12, -0.25), 0.025, 0.004, DENT, fondu=0.0)
        _ = a
    visage(c, 0.09, -0.21, 0.12, 0.05, iris=rgb("ff3a2a"), crocs=False, angle=30)
    for cc, nom in ((-1, "RoueG"), (1, "RoueD")):
        r = s.membre(nom, "Patte", (cc * 0.28, -0.32, 0.06), cc, 0.0 if cc < 0 else 0.5)
        r.boule((cc * 0.3, -0.34, -0.1), (0.05, 0.12, 0.12), FONCE, fondu=0.0)
        r.boule((cc * 0.3, -0.34, 0.2), (0.05, 0.12, 0.12), FONCE, fondu=0.0)
        r.boule((cc * 0.33, -0.34, -0.1), (0.02, 0.05, 0.05), ACIER, mode="peint")
        r.boule((cc * 0.33, -0.34, 0.2), (0.02, 0.05, 0.05), ACIER, mode="peint")
    return s


# --------------------------------------------------------------------- Zen


def bambougre():
    s = Sculpteur("Bambougre")
    BAMBOU, NOEUD, FEUILLE = rgb("8ad04a"), rgb("5a9a2a"), rgb("4ab04a")
    c = s.membre("Corps")
    c.cylindre((0, -0.15, 0), 0.13, 0.3, BAMBOU, arrondi=0.05)
    for y in (-0.3, -0.05, 0.12):
        c.cylindre((0, y, 0), 0.14, 0.015, NOEUD, arrondi=0.01, fondu=0.0)
    visage(c, -0.16, -0.12, 0.055, 0.035, angle=30, bouche_y=-0.22)
    t = s.membre("Tete", "Tete", (0, 0.15, 0))
    for cc in (-1, 1):
        t.boule((cc * 0.1, 0.24, 0.0), (0.12, 0.025, 0.05), FEUILLE, rot=(0, 0, cc * 35), fondu=0.0)
    t.boule((0, 0.26, 0.04), (0.04, 0.12, 0.025), FEUILLE, fondu=0.0)
    bras2(s, BAMBOU, NOEUD, x=0.15, y=-0.08, longueur=0.12, r=0.03, poing=0.04, corps=c)
    jambes2(s, BAMBOU, NOEUD, x=0.07, haut=-0.42, r=0.04, corps=c)
    return s


def oniboule():
    s = Sculpteur("Oniboule")
    ROUGE, FONCE, CORNE, CHEVEUX = rgb("e6403a"), rgb("a02a2a"), rgb("fff2c8"), rgb("2a2a4a")
    c = s.membre("Corps")
    c.boule((0, -0.13, 0), (0.29, 0.29, 0.27), ROUGE)
    c.boule((0, -0.3, -0.06), (0.2, 0.08, 0.15), FONCE, mode="peint")
    visage(c, -0.02, -0.25, 0.1, 0.05, iris=rgb("ffd23a"), crocs=False, angle=32)
    c.boule((0, -0.17, -0.25), (0.1, 0.03, 0.03), rgb("2a1030"), fondu=0.0, plat=True)
    _crocs(c, -0.18, -0.27, 0.06, 0.035, vers_haut=True)
    t = s.membre("Tete", "Tete", (0, 0.12, 0))
    t.boule((0, 0.14, 0.04), (0.18, 0.04, 0.16), CHEVEUX, fondu=0.03)
    for cc in (-1, 1):
        t.cone((cc * 0.1, 0.14, -0.04), (cc * 0.14, 0.3, -0.06), 0.045, 0.008, CORNE, fondu=0.0)
    for cc, nom in ((-1, "PatteG"), (1, "PatteD")):
        p = s.membre(nom, "Patte", (cc * 0.13, -0.38, 0), cc, 0.0 if cc < 0 else 0.5)
        p.boule((cc * 0.14, -0.44, -0.02), (0.08, 0.04, 0.1), FONCE, fondu=0.02)
    return s


def komapierre():
    s = Sculpteur("Komapierre")
    PIERRE, FONCE, MOUSSE, OEIL = rgb("a8a8b0"), rgb("6a6a74"), rgb("6aa04a"), rgb("3ae6d2")
    c = s.membre("Corps")
    c.boule((0, -0.16, 0.1), (0.22, 0.22, 0.26), PIERRE)
    c.boite((0, -0.45, 0.06), (0.3, 0.03, 0.34), FONCE, arrondi=0.02)  # socle
    t = s.membre("Tete", "Tete", (0, 0.04, -0.12))
    t.boule((0, 0.12, -0.18), (0.21, 0.2, 0.17), PIERRE)
    for i in range(10):
        a = i / 10 * 2 * math.pi
        t.boule((math.cos(a) * 0.21, 0.12 + math.sin(a) * 0.19, -0.1), (0.07, 0.07, 0.07), FONCE, fondu=0.02)  # crinière
    t.boule((0, 0.05, -0.32), (0.09, 0.06, 0.05), PIERRE, fondu=0.03)
    t.boule((0, 0.1, -0.35), (0.03, 0.02, 0.015), FONCE, fondu=0.0)
    visage(t, 0.16, -0.33, 0.07, 0.04, iris=OEIL, crocs=False, angle=30)
    _crocs(t, -0.0, -0.36, 0.05, 0.03)
    t.boule((0.12, 0.28, -0.15), (0.06, 0.03, 0.04), MOUSSE, mode="peint")
    pattes4(s, PIERRE, FONCE, x=0.14, z_av=-0.1, z_ar=0.25, haut=-0.24, r=0.065, corps=c)
    return s


# ---------------------------------------------------------------- Cavernes


def stalagmord():
    s = Sculpteur("Stalagmord")
    ROCHE, FONCE, CRISTAL = rgb("8a7a9a"), rgb("5a4a6a"), rgb("8ae6ff")
    c = s.membre("Corps")
    c.cone((0, -0.42, 0), (0, 0.35, 0), 0.26, 0.02, ROCHE, fondu=0.0)
    for y in (-0.3, -0.12, 0.08):
        c.cone((0, y, 0), (0, y + 0.02, 0), 0.27 - (y + 0.42) * 0.32, 0.26 - (y + 0.42) * 0.32, FONCE, mode="peint")
    c.cone((0.15, -0.3, -0.1), (0.25, -0.05, -0.15), 0.04, 0.005, CRISTAL, fondu=0.0)
    c.boule((0, -0.22, -0.2), (0.12, 0.05, 0.05), rgb("2a1030"), mode="creux")
    _crocs(c, -0.17, -0.23, 0.06, 0.035)
    _crocs(c, -0.27, -0.22, 0.05, 0.03, vers_haut=True)
    visage(c, -0.05, -0.15, 0.06, 0.035, iris=CRISTAL, crocs=False, angle=30)
    for cc, nom in ((-1, "PatteG"), (1, "PatteD")):
        p = s.membre(nom, "Patte", (cc * 0.15, -0.4, 0), cc, 0.0 if cc < 0 else 0.5)
        p.boule((cc * 0.17, -0.45, -0.04), (0.07, 0.035, 0.09), FONCE, fondu=0.02)
    return s


def vercaillou():
    s = Sculpteur("Vercaillou")
    ROCHE, FONCE, VENTRE = rgb("9a8a7a"), rgb("6a5a4a"), rgb("d8c0a0")
    c = s.membre("Corps")
    c.boule((0, -0.44, 0.1), (0.3, 0.04, 0.26), FONCE)  # trou dans le sol
    c.courbe([(0, -0.42, 0.1), (0.0, -0.25, 0.08), (0.0, -0.05, 0.0), (0.0, 0.08, -0.08)], [0.13, 0.13, 0.12, 0.12], ROCHE)
    for y in (-0.33, -0.22, -0.11, 0.0):
        c.boule((0, y, 0.06 - (y + 0.42) * 0.1), (0.14, 0.02, 0.14), FONCE, mode="peint")
    c.boule((0, -0.15, -0.08), (0.06, 0.2, 0.06), VENTRE, mode="peint")
    t = s.membre("Tete", "Tete", (0, 0.08, -0.08))
    t.boule((0, 0.16, -0.1), (0.14, 0.13, 0.14), ROCHE)
    t.boule((0, 0.11, -0.24), (0.1, 0.06, 0.03), rgb("2a1030"), mode="creux")
    _crocs(t, 0.14, -0.25, 0.06, 0.03)
    _crocs(t, 0.07, -0.25, 0.05, 0.025, vers_haut=True)
    visage(t, 0.22, -0.21, 0.06, 0.035, crocs=False, angle=30)
    for x, z in ((-0.25, 0.0), (0.24, 0.2), (0.1, -0.15)):
        c.boite((x, -0.42, z), (0.04, 0.03, 0.04), FONCE, arrondi=0.015, rot=(10, 30, 15), fondu=0.0)
    return s


def rocgrondeur():
    s = Sculpteur("Rocgrondeur")
    ROCHE, FONCE, MOUSSE, CRISTAL = rgb("7a7a86"), rgb("4a4a56"), rgb("6aa04a"), rgb("b46aff")
    c = s.membre("Corps")
    c.boule((0, -0.1, 0.04), (0.29, 0.27, 0.23), ROCHE)
    c.boule((-0.1, 0.12, 0.1), (0.12, 0.05, 0.1), MOUSSE, mode="peint")
    for x, y, z in ((0.18, 0.12, 0.08), (0.24, -0.02, 0.12)):
        c.cone((x, y, z), (x * 1.3, y + 0.12, z * 1.2), 0.04, 0.006, CRISTAL, fondu=0.0)
    visage(c, 0.04, -0.21, 0.1, 0.05, iris=rgb("ffd23a"), angle=30, bouche_y=-0.08)
    for cc, nom in ((-1, "BrasG"), (1, "BrasD")):
        b = s.membre(nom, "Bras", (cc * 0.28, 0.05, 0), cc, 0.0 if cc < 0 else 0.5)
        b.boule((cc * 0.32, 0.0, 0), (0.09, 0.09, 0.09), ROCHE, fondu=0.0)
        b.boule((cc * 0.36, -0.16, -0.02), (0.08, 0.08, 0.08), ROCHE, fondu=0.03)
        b.boule((cc * 0.37, -0.3, -0.04), (0.11, 0.1, 0.11), FONCE, fondu=0.03)
    jambes2(s, ROCHE, FONCE, x=0.14, haut=-0.32, r=0.085, corps=c)
    return s


# ------------------------------------------------------------------ Jouets


def billerage():
    s = Sculpteur("Billerage")
    VERRE, SPIRALE, SPIRALE2 = rgb("8ad8ff"), rgb("ff3a6a"), rgb("ffd23a")
    c = s.membre("Corps")
    c.boule((0, -0.2, 0), (0.27, 0.27, 0.27), VERRE)
    # Bandes en spirale bien visibles (comme une bille de verre).
    for i in range(4):
        c.boite((0, -0.2, 0), (0.29, 0.03, 0.29), SPIRALE if i % 2 == 0 else SPIRALE2, arrondi=0.02,
                rot=(i * 45, 25, 15), mode="peint")
    c.boule((-0.12, -0.04, -0.2), (0.05, 0.04, 0.03), BLANC, mode="peint", plat=True)
    visage(c, -0.16, -0.25, 0.09, 0.045, angle=30, bouche_y=-0.31)
    return s


def tamboum():
    s = Sculpteur("Tamboum")
    CAISSE, PEAU, CORDE, BAGUETTE = rgb("e6403a"), rgb("fff2dc"), rgb("ffd23a"), rgb("c08a4a")
    c = s.membre("Corps")
    c.cylindre((0, -0.12, 0), 0.24, 0.17, CAISSE, arrondi=0.03)
    c.cylindre((0, 0.05, 0), 0.245, 0.015, PEAU, arrondi=0.01, fondu=0.0)
    c.cylindre((0, -0.29, 0), 0.245, 0.015, PEAU, arrondi=0.01, fondu=0.0)
    for i in range(8):
        a = i / 8 * 2 * math.pi
        c.cone((math.cos(a) * 0.245, 0.03, math.sin(a) * 0.245), (math.cos(a + 0.4) * 0.245, -0.27, math.sin(a + 0.4) * 0.245),
               0.01, 0.01, CORDE, fondu=0.0)
    visage(c, -0.08, -0.24, 0.09, 0.045, angle=30, bouche_y=-0.18)
    for cc, nom in ((-1, "BrasG"), (1, "BrasD")):
        b = s.membre(nom, "Bras", (cc * 0.24, -0.08, 0), cc, 0.0 if cc < 0 else 0.5)
        b.cone((cc * 0.24, -0.08, 0), (cc * 0.3, 0.1, -0.05), 0.02, 0.02, PEAU, fondu=0.0)
        b.cone((cc * 0.3, 0.1, -0.05), (cc * 0.12, 0.2, -0.03), 0.015, 0.015, BAGUETTE, fondu=0.0)
        b.boule((cc * 0.1, 0.21, -0.03), (0.03, 0.03, 0.03), BAGUETTE, fondu=0.0)
    jambes2(s, PEAU, CAISSE, x=0.1, haut=-0.3, r=0.04)
    return s


def pianogre():
    s = Sculpteur("Pianogre")
    NOIR, BLANC_T, NOIR_T, OR = rgb("1d1a26"), rgb("fff8f0"), rgb("15121c"), rgb("f2c04a")
    c = s.membre("Corps")
    c.boite((0, -0.14, 0.08), (0.3, 0.12, 0.28), NOIR, arrondi=0.04)
    c.boite((0, 0.02, 0.18), (0.29, 0.03, 0.18), NOIR, arrondi=0.02, rot=(-30, 0, 0))  # couvercle levé
    t = s.membre("Machoire", "Machoire", (0, -0.06, -0.2))
    t.boite((0, -0.06, -0.24), (0.29, 0.03, 0.06), BLANC_T, arrondi=0.01, fondu=0.0)
    for i in range(12):
        x = -0.27 + i * 0.05
        t.boite((x, -0.06, -0.24), (0.003, 0.031, 0.06), rgb("bfb8b0"), arrondi=0.002, mode="peint")
        if i % 7 not in (2, 6):
            t.boite((x + 0.025, -0.03, -0.22), (0.012, 0.012, 0.04), NOIR_T, arrondi=0.004, fondu=0.0)
    visage(c, -0.17, -0.2, 0.11, 0.045, iris=OR, crocs=False, angle=32)
    for x, z in ((-0.24, -0.12), (0.24, -0.12), (0.0, 0.3)):
        p = s.membre(f"Pied{int((x + 1) * 10)}{int((z + 1) * 10)}", "Patte", (x, -0.26, z), 1 if x > 0 else -1)
        p.cone((x, -0.26, z), (x, -0.42, z), 0.035, 0.03, NOIR, fondu=0.0)
        p.boule((x, -0.45, z), (0.035, 0.025, 0.035), OR, fondu=0.0)
    return s


MONSTRES = {
    "Visseur": visseur,
    "Pistonard": pistonard,
    "Broyeurex": broyeurex,
    "Bambougre": bambougre,
    "Oniboule": oniboule,
    "Komapierre": komapierre,
    "Stalagmord": stalagmord,
    "Vercaillou": vercaillou,
    "Rocgrondeur": rocgrondeur,
    "Billerage": billerage,
    "Tamboum": tamboum,
    "Pianogre": pianogre,
}

_ = (joues, piquants, _sourcils)
