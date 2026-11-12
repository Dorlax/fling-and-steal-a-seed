"""Monstres en voxels : Automne, Ferme, Rêves, Plage."""

import math

from monstres import _crocs, _sourcils
from monstres_aide import BLANC, bras2, jambes2, joues, pattes4, piquants, rgb, tentacule, visage
from sculpteur import Sculpteur

# ----------------------------------------------------------------- Automne


def chataigneux():
    s = Sculpteur("Chataigneux")
    BOGUE, PIQUE, MARRON, CLAIR = rgb("8ab04a"), rgb("5a7a2a"), rgb("8a4a2a"), rgb("c08a5a")
    c = s.membre("Corps")
    c.boule((0, -0.18, 0.02), (0.25, 0.24, 0.25), BOGUE)
    piquants(c, (0, -0.18, 0.02), 0.22, PIQUE, BOGUE, n_th=10, n_ph=6, longueur=0.1, r=0.022)
    c.boule((0, -0.16, -0.2), (0.16, 0.15, 0.08), MARRON, fondu=0.02)  # la châtaigne qui sort
    c.boule((0, -0.06, -0.22), (0.11, 0.04, 0.05), CLAIR, mode="peint")
    visage(c, -0.15, -0.28, 0.07, 0.04, iris=rgb("ffd23a"), angle=28, bouche_y=-0.25)
    for cc, nom in ((-1, "PatteG"), (1, "PatteD")):
        p = s.membre(nom, "Patte", (cc * 0.12, -0.38, 0), cc, 0.0 if cc < 0 else 0.5)
        p.boule((cc * 0.12, -0.45, -0.02), (0.06, 0.03, 0.08), MARRON, fondu=0.02)
    return s


def epouvantou():
    s = Sculpteur("Epouvantou")
    PAILLE, CHEMISE, CARREAU, CHAPEAU, SAC = rgb("f2c84a"), rgb("e6403a"), rgb("a02a2a"), rgb("6a4a2a"), rgb("e6cfa0")
    c = s.membre("Corps")
    c.boite((0, -0.08, 0), (0.15, 0.17, 0.09), CHEMISE, arrondi=0.04)
    for x in (-0.08, 0.0, 0.08):
        c.boite((x, -0.08, -0.09), (0.006, 0.17, 0.004), CARREAU, arrondi=0.003, mode="peint")
    for y in (-0.15, -0.02):
        c.boite((0, y, -0.09), (0.15, 0.006, 0.004), CARREAU, arrondi=0.003, mode="peint")
    t = s.membre("Tete", "Tete", (0, 0.1, 0))
    t.boule((0, 0.2, 0), (0.12, 0.12, 0.11), SAC)
    t.boule((0, 0.32, 0), (0.22, 0.02, 0.2), CHAPEAU, fondu=0.0)
    t.cone((0, 0.32, 0), (0, 0.45, 0.02), 0.1, 0.06, CHAPEAU, fondu=0.0)
    t.boite((-0.05, 0.22, -0.11), (0.025, 0.004, 0.004), rgb("2a1a14"), rot=(0, 0, 45), arrondi=0.002, fondu=0.0)
    t.boite((-0.05, 0.22, -0.11), (0.025, 0.004, 0.004), rgb("2a1a14"), rot=(0, 0, -45), arrondi=0.002, fondu=0.0)
    t.oeil((0.05, 0.22, -0.1), 0.03, iris=rgb("ff8a2a"))
    _sourcils(t, 0.27, -0.11, 0.05, 0.045, 26)
    t.courbe([(-0.06, 0.13, -0.1), (0.0, 0.15, -0.11), (0.06, 0.13, -0.1)], [0.006, 0.006, 0.006], rgb("2a1a14"), fondu=0.0)
    for cc, nom in ((-1, "BrasG"), (1, "BrasD")):
        b = s.membre(nom, "Bras", (cc * 0.14, 0.02, 0), cc, 0.0 if cc < 0 else 0.5)
        b.cone((cc * 0.14, 0.02, 0), (cc * 0.38, 0.04, 0), 0.04, 0.035, CHEMISE, fondu=0.0)
        for dy in (-0.03, 0.0, 0.03):
            b.cone((cc * 0.38, 0.04, 0), (cc * 0.46, 0.04 + dy, 0), 0.012, 0.004, PAILLE, fondu=0.0)
    for cc, nom in ((-1, "PatteG"), (1, "PatteD")):
        p = s.membre(nom, "Patte", (cc * 0.06, -0.25, 0), cc, 0.0 if cc < 0 else 0.5)
        p.cone((cc * 0.06, -0.24, 0), (cc * 0.08, -0.46, 0), 0.025, 0.02, rgb("8a6a3a"), fondu=0.0)
        for dx in (-0.025, 0.025):
            p.cone((cc * 0.08, -0.4, 0), (cc * 0.08 + dx, -0.47, -0.02), 0.01, 0.004, PAILLE, fondu=0.0)
    return s


