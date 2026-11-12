"""Monstres en voxels : Jungle, Ciel, Manoir, Savane."""

import math

from monstres import _crocs, _sourcils
from monstres_aide import BLANC, bras2, jambes2, pattes4, rgb, visage
from sculpteur import Sculpteur

# ------------------------------------------------------------------ Jungle


def fourmigeant():
    s = Sculpteur("Fourmigeant")
    ROUGE, FONCE, MANDI = rgb("c0402a"), rgb("6a1a10"), rgb("2a1a14")
    c = s.membre("Corps")
    c.boule((0, -0.18, 0.22), (0.14, 0.13, 0.17), ROUGE)
    c.boule((0, -0.16, 0.0), (0.09, 0.08, 0.1), ROUGE, fondu=0.03)
    t = s.membre("Tete", "Tete", (0, -0.12, -0.1))
    t.boule((0, -0.1, -0.18), (0.13, 0.12, 0.11), ROUGE)
    visage(t, -0.06, -0.27, 0.06, 0.04, crocs=False, angle=28)
    for cc, nom in ((-1, "AntenneG"), (1, "AntenneD")):
        a = s.membre(nom, "Antenne", (cc * 0.05, 0.0, -0.2), cc)
        a.courbe([(cc * 0.05, 0.0, -0.2), (cc * 0.1, 0.12, -0.24), (cc * 0.16, 0.16, -0.32)], [0.012, 0.01, 0.008], FONCE)
        a.boule((cc * 0.16, 0.16, -0.32), (0.02, 0.02, 0.02), FONCE, fondu=0.0)
    m = s.membre("Machoire", "Machoire", (0, -0.15, -0.26))
    for cc in (-1, 1):
        m.courbe([(cc * 0.05, -0.15, -0.27), (cc * 0.08, -0.17, -0.34), (cc * 0.02, -0.18, -0.39)], [0.022, 0.016, 0.008],
                 MANDI, fondu=0.0)
    for i, z in enumerate((-0.04, 0.04, 0.12)):
        for cc, cote in ((-1, "G"), (1, "D")):
            p = s.membre(f"Patte{i + 1}{cote}", "Patte", (cc * 0.07, -0.18, z), cc, (i / 3) if cc < 0 else 0.5 - i / 3)
            p.courbe([(cc * 0.07, -0.18, z), (cc * 0.2, -0.22, z), (cc * 0.25, -0.46, z + 0.02)], [0.02, 0.016, 0.012],
                     FONCE)
    return s


def serpentacle():
    s = Sculpteur("Serpentacle")
    VERT, JAUNE, ROUGE, LANGUE = rgb("3ab04a"), rgb("ffd23a"), rgb("e6402a"), rgb("ff3a6a")
    c = s.membre("Corps")
    pts = [(0.0, -0.42, 0.3), (0.2, -0.42, 0.18), (0.18, -0.42, -0.05), (-0.05, -0.4, -0.1), (-0.18, -0.38, 0.08),
           (-0.05, -0.3, 0.12), (0.0, -0.12, 0.02)]
    c.courbe(pts, [0.04, 0.065, 0.075, 0.08, 0.08, 0.075, 0.07], VERT)
    for i in range(len(pts) - 1):
        a, b = pts[i], pts[i + 1]
        mid = tuple((a[k] + b[k]) / 2 for k in range(3))
        c.boule(mid, (0.085, 0.085, 0.085), JAUNE if i % 2 else ROUGE, mode="peint")
    t = s.membre("Tete", "Tete", (0, -0.06, -0.02))
    t.boule((0, 0.02, -0.08), (0.12, 0.09, 0.14), VERT)
    visage(t, 0.06, -0.19, 0.06, 0.035, iris=JAUNE, crocs=False, angle=30)
    _crocs(t, -0.02, -0.21, 0.04, 0.025)
    t.courbe([(0, -0.01, -0.2), (0, -0.02, -0.28), (0.02, -0.03, -0.32)], [0.012, 0.01, 0.006], LANGUE, fondu=0.0)
    return s