def souchegrogne():
    s = Sculpteur("Souchegrogne")
    ECORCE, FONCE, CERNES, MOUSSE, CHAMPI = rgb("8a5a3a"), rgb("5a3a20"), rgb("e6c48a"), rgb("6aa04a"), rgb("ff8a3a")
    c = s.membre("Corps")
    c.cylindre((0, -0.15, 0), 0.26, 0.2, ECORCE, arrondi=0.05)
    c.cylindre((0, 0.05, 0), 0.24, 0.012, CERNES, arrondi=0.01, mode="peint")
    for r in (0.07, 0.14, 0.2):
        c.boule((0, 0.06, 0), (r, 0.004, r), FONCE, mode="peint")
    for i in range(8):
        a = i / 8 * 2 * math.pi
        c.boite((math.cos(a) * 0.26, -0.15, math.sin(a) * 0.26), (0.012, 0.18, 0.012), FONCE, arrondi=0.008, mode="peint")
    c.boule((0.2, -0.05, 0.1), (0.08, 0.05, 0.06), MOUSSE, mode="peint")
    for x, z in ((0.12, 0.1), (-0.14, 0.08)):
        c.cone((x, 0.06, z), (x, 0.12, z), 0.012, 0.012, CERNES, fondu=0.0)
        c.boule((x, 0.13, z), (0.04, 0.02, 0.04), CHAMPI, fondu=0.0)
    visage(c, -0.08, -0.24, 0.09, 0.045, iris=rgb("ffd23a"), angle=32, bouche_y=-0.2)
    for i in range(4):
        a = (i + 0.5) / 4 * 2 * math.pi
        cc = 1 if math.cos(a) > 0 else -1
        p = s.membre(f"Racine{i + 1}", "Patte", (math.cos(a) * 0.2, -0.33, math.sin(a) * 0.2), cc, i * 0.25)
        p.courbe([(math.cos(a) * 0.2, -0.33, math.sin(a) * 0.2), (math.cos(a) * 0.32, -0.42, math.sin(a) * 0.32),
                  (math.cos(a) * 0.4, -0.465, math.sin(a) * 0.4)], [0.055, 0.04, 0.025], FONCE)
    return s


# ------------------------------------------------------------------- Ferme


def corbinard():
    s = Sculpteur("Corbinard")
    NOIR, REFLET, BEC, BRILLANT = rgb("2a2a3a"), rgb("4a4a7a"), rgb("ffb03a"), rgb("ffe06a")
    c = s.membre("Corps")
    c.boule((0, -0.15, 0.04), (0.17, 0.19, 0.21), NOIR)
    c.boule((0, -0.1, 0.08), (0.1, 0.06, 0.12), REFLET, mode="peint")
    t = s.membre("Tete", "Tete", (0, 0.04, -0.06))
    t.boule((0, 0.12, -0.08), (0.13, 0.12, 0.12), NOIR)
    t.cone((0, 0.1, -0.18), (0, 0.08, -0.3), 0.045, 0.008, BEC, fondu=0.0)
    visage(t, 0.16, -0.18, 0.06, 0.035, crocs=False, angle=30)
    t.boule((0.0, 0.05, -0.3), (0.025, 0.025, 0.025), BRILLANT, fondu=0.0)  # pièce volée dans le bec
    for cc, nom in ((-1, "AileG"), (1, "AileD")):
        a = s.membre(nom, "Aile", (cc * 0.16, -0.06, 0.04), cc)
        a.boule((cc * 0.22, -0.1, 0.08), (0.06, 0.13, 0.15), NOIR, fondu=0.0)
        a.boule((cc * 0.25, -0.15, 0.12), (0.03, 0.08, 0.1), REFLET, mode="peint")
    q = s.membre("Queue", "Queue", (0, -0.18, 0.24))
    q.boule((0, -0.22, 0.32), (0.08, 0.025, 0.09), NOIR, rot=(30, 0, 0), fondu=0.0)
    for cc, nom in ((-1, "PatteG"), (1, "PatteD")):
        p = s.membre(nom, "Patte", (cc * 0.07, -0.32, 0.03), cc, 0.0 if cc < 0 else 0.5)
        p.cone((cc * 0.07, -0.32, 0.03), (cc * 0.07, -0.46, 0.01), 0.02, 0.018, BEC, fondu=0.0)
        for dx, dz in ((-0.03, -0.05), (0.0, -0.06), (0.03, -0.05)):
            p.cone((cc * 0.07, -0.47, 0.01), (cc * 0.07 + dx, -0.475, 0.01 + dz), 0.016, 0.01, BEC, fondu=0.01)
    return s


def biqueboum():
    s = Sculpteur("Biqueboum")
    POIL, OMBRE, CORNE, SABOT = rgb("f2ece2"), rgb("c8bca8"), rgb("8a7a6a"), rgb("4a3a30")
    c = s.membre("Corps")
    c.boule((0, -0.1, 0.08), (0.17, 0.16, 0.25), POIL)
    t = s.membre("Tete", "Tete", (0, 0.0, -0.16))
    t.boule((0, 0.04, -0.24), (0.12, 0.12, 0.12), POIL)
    t.boule((0, -0.02, -0.34), (0.07, 0.06, 0.06), POIL, fondu=0.03)
    t.cone((0, -0.08, -0.32), (0, -0.2, -0.3), 0.03, 0.008, OMBRE, fondu=0.0)  # barbiche
    visage(t, 0.07, -0.33, 0.06, 0.035, iris=rgb("ffb03a"), crocs=False, angle=34)
    for cc in (-1, 1):
        t.courbe([(cc * 0.06, 0.13, -0.24), (cc * 0.1, 0.22, -0.3), (cc * 0.12, 0.24, -0.4)], [0.035, 0.025, 0.008], CORNE)
    for cc, nom in ((-1, "OreilleG"), (1, "OreilleD")):
        o = s.membre(nom, "Oreille", (cc * 0.1, 0.08, -0.22), cc)
        o.boule((cc * 0.17, 0.06, -0.22), (0.06, 0.02, 0.03), POIL, rot=(0, 0, cc * -20), fondu=0.0)
    q = s.membre("Queue", "Queue", (0, 0.0, 0.32))
    q.cone((0, 0.0, 0.32), (0, 0.08, 0.38), 0.03, 0.01, POIL, fondu=0.0)
    pattes4(s, POIL, SABOT, x=0.11, z_av=-0.08, z_ar=0.22, haut=-0.2, r=0.04, corps=c)
    return s


def moissogre():
    s = Sculpteur("Moissogre")
    ROUGE, FONCE, LAME, PNEU, VERRE = rgb("e6403a"), rgb("8a2a2a"), rgb("d8dce6"), rgb("2a2a30"), rgb("bfe6ff")
    c = s.membre("Corps")
    c.boite((0, -0.08, 0.1), (0.24, 0.17, 0.24), ROUGE, arrondi=0.05)
    c.boite((0, 0.15, 0.16), (0.13, 0.09, 0.11), ROUGE, arrondi=0.03)  # cabine
    c.boite((0, 0.16, 0.05), (0.11, 0.06, 0.005), VERRE, arrondi=0.01, mode="peint", plat=True)
    visage(c, 0.16, 0.04, 0.05, 0.035, iris=rgb("ffd23a"), crocs=False, angle=28)
    c.cylindre((0.18, 0.18, 0.28), 0.03, 0.08, FONCE, arrondi=0.01)
    m = s.membre("Rabatteur", "Machoire", (0, -0.12, -0.16))
    m.boite((0, -0.22, -0.24), (0.3, 0.04, 0.08), FONCE, arrondi=0.02, fondu=0.0)
    for i in range(9):
        x = -0.28 + i * 0.07
        m.cone((x, -0.24, -0.3), (x, -0.25, -0.38), 0.025, 0.004, LAME, fondu=0.0)
    m.cylindre((0, -0.12, -0.26), 0.02, 0.02, LAME, arrondi=0.005)
    for cc, nom in ((-1, "RoueG"), (1, "RoueD")):
        r = s.membre(nom, "Patte", (cc * 0.24, -0.3, 0.1), cc, 0.0 if cc < 0 else 0.5)
        r.boule((cc * 0.25, -0.32, -0.02), (0.05, 0.14, 0.14), PNEU, fondu=0.0)
        r.boule((cc * 0.25, -0.36, 0.26), (0.05, 0.1, 0.1), PNEU, fondu=0.0)
        r.boule((cc * 0.28, -0.32, -0.02), (0.02, 0.06, 0.06), rgb("ffd23a"), mode="peint")
    return s