def plantegloutonne():
    s = Sculpteur("Plantegloutonne")
    TIGE, FEUILLE, BOUCHE, POIS, DENT = rgb("3a8a3a"), rgb("5ac04a"), rgb("e6304a"), rgb("fff2b0"), rgb("fffaf0")
    c = s.membre("Corps")
    c.boule((0, -0.42, 0), (0.25, 0.06, 0.25), rgb("6a4a2a"))  # pot de terre
    c.courbe([(0, -0.42, 0), (0.04, -0.25, 0.04), (-0.02, -0.08, 0.02)], [0.06, 0.055, 0.05], TIGE)
    for cc in (-1, 1):
        c.boule((cc * 0.2, -0.36, 0.0), (0.15, 0.03, 0.08), FEUILLE, rot=(0, 0, cc * 20), fondu=0.02)
    t = s.membre("Tete", "Tete", (0, -0.06, 0))
    t.boule((0, 0.15, -0.02), (0.26, 0.22, 0.24), BOUCHE)
    for x, y, z in ((-0.15, 0.3, 0.05), (0.12, 0.32, 0.1), (0.2, 0.15, 0.14), (-0.2, 0.1, 0.12), (0.0, 0.36, -0.05)):
        t.boule((x, y, z), (0.03, 0.03, 0.03), POIS, mode="peint")
    t.boule((0, 0.11, -0.2), (0.2, 0.05, 0.1), rgb("4a0a1a"), mode="creux")
    for i in range(6):
        x = -0.15 + i * 0.06
        t.cone((x, 0.16, -0.22), (x, 0.09, -0.24), 0.02, 0.003, DENT, fondu=0.0)
        t.cone((x + 0.03, 0.04, -0.22), (x + 0.03, 0.1, -0.24), 0.018, 0.003, DENT, fondu=0.0)
    visage(t, 0.25, -0.2, 0.09, 0.045, crocs=False, angle=26)
    for cc, nom in ((-1, "FeuilleG"), (1, "FeuilleD")):
        b = s.membre(nom, "Bras", (cc * 0.04, -0.2, 0), cc, 0.0 if cc < 0 else 0.5)
        b.boule((cc * 0.22, -0.18, 0.0), (0.18, 0.035, 0.08), FEUILLE, rot=(0, 0, cc * -25), fondu=0.0)
    return s


# -------------------------------------------------------------------- Ciel


def orageon():
    s = Sculpteur("Orageon")
    NUAGE, FONCE, ECLAIR = rgb("6a7a9a"), rgb("4a5470"), rgb("ffe03a")
    c = s.membre("Corps")
    for x, y, z, r in ((0, -0.05, 0, 0.22), (-0.2, -0.1, 0.02, 0.15), (0.2, -0.1, 0.0, 0.16), (0.05, 0.1, 0.05, 0.16),
                       (-0.1, 0.06, 0.08, 0.13)):
        c.boule((x, y, z), (r, r * 0.9, r), NUAGE, fondu=0.05)
    c.boule((0, -0.2, 0.0), (0.3, 0.06, 0.18), FONCE, mode="peint")
    visage(c, -0.02, -0.21, 0.09, 0.045, bouche_y=-0.12)
    e = s.membre("Eclair", "Pendule", (0, -0.22, 0))
    e.courbe([(0.02, -0.22, 0), (-0.05, -0.3, 0), (0.04, -0.34, 0), (-0.03, -0.45, 0)], [0.025, 0.022, 0.02, 0.008],
             ECLAIR, fondu=0.0)
    return s