# ------------------------------------------------------------------- Rêves


def cauchemou():
    s = Sculpteur("Cauchemou")
    DRAP, OMBRE, LUEUR = rgb("2a2440"), rgb("4a3e6a"), rgb("ff6ad8")
    c = s.membre("Corps")
    c.boule((0, 0.06, 0), (0.22, 0.26, 0.2), DRAP)
    c.cone((0, -0.05, 0), (0, -0.38, 0), 0.22, 0.3, DRAP, fondu=0.06)
    for i in range(7):
        a = i / 7 * 2 * math.pi
        c.boule((math.cos(a) * 0.26, -0.42, math.sin(a) * 0.26), (0.07, 0.05, 0.07), DRAP, fondu=0.03)
    c.boule((0.1, 0.18, -0.1), (0.06, 0.08, 0.05), OMBRE, mode="peint")
    for cc in (-1, 1):
        c.boule((cc * 0.08, 0.1, -0.19), (0.04, 0.05, 0.02), LUEUR, fondu=0.0, plat=True)
    _sourcils(c, 0.17, -0.2, 0.08, 0.06, 26, rgb("15121c"))
    c.boule((0, -0.02, -0.2), (0.07, 0.05, 0.02), rgb("15121c"), fondu=0.0, plat=True)  # « bouh ! »
    for cc, nom in ((-1, "BrasG"), (1, "BrasD")):
        b = s.membre(nom, "Bras", (cc * 0.2, 0.0, 0), cc, 0.0 if cc < 0 else 0.5)
        b.cone((cc * 0.2, 0.0, 0), (cc * 0.34, 0.12, -0.06), 0.06, 0.03, DRAP, fondu=0.0)
    return s


def ronfleur():
    s = Sculpteur("Ronfleur")
    PYJAMA, RAYURE, PEAU, BONNET, BULLE = rgb("6a8ae6"), rgb("bfd0ff"), rgb("ffd8b4"), rgb("e6403a"), rgb("d8f2ff")
    c = s.membre("Corps")
    c.boule((0, -0.16, 0.02), (0.27, 0.28, 0.24), PYJAMA)
    for x in (-0.18, -0.06, 0.06, 0.18):
        c.boite((x, -0.16, 0), (0.015, 0.27, 0.25), RAYURE, arrondi=0.01, mode="peint")
    t = s.membre("Tete", "Tete", (0, 0.1, 0))
    t.boule((0, 0.2, -0.02), (0.15, 0.14, 0.14), PEAU)
    t.cone((0, 0.3, 0.0), (0.12, 0.4, 0.12), 0.13, 0.02, BONNET, fondu=0.0)
    t.boule((0.13, 0.41, 0.13), (0.035, 0.035, 0.035), BLANC, fondu=0.0)
    for cc in (-1, 1):  # yeux fermés, il dort
        t.courbe([(cc * 0.09, 0.22, -0.145), (cc * 0.06, 0.21, -0.15), (cc * 0.03, 0.22, -0.145)], [0.008, 0.008, 0.008],
                 rgb("2a1a14"), fondu=0.0)
    _sourcils(t, 0.26, -0.15, 0.06, 0.05, 22)
    t.boule((0, 0.13, -0.14), (0.04, 0.03, 0.02), rgb("8a3a3a"), fondu=0.0, plat=True)
    joues(t, 0.15, -0.13, 0.1)
    b = s.membre("Bulle", "Antenne", (0.08, 0.13, -0.16))
    b.boule((0.12, 0.08, -0.28), (0.08, 0.08, 0.08), BULLE, fondu=0.0)
    b.boule((0.09, 0.11, -0.34), (0.02, 0.02, 0.02), BLANC, mode="peint", plat=True)
    bras2(s, PYJAMA, PEAU, x=0.26, y=-0.05, longueur=0.15, r=0.055, poing=0.065, corps=c)
    jambes2(s, PYJAMA, rgb("8a5a3a"), x=0.12, haut=-0.36, r=0.07, corps=c)
    return s


def placardeur():
    s = Sculpteur("Placardeur")
    BOIS, FONCE, NOIR, OEIL, POIGNEE = rgb("8a5a8a"), rgb("5a3a5a"), rgb("15121c"), rgb("ffe03a"), rgb("f2c04a")
    c = s.membre("Corps")
    c.boite((0, -0.04, 0.05), (0.26, 0.4, 0.18), BOIS, arrondi=0.03)
    c.boite((0, -0.04, -0.13), (0.22, 0.36, 0.01), NOIR, arrondi=0.005, mode="creux")  # porte entrouverte : le noir
    for x, y in ((-0.1, 0.12), (0.08, 0.15), (-0.04, -0.12), (0.1, -0.05)):
        c.oeil((x, y, -0.12), 0.03, iris=OEIL)
    _sourcils(c, 0.2, -0.13, 0.09, 0.05, 26, OEIL)
    for i in range(5):
        x = -0.12 + i * 0.06
        c.cone((x, -0.3, -0.12), (x, -0.36, -0.13), 0.02, 0.003, BLANC, fondu=0.0)
    for cc, nom in ((-1, "PorteG"), (1, "PorteD")):
        p = s.membre(nom, "Bascule", (cc * 0.25, -0.04, -0.14), cc)
        p.boite((cc * 0.3, -0.04, -0.22), (0.015, 0.37, 0.1), FONCE, arrondi=0.01, rot=(0, cc * 60, 0), fondu=0.0)
        p.boule((cc * 0.27, -0.02, -0.29), (0.02, 0.02, 0.02), POIGNEE, fondu=0.0)
    for x in (-0.2, 0.2):
        c.cone((x, -0.44, 0.05), (x, -0.47, 0.05), 0.04, 0.03, FONCE, fondu=0.0)
    return s


# ------------------------------------------------------------------- Plage


def crabogre():
    s = Sculpteur("Crabogre")
    ROUGE, CLAIR, FONCE = rgb("ff5a3a"), rgb("ffa08a"), rgb("a02a1a")
    c = s.membre("Corps")
    c.boule((0, -0.2, 0.06), (0.26, 0.14, 0.2), ROUGE)
    c.boule((0, -0.27, 0.04), (0.2, 0.06, 0.16), CLAIR, mode="peint")
    for cc in (-1, 1):
        c.cone((cc * 0.07, -0.12, -0.08), (cc * 0.08, 0.04, -0.12), 0.02, 0.018, ROUGE, fondu=0.0)
        c.oeil((cc * 0.08, 0.06, -0.13), 0.04)
    _sourcils(c, 0.12, -0.15, 0.08, 0.05, 30)
    c.boule((0, -0.22, -0.13), (0.06, 0.02, 0.02), rgb("2a1030"), fondu=0.0, plat=True)
    for cc, nom in ((-1, "PinceG"), (1, "PinceD")):
        b = s.membre(nom, "Bras", (cc * 0.22, -0.18, -0.08), cc, 0.0 if cc < 0 else 0.5)
        b.cone((cc * 0.22, -0.18, -0.08), (cc * 0.32, -0.08, -0.2), 0.035, 0.03, ROUGE, fondu=0.0)
        b.boule((cc * 0.34, -0.02, -0.25), (0.11, 0.09, 0.08), ROUGE, fondu=0.02)  # pince énorme
        b.boule((cc * 0.38, 0.06, -0.3), (0.06, 0.035, 0.05), ROUGE, fondu=0.0)
        b.boule((cc * 0.34, -0.01, -0.32), (0.05, 0.015, 0.02), FONCE, mode="creux")
    for i, z in enumerate((-0.02, 0.08, 0.18)):
        for cc, cote in ((-1, "G"), (1, "D")):
            p = s.membre(f"Patte{i + 1}{cote}", "Patte", (cc * 0.2, -0.24, z), cc, (i / 3) if cc < 0 else 0.5 - i / 3)
            p.courbe([(cc * 0.2, -0.24, z), (cc * 0.32, -0.26, z + 0.02), (cc * 0.36, -0.46, z + 0.04)], [0.025, 0.02, 0.01],
                     ROUGE)
    return s