def corbeauvent():
    s = Sculpteur("Corbeauvent")
    NOIR, BLEU, BEC, VENT = rgb("2a2a4a"), rgb("4a5a9a"), rgb("ffb03a"), rgb("bfe6ff")
    c = s.membre("Corps")
    c.boule((0, -0.12, 0.05), (0.17, 0.2, 0.22), NOIR)
    c.boule((0, -0.15, -0.08), (0.1, 0.13, 0.08), BLEU, mode="peint")
    t = s.membre("Tete", "Tete", (0, 0.06, -0.06))
    t.boule((0, 0.15, -0.08), (0.13, 0.12, 0.12), NOIR)
    t.cone((0, 0.13, -0.18), (0, 0.1, -0.32), 0.05, 0.008, BEC, fondu=0.0)
    visage(t, 0.18, -0.18, 0.06, 0.035, iris=rgb("ff3a3a"), crocs=False, angle=30)
    for i in range(3):
        t.cone((0, 0.24, -0.04 + i * 0.04), (0, 0.33 - i * 0.02, 0.02 + i * 0.04), 0.025, 0.006, BLEU, fondu=0.01)
    for cc, nom in ((-1, "AileG"), (1, "AileD")):
        a = s.membre(nom, "Aile", (cc * 0.16, 0.0, 0.05), cc)
        a.boule((cc * 0.32, 0.02, 0.08), (0.2, 0.07, 0.025), NOIR, rot=(0, 0, cc * -15), fondu=0.0)
        for k in range(3):
            a.cone((cc * (0.42 + k * 0.02), -0.02 - k * 0.03, 0.06), (cc * (0.52 + k * 0.02), -0.05 - k * 0.03, 0.1),
                   0.02, 0.005, BLEU, fondu=0.0)
        a.courbe([(cc * 0.3, 0.1, 0.0), (cc * 0.4, 0.14, 0.04), (cc * 0.48, 0.12, 0.08)], [0.006, 0.006, 0.004], VENT,
                 fondu=0.0)
    q = s.membre("Queue", "Queue", (0, -0.2, 0.25))
    q.boule((0, -0.24, 0.34), (0.1, 0.025, 0.1), NOIR, rot=(25, 0, 0), fondu=0.0)
    for cc, nom in ((-1, "PatteG"), (1, "PatteD")):
        p = s.membre(nom, "Patte", (cc * 0.07, -0.3, 0.04), cc, 0.0 if cc < 0 else 0.5)
        p.cone((cc * 0.07, -0.3, 0.04), (cc * 0.07, -0.46, 0.02), 0.022, 0.02, BEC, fondu=0.0)
        for dx, dz in ((-0.03, -0.05), (0.0, -0.06), (0.03, -0.05)):
            p.cone((cc * 0.07, -0.47, 0.02), (cc * 0.07 + dx, -0.475, 0.02 + dz), 0.018, 0.01, BEC, fondu=0.01)
    return s


def tornadogre():
    s = Sculpteur("Tornadogre")
    VENT, CLAIR, FONCE = rgb("8aa8c8"), rgb("d8ecff"), rgb("5a7898")
    c = s.membre("Corps")
    c.cone((0, -0.46, 0), (0, 0.3, 0), 0.06, 0.34, VENT, fondu=0.0)
    for i in range(9):
        y = -0.4 + i * 0.085
        r = 0.08 + (y + 0.46) / 0.76 * 0.28
        c.boite((0, y, 0), (r + 0.01, 0.01, r + 0.01), CLAIR if i % 2 else FONCE, arrondi=0.01,
                rot=(8 * (-1) ** i, i * 20, 0), mode="peint")
    visage(c, 0.12, -0.27, 0.11, 0.055, iris=rgb("ffe03a"), angle=30, bouche_y=0.0)
    for i, (x, y, z) in enumerate(((-0.3, 0.2, 0.0), (0.32, -0.05, 0.1), (-0.2, -0.2, 0.15))):
        d = s.membre(f"Debris{i + 1}", "Antenne", (x * 0.7, y, z))
        d.boite((x, y, z), (0.03, 0.03, 0.03), rgb("8a6a4a"), arrondi=0.01, rot=(30, 40, 10), fondu=0.0)
    return s


# ------------------------------------------------------------------ Manoir


def toilou():
    s = Sculpteur("Toilou")
    POIL, FONCE, ROUGE = rgb("3a2a4a"), rgb("1d1626"), rgb("ff3a5a")
    c = s.membre("Corps")
    c.boule((0, -0.22, 0.08), (0.2, 0.17, 0.2), POIL)
    c.boule((0, -0.18, 0.12), (0.06, 0.04, 0.03), ROUGE, mode="peint")
    c.boule((0, -0.24, -0.12), (0.13, 0.12, 0.1), POIL, fondu=0.03)
    for x in (-0.09, -0.03, 0.03, 0.09):
        c.oeil((x, -0.18, -0.2), 0.028, iris=ROUGE)
    _sourcils(c, -0.13, -0.215, 0.07, 0.05, 20)
    _crocs(c, -0.31, -0.2, 0.03, 0.03)
    for i, z in enumerate((-0.08, 0.0, 0.08, 0.16)):
        for cc, cote in ((-1, "G"), (1, "D")):
            p = s.membre(f"Patte{i + 1}{cote}", "Patte", (cc * 0.14, -0.2, z), cc, (i / 4) if cc < 0 else 0.5 - i / 4)
            p.courbe([(cc * 0.14, -0.2, z), (cc * 0.3, -0.08, z * 1.4), (cc * 0.4, -0.46, z * 1.8)], [0.025, 0.02, 0.012],
                     POIL)
    return s


def momiflet():
    s = Sculpteur("Momiflet")
    BANDE, OMBRE, VIOLET = rgb("e6dcc8"), rgb("b0a48a"), rgb("b46aff")
    c = s.membre("Corps")
    c.boule((0, -0.1, 0), (0.19, 0.24, 0.15), BANDE)
    for i in range(7):
        c.boite((0, -0.3 + i * 0.07, 0), (0.2, 0.008, 0.16), OMBRE, arrondi=0.008, rot=(0, 0, (-1) ** i * 10), mode="peint")
    t = s.membre("Tete", "Tete", (0, 0.14, 0))
    t.boule((0, 0.26, 0), (0.15, 0.14, 0.14), BANDE)
    for i in range(3):
        t.boite((0, 0.18 + i * 0.07, 0), (0.16, 0.008, 0.15), OMBRE, arrondi=0.008, rot=(0, 0, (-1) ** i * 14), mode="peint")
    for cc in (-1, 1):
        t.boule((cc * 0.055, 0.26, -0.13), (0.035, 0.02, 0.02), rgb("1d1626"), fondu=0.0, plat=True)
        t.boule((cc * 0.055, 0.26, -0.145), (0.02, 0.012, 0.01), VIOLET, mode="peint", plat=True)
    _sourcils(t, 0.3, -0.14, 0.055, 0.05, 24, OMBRE)
    q = s.membre("Bandelette", "Queue", (0.0, -0.3, 0.1))
    q.courbe([(0.0, -0.3, 0.12), (0.06, -0.38, 0.24), (0.1, -0.45, 0.36)], [0.04, 0.035, 0.03], BANDE)
    for cc, nom in ((-1, "BrasG"), (1, "BrasD")):
        b = s.membre(nom, "Bras", (cc * 0.18, 0.05, 0), cc, 0.0 if cc < 0 else 0.5)
        b.cone((cc * 0.18, 0.05, 0), (cc * 0.22, 0.02, -0.22), 0.045, 0.04, BANDE, fondu=0.0)  # bras tendus
    jambes2(s, BANDE, OMBRE, x=0.08, haut=-0.3, r=0.055, corps=c)
    return s


def gargouillard():
    s = Sculpteur("Gargouillard")
    PIERRE, FONCE, MOUSSE, OEIL = rgb("8a8a9a"), rgb("5a5a6a"), rgb("6a9a5a"), rgb("ff6a3a")
    c = s.membre("Corps")
    c.boule((0, -0.15, 0.04), (0.2, 0.22, 0.2), PIERRE)
    c.boule((0.1, -0.05, -0.12), (0.06, 0.04, 0.03), MOUSSE, mode="peint")
    t = s.membre("Tete", "Tete", (0, 0.06, -0.06))
    t.boule((0, 0.15, -0.08), (0.14, 0.12, 0.13), PIERRE)
    t.cone((0, 0.12, -0.18), (0, 0.1, -0.26), 0.07, 0.05, PIERRE, fondu=0.03)
    visage(t, 0.18, -0.2, 0.06, 0.035, iris=OEIL, crocs=False, angle=30)
    _crocs(t, 0.05, -0.26, 0.04, 0.03, vers_haut=True)
    for cc in (-1, 1):
        t.courbe([(cc * 0.08, 0.24, -0.06), (cc * 0.14, 0.33, -0.02), (cc * 0.12, 0.4, 0.04)], [0.03, 0.02, 0.006], FONCE)
    for cc, nom in ((-1, "AileG"), (1, "AileD")):
        a = s.membre(nom, "Aile", (cc * 0.14, 0.02, 0.15), cc)
        a.cone((cc * 0.14, 0.02, 0.15), (cc * 0.42, 0.25, 0.22), 0.025, 0.012, FONCE, fondu=0.0)
        a.boule((cc * 0.32, 0.1, 0.22), (0.15, 0.13, 0.015), FONCE, rot=(0, cc * -15, cc * 35), fondu=0.0)
    q = s.membre("Queue", "Queue", (0, -0.25, 0.22))
    q.courbe([(0, -0.25, 0.22), (0.05, -0.35, 0.34), (0.12, -0.36, 0.42)], [0.04, 0.03, 0.015], PIERRE)
    q.cone((0.12, -0.36, 0.42), (0.16, -0.35, 0.47), 0.03, 0.004, FONCE, fondu=0.0)
    bras2(s, PIERRE, FONCE, x=0.2, y=-0.06, longueur=0.16, r=0.05, poing=0.06, corps=c)
    jambes2(s, PIERRE, FONCE, x=0.11, haut=-0.32, r=0.065, corps=c)
    return s