def meduselle():
    s = Sculpteur("Meduselle")
    ROSE, CLAIR, LUEUR = rgb("ff8ad8"), rgb("ffd0f0"), rgb("8af2ff")
    c = s.membre("Corps")
    c.boule((0, 0.14, 0), (0.25, 0.2, 0.25), ROSE)
    c.boule((0, 0.02, 0), (0.27, 0.05, 0.27), CLAIR, fondu=0.03)
    for x, y, z in ((-0.12, 0.25, -0.15), (0.14, 0.28, -0.1), (0.0, 0.32, 0.12)):
        c.boule((x, y, z), (0.03, 0.03, 0.03), LUEUR, mode="peint", plat=True)
    visage(c, 0.12, -0.22, 0.09, 0.045, angle=26, bouche_y=0.05)
    joues(c, 0.06, -0.2, 0.15)
    for i in range(6):
        a = i / 6 * 2 * math.pi + 0.2
        dx, dz = math.cos(a) * 0.17, math.sin(a) * 0.17
        pts = [(dx, -0.02, dz), (dx * 1.1, -0.18, dz * 1.1), (dx * 0.9, -0.32, dz * 0.9), (dx * 1.15, -0.44, dz * 1.15)]
        tentacule(s, f"Tentacule{i + 1}", pts[0], pts, [0.028, 0.022, 0.018, 0.012], CLAIR, cote=1 if dx > 0 else -1,
                  phase=i / 6, bout=LUEUR)
    return s


def rouleaugre():
    s = Sculpteur("Rouleaugre")
    EAU, FONCE, ECUME, SABLE = rgb("3a8ae6"), rgb("1a5ab0"), rgb("f2fbff"), rgb("f2d8a0")
    c = s.membre("Corps")
    c.boule((0, -0.38, 0.05), (0.42, 0.08, 0.32), FONCE)
    c.courbe([(0, -0.35, 0.25), (0, -0.05, 0.22), (0, 0.18, 0.05), (0, 0.18, -0.15), (0, 0.04, -0.25)],
             [0.2, 0.22, 0.2, 0.16, 0.1], EAU)
    for x in (-0.3, -0.15, 0.0, 0.15, 0.3):
        c.boule((x, -0.2, 0.18), (0.13, 0.2, 0.12), EAU, fondu=0.08)
    for x in (-0.28, -0.12, 0.04, 0.2, 0.32):
        c.boule((x, 0.26, -0.02), (0.08, 0.06, 0.08), ECUME, fondu=0.02)
        c.boule((x + 0.05, 0.1, -0.24), (0.05, 0.04, 0.05), ECUME, fondu=0.02)
    c.boule((0, -0.45, -0.25), (0.35, 0.03, 0.1), SABLE, fondu=0.0)
    visage(c, 0.0, -0.36, 0.1, 0.05, angle=30, bouche_y=-0.15)
    for i, (x, y, z) in enumerate(((-0.32, 0.36, 0.0), (0.3, 0.33, -0.05))):
        g = s.membre(f"Goutte{i + 1}", "Antenne", (x * 0.8, y - 0.06, z))
        g.boule((x, y, z), (0.035, 0.045, 0.035), ECUME, fondu=0.0)
    return s


MONSTRES = {
    "Chataigneux": chataigneux,
    "Epouvantou": epouvantou,
    "Souchegrogne": souchegrogne,
    "Corbinard": corbinard,
    "Biqueboum": biqueboum,
    "Moissogre": moissogre,
    "Cauchemou": cauchemou,
    "Ronfleur": ronfleur,
    "Placardeur": placardeur,
    "Crabogre": crabogre,
    "Meduselle": meduselle,
    "Rouleaugre": rouleaugre,
}

_ = (_crocs, bras2)