# ------------------------------------------------------------------ Savane


def hyenard():
    s = Sculpteur("Hyenard")
    PELAGE, TACHE, CRINIERE, MUSEAU = rgb("c8a06a"), rgb("6a4a2a"), rgb("4a3a2a"), rgb("3a2a20")
    c = s.membre("Corps")
    c.boule((0, -0.12, 0.06), (0.17, 0.18, 0.28), PELAGE)
    for x, y, z in ((0.12, -0.05, 0.1), (-0.13, -0.1, 0.18), (0.1, -0.15, -0.05), (-0.08, 0.0, 0.0), (0.05, 0.02, 0.24)):
        c.boule((x, y, z), (0.035, 0.035, 0.035), TACHE, mode="peint")
    for i in range(6):
        z = -0.16 + i * 0.07
        c.cone((0, 0.02 - i * 0.01, z), (0, 0.1 - i * 0.012, z + 0.03), 0.03, 0.006, CRINIERE, fondu=0.01)
    t = s.membre("Tete", "Tete", (0, 0.0, -0.2))
    t.boule((0, 0.04, -0.27), (0.14, 0.12, 0.12), PELAGE)
    t.cone((0, 0.0, -0.33), (0, -0.02, -0.43), 0.07, 0.05, MUSEAU, fondu=0.03)
    visage(t, 0.08, -0.36, 0.065, 0.035, iris=rgb("ffd23a"), crocs=False, angle=22)
    t.boule((0, -0.06, -0.39), (0.06, 0.02, 0.03), rgb("2a1030"), fondu=0.0, plat=True)  # ricanement
    _crocs(t, -0.06, -0.415, 0.035, 0.02)
    for cc, nom in ((-1, "OreilleG"), (1, "OreilleD")):
        o = s.membre(nom, "Oreille", (cc * 0.09, 0.14, -0.24), cc)
        o.boule((cc * 0.1, 0.18, -0.23), (0.045, 0.06, 0.02), PELAGE, fondu=0.0)
        o.boule((cc * 0.1, 0.18, -0.25), (0.025, 0.04, 0.01), TACHE, mode="peint")
    q = s.membre("Queue", "Queue", (0, -0.04, 0.34))
    q.courbe([(0, -0.04, 0.33), (0, -0.1, 0.43)], [0.03, 0.02], PELAGE)
    q.boule((0, -0.12, 0.45), (0.04, 0.05, 0.04), CRINIERE, fondu=0.0)
    pattes4(s, PELAGE, TACHE, x=0.12, z_av=-0.1, z_ar=0.22, haut=-0.24, r=0.045, corps=c)
    return s


def vautourbe():
    s = Sculpteur("Vautourbe")
    PLUME, FONCE, PEAU, BEC = rgb("5a3a2a"), rgb("2a1a14"), rgb("ff7a6a"), rgb("e6d2a0")
    c = s.membre("Corps")
    c.boule((0, -0.06, 0.06), (0.18, 0.16, 0.25), PLUME, rot=(-20, 0, 0))
    c.boule((0, 0.06, -0.1), (0.12, 0.05, 0.08), rgb("efe6d8"), fondu=0.05)
    t = s.membre("Tete", "Tete", (0, 0.08, -0.16))
    t.cone((0, 0.08, -0.14), (0, 0.12, -0.24), 0.04, 0.035, PEAU, fondu=0.0)
    t.boule((0, 0.14, -0.27), (0.08, 0.08, 0.09), PEAU)
    t.courbe([(0, 0.13, -0.35), (0, 0.1, -0.42), (0, 0.05, -0.43)], [0.035, 0.022, 0.008], BEC)
    visage(t, 0.17, -0.34, 0.04, 0.028, crocs=False, angle=32)
    for cc, nom in ((-1, "AileG"), (1, "AileD")):
        a = s.membre(nom, "Aile", (cc * 0.15, 0.02, 0.06), cc)
        a.boule((cc * 0.34, 0.06, 0.08), (0.22, 0.06, 0.025), PLUME, rot=(0, 0, cc * -25), fondu=0.0)
        for k in range(4):
            a.cone((cc * (0.48 + k * 0.005), 0.12 - k * 0.04, 0.07), (cc * (0.56 + k * 0.01), 0.16 - k * 0.05, 0.09),
                   0.02, 0.005, FONCE, fondu=0.0)
    q = s.membre("Queue", "Queue", (0, -0.12, 0.28))
    q.boule((0, -0.16, 0.36), (0.09, 0.025, 0.09), FONCE, rot=(30, 0, 0), fondu=0.0)
    for cc, nom in ((-1, "PatteG"), (1, "PatteD")):
        p = s.membre(nom, "Patte", (cc * 0.07, -0.2, 0.06), cc, 0.0 if cc < 0 else 0.5)
        p.cone((cc * 0.07, -0.2, 0.06), (cc * 0.07, -0.46, 0.0), 0.024, 0.02, BEC, fondu=0.0)
        for dx, dz in ((-0.03, -0.05), (0.0, -0.06), (0.03, -0.05)):
            p.cone((cc * 0.07, -0.47, 0.0), (cc * 0.07 + dx, -0.475, dz), 0.018, 0.01, FONCE, fondu=0.01)
    return s


def bufflegrogne():
    s = Sculpteur("Bufflegrogne")
    PEAU, FONCE, CORNE, MUSEAU = rgb("5a3a2a"), rgb("2a1a14"), rgb("efe2c8"), rgb("8a6a5a")
    c = s.membre("Corps")
    c.boule((0, -0.08, 0.08), (0.25, 0.22, 0.3), PEAU)
    c.boule((0, 0.04, -0.06), (0.22, 0.17, 0.18), FONCE, fondu=0.05)  # bosse
    t = s.membre("Tete", "Tete", (0, -0.06, -0.22))
    t.boule((0, -0.08, -0.3), (0.15, 0.13, 0.12), PEAU)
    t.boule((0, -0.14, -0.4), (0.1, 0.07, 0.05), MUSEAU, fondu=0.03)
    for cc in (-1, 1):
        t.boule((cc * 0.035, -0.14, -0.445), (0.015, 0.02, 0.01), FONCE, mode="peint", plat=True)
        t.courbe([(cc * 0.1, 0.0, -0.3), (cc * 0.24, 0.02, -0.3), (cc * 0.3, 0.1, -0.33), (cc * 0.26, 0.17, -0.36)],
                 [0.045, 0.035, 0.025, 0.008], CORNE)
    visage(t, -0.02, -0.4, 0.065, 0.035, iris=rgb("ff4a3a"), crocs=False, angle=34)
    t.boule((0, -0.2, -0.43), (0.025, 0.025, 0.012), rgb("f2c04a"), fondu=0.0)  # anneau au nez
    q = s.membre("Queue", "Queue", (0, 0.0, 0.37))
    q.courbe([(0, 0.0, 0.37), (0, -0.12, 0.44)], [0.02, 0.015], PEAU)
    q.boule((0, -0.15, 0.45), (0.025, 0.04, 0.025), FONCE, fondu=0.0)
    pattes4(s, PEAU, FONCE, x=0.16, z_av=-0.08, z_ar=0.24, haut=-0.2, r=0.065, corps=c)
    return s


MONSTRES = {
    "Fourmigeant": fourmigeant,
    "Serpentacle": serpentacle,
    "Plantegloutonne": plantegloutonne,
    "Orageon": orageon,
    "Corbeauvent": corbeauvent,
    "Tornadogre": tornadogre,
    "Toilou": toilou,
    "Momiflet": momiflet,
    "Gargouillard": gargouillard,
    "Hyenard": hyenard,
    "Vautourbe": vautourbe,
    "Bufflegrogne": bufflegrogne,
}

_ = (BLANC, math)
