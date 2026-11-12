"""Monstres en voxels : Bois Moussu, Dunes, Glacier, Volcan."""

from monstres_aide import BLANC, bras2, jambes2, joues, pattes4, piquants, rgb, visage
from sculpteur import Sculpteur

# ------------------------------------------------------------- Bois Moussu


def champignard():
    s = Sculpteur("Champignard")
    CHAP, POIS, PIED, FONCE = rgb("c0392b"), rgb("fff27a"), rgb("f3e3c3"), rgb("8a5a3a")
    c = s.membre("Corps")
    c.boule((0, -0.2, 0), (0.2, 0.24, 0.19), PIED)
    t = s.membre("Tete", "Tete", (0, 0.02, 0))
    t.boule((0, 0.12, 0), (0.42, 0.2, 0.4), CHAP)
    t.boule((0, 0.02, 0), (0.38, 0.06, 0.36), rgb("e8c8a0"), mode="peint")
    for x, y, z, r in ((-0.2, 0.22, -0.18, 0.06), (0.18, 0.25, -0.12, 0.07), (0.02, 0.3, 0.06, 0.08),
                       (-0.26, 0.16, 0.12, 0.05), (0.28, 0.15, 0.16, 0.05), (0.0, 0.2, -0.3, 0.05)):
        t.boule((x, y, z), (r, r * 0.6, r), POIS, mode="peint", plat=True)
    visage(c, -0.14, -0.18, 0.08, 0.04, angle=28)
    joues(c, -0.2, -0.17, 0.13)
    bras2(s, PIED, PIED, x=0.2, y=-0.15, longueur=0.12, r=0.045, poing=0.06, corps=c)
    jambes2(s, PIED, FONCE, x=0.09, haut=-0.36, r=0.06, corps=c)
    return s


def roncebete():
    s = Sculpteur("Roncebete")
    RONCE, FONCE, BAIE, FEUILLE = rgb("4f7a2a"), rgb("2f4a1a"), rgb("ff3a5a"), rgb("8fd04a")
    c = s.membre("Corps")
    c.boule((0, -0.12, 0.06), (0.26, 0.2, 0.3), RONCE)
    piquants(c, (0, -0.1, 0.08), 0.22, FONCE, RONCE, n_th=9, n_ph=4, longueur=0.09, r=0.025)
    for x, y, z in ((-0.18, 0.04, 0.0), (0.2, 0.02, 0.15), (0.0, 0.1, 0.2), (-0.12, -0.02, 0.3), (0.15, 0.08, -0.05)):
        c.boule((x, y, z), (0.04, 0.04, 0.04), BAIE, fondu=0.0)
    t = s.membre("Tete", "Tete", (0, -0.06, -0.2))
    t.boule((0, -0.06, -0.27), (0.17, 0.15, 0.13), RONCE)
    t.cone((0, -0.09, -0.34), (0, -0.1, -0.42), 0.07, 0.05, RONCE, fondu=0.03)
    t.boule((0, -0.1, -0.43), (0.03, 0.025, 0.02), BAIE, fondu=0.0)
    visage(t, -0.01, -0.36, 0.07, 0.04, iris=rgb("ff6a7a"), crocs=False)
    from monstres import _crocs
    _crocs(t, -0.15, -0.41, 0.035, 0.022)
    for cc, nom in ((-1, "OreilleG"), (1, "OreilleD")):
        o = s.membre(nom, "Oreille", (cc * 0.1, 0.06, -0.25), cc)
        o.cone((cc * 0.1, 0.05, -0.25), (cc * 0.17, 0.17, -0.22), 0.04, 0.008, FEUILLE, fondu=0.0)
    q = s.membre("Queue", "Queue", (0, -0.06, 0.34))
    q.courbe([(0, -0.06, 0.33), (0.03, 0.02, 0.42), (0.0, 0.12, 0.44)], [0.04, 0.03, 0.015], FONCE)
    q.boule((0.0, 0.13, 0.44), (0.035, 0.035, 0.035), BAIE, fondu=0.0)
    pattes4(s, RONCE, FONCE, x=0.15, z_av=-0.08, z_ar=0.2, haut=-0.25, r=0.05, corps=c)
    return s


def grumtronc():
    s = Sculpteur("Grumtronc")
    ECORCE, FONCE, MOUSSE, FEUILLE = rgb("8a5a34"), rgb("5a3820"), rgb("6ab04a"), rgb("4a9a3a")
    c = s.membre("Corps")
    c.cone((0, -0.36, 0), (0, 0.12, 0), 0.22, 0.17, ECORCE, fondu=0.0)
    for x in (-0.12, 0.0, 0.12):
        c.cone((x, -0.36, -0.2), (x * 0.8, 0.1, -0.16), 0.012, 0.01, FONCE, mode="peint")
    c.boule((0.12, -0.05, 0.14), (0.1, 0.06, 0.08), MOUSSE, mode="peint")
    t = s.membre("Tete", "Tete", (0, 0.14, 0))
    for x, y, z in ((0, 0.3, 0), (-0.15, 0.24, 0.05), (0.16, 0.25, 0.03), (0.0, 0.36, 0.12), (-0.05, 0.4, -0.06)):
        t.boule((x, y, z), (0.16, 0.13, 0.16), FEUILLE)
    t.boule((0.08, 0.38, -0.1), (0.06, 0.04, 0.05), MOUSSE, mode="peint")
    visage(c, 0.02, -0.19, 0.08, 0.045, iris=rgb("ffd23a"), bouche_y=-0.12)
    for cc, nom in ((-1, "BrasG"), (1, "BrasD")):
        b = s.membre(nom, "Bras", (cc * 0.17, 0.0, 0.0), cc, 0.0 if cc < 0 else 0.5)
        b.courbe([(cc * 0.17, 0.0, 0), (cc * 0.3, -0.06, -0.02), (cc * 0.38, -0.2, -0.04), (cc * 0.4, -0.3, -0.06)],
                 [0.05, 0.04, 0.03, 0.02], ECORCE)
        for dz in (-0.03, 0.02):
            b.cone((cc * 0.4, -0.3, -0.06), (cc * 0.44, -0.36, -0.06 + dz), 0.015, 0.006, FONCE, fondu=0.0)
        b.boule((cc * 0.32, -0.05, -0.02), (0.05, 0.04, 0.04), FEUILLE, fondu=0.0)
    for cc, nom in ((-1, "PatteG"), (1, "PatteD")):
        p = s.membre(nom, "Patte", (cc * 0.12, -0.36, 0), cc, 0.0 if cc < 0 else 0.5)
        p.courbe([(cc * 0.12, -0.36, 0), (cc * 0.2, -0.43, -0.04), (cc * 0.26, -0.465, -0.08)], [0.06, 0.045, 0.03], FONCE)
    return s


# ------------------------------------------------------------------- Dunes


def momiotte():
    s = Sculpteur("Momiotte")
    BANDE, OMBRE, VERT = rgb("efe2c0"), rgb("c9b48a"), rgb("6aff7a")
    c = s.membre("Corps")
    c.boule((0, -0.2, 0), (0.2, 0.24, 0.18), BANDE)
    for i in range(6):
        y = -0.4 + i * 0.07
        c.boite((0, y, 0), (0.21, 0.008, 0.19), OMBRE, arrondi=0.008, rot=(0, 0, (-1) ** i * 8), mode="peint")
    t = s.membre("Tete", "Tete", (0, 0.04, 0))
    t.boule((0, 0.16, 0), (0.19, 0.17, 0.17), BANDE)
    for i in range(4):
        t.boite((0, 0.06 + i * 0.07, 0), (0.2, 0.008, 0.18), OMBRE, arrondi=0.008, rot=(0, 0, (-1) ** i * 12), mode="peint")
    # Un seul œil vert lumineux qui dépasse des bandelettes.
    t.boule((-0.06, 0.16, -0.16), (0.05, 0.05, 0.03), rgb("1d1626"), fondu=0.0, plat=True)
    t.boule((-0.06, 0.16, -0.18), (0.03, 0.03, 0.02), VERT, mode="peint", plat=True)
    t.boite((0.07, 0.17, -0.165), (0.06, 0.012, 0.015), OMBRE, arrondi=0.008, rot=(0, 0, -20), fondu=0.0)
    # Bandelette qui pend (rôle Queue : elle flotte).
    q = s.membre("Bandelette", "Queue", (0.1, 0.2, 0.12))
    q.courbe([(0.1, 0.2, 0.14), (0.16, 0.1, 0.22), (0.2, -0.02, 0.26)], [0.03, 0.025, 0.02], BANDE)
    bras2(s, BANDE, BANDE, x=0.2, y=-0.1, longueur=0.1, r=0.045, poing=0.05, corps=c)
    jambes2(s, BANDE, OMBRE, x=0.09, haut=-0.36, r=0.055, corps=c)
    return s


def vautourne():
    s = Sculpteur("Vautourne")
    PLUME, FONCE, PEAU, BEC = rgb("6a4a3a"), rgb("3e2a20"), rgb("ff9a8a"), rgb("f2c04a")
    c = s.membre("Corps")
    c.boule((0, -0.15, 0.06), (0.2, 0.22, 0.24), PLUME)
    c.boule((0, -0.18, -0.08), (0.13, 0.15, 0.1), rgb("8a6a50"), mode="peint")
    c.boule((0, 0.04, -0.02), (0.13, 0.06, 0.12), BLANC, fondu=0.05)  # collerette
    t = s.membre("Tete", "Tete", (0, 0.06, -0.06))
    t.cone((0, 0.06, -0.04), (0, 0.18, -0.1), 0.05, 0.045, PEAU, fondu=0.0)
    t.boule((0, 0.22, -0.12), (0.1, 0.09, 0.1), PEAU)
    t.courbe([(0, 0.22, -0.2), (0, 0.2, -0.28), (0, 0.15, -0.3)], [0.045, 0.03, 0.012], BEC)
    visage(t, 0.25, -0.19, 0.05, 0.03, crocs=False, angle=30)
    for cc, nom in ((-1, "AileG"), (1, "AileD")):
        a = s.membre(nom, "Aile", (cc * 0.18, -0.02, 0.06), cc)
        a.boule((cc * 0.32, -0.06, 0.1), (0.17, 0.08, 0.025), PLUME, rot=(0, 0, cc * -20), fondu=0.0)
        a.boule((cc * 0.42, -0.1, 0.1), (0.07, 0.06, 0.027), FONCE, mode="peint")
    q = s.membre("Queue", "Queue", (0, -0.2, 0.28))
    q.boule((0, -0.24, 0.34), (0.1, 0.03, 0.08), FONCE, rot=(30, 0, 0), fondu=0.0)
    for cc, nom in ((-1, "PatteG"), (1, "PatteD")):
        p = s.membre(nom, "Patte", (cc * 0.08, -0.34, 0.04), cc, 0.0 if cc < 0 else 0.5)
        p.cone((cc * 0.08, -0.34, 0.04), (cc * 0.08, -0.46, 0.02), 0.025, 0.022, BEC, fondu=0.0)
        for dx, dz in ((-0.03, -0.05), (0.0, -0.06), (0.03, -0.05)):
            p.cone((cc * 0.08, -0.47, 0.02), (cc * 0.08 + dx, -0.475, 0.02 + dz), 0.02, 0.012, BEC, fondu=0.01)
    return s


def golemsable():
    s = Sculpteur("Golemsable")
    GRES, FONCE, RUNE = rgb("d9a86a"), rgb("a8733e"), rgb("3ae6d2")
    c = s.membre("Corps")
    c.boite((0, -0.1, 0), (0.26, 0.22, 0.18), GRES, arrondi=0.07)
    for x, y in ((-0.12, -0.2), (0.1, 0.0), (0.16, -0.25)):
        c.boite((x, y, -0.18), (0.06, 0.004, 0.01), FONCE, arrondi=0.003, mode="peint")
    c.boule((0, -0.08, -0.18), (0.06, 0.06, 0.02), RUNE, mode="peint", plat=True)
    t = s.membre("Tete", "Tete", (0, 0.12, 0))
    t.boite((0, 0.22, -0.02), (0.13, 0.1, 0.12), GRES, arrondi=0.04)
    t.boite((0, 0.3, -0.02), (0.14, 0.02, 0.13), FONCE, arrondi=0.01, mode="peint")
    for cc in (-1, 1):
        t.boite((cc * 0.06, 0.22, -0.14), (0.03, 0.022, 0.01), RUNE, arrondi=0.01, fondu=0.0, plat=True)
    from monstres import _sourcils
    _sourcils(t, 0.265, -0.145, 0.06, 0.06, 28, FONCE)
    bras2(s, GRES, FONCE, x=0.3, y=0.04, longueur=0.24, r=0.07, poing=0.1, corps=c)
    jambes2(s, GRES, FONCE, x=0.13, haut=-0.3, r=0.08, corps=c)
    return s


# ----------------------------------------------------------------- Glacier


def bouleneige():
    s = Sculpteur("Bouleneige")
    NEIGE, OMBRE, CAROTTE, BOIS = rgb("f6fbff"), rgb("c7dcf2"), rgb("ff8a2a"), rgb("6a4a30")
    c = s.membre("Corps")
    c.boule((0, -0.17, 0), (0.3, 0.29, 0.3), NEIGE)
    c.boule((0.12, -0.32, 0.12), (0.18, 0.1, 0.16), OMBRE, mode="peint")
    for x, y, z in ((0.22, 0.0, -0.1), (-0.25, -0.1, 0.05), (0.05, 0.08, 0.2)):
        c.boule((x, y, z), (0.05, 0.04, 0.05), OMBRE, mode="peint")
    visage(c, -0.08, -0.27, 0.1, 0.05, angle=26, bouche_y=-0.24)
    c.cone((0, -0.15, -0.28), (0.0, -0.17, -0.4), 0.035, 0.008, CAROTTE, fondu=0.0)
    joues(c, -0.18, -0.26, 0.16)
    for cc, nom in ((-1, "BrasG"), (1, "BrasD")):
        b = s.membre(nom, "Bras", (cc * 0.27, -0.08, 0), cc, 0.0 if cc < 0 else 0.5)
        b.courbe([(cc * 0.27, -0.08, 0), (cc * 0.38, 0.0, -0.02), (cc * 0.44, 0.08, -0.03)], [0.018, 0.014, 0.01], BOIS)
        b.cone((cc * 0.4, 0.03, -0.02), (cc * 0.43, -0.02, -0.04), 0.01, 0.005, BOIS, fondu=0.0)
    return s


def grognours():
    s = Sculpteur("Grognours")
    BLANC_OURS, OMBRE, NEZ = rgb("eef6ff"), rgb("bcd2ea"), rgb("1d1626")
    c = s.membre("Corps")
    c.boule((0, -0.13, 0.08), (0.24, 0.22, 0.3), BLANC_OURS)
    c.boule((0, -0.25, 0.05), (0.16, 0.08, 0.22), OMBRE, mode="peint")
    t = s.membre("Tete", "Tete", (0, -0.02, -0.2))
    t.boule((0, 0.0, -0.28), (0.17, 0.15, 0.15), BLANC_OURS)
    t.boule((0, -0.06, -0.39), (0.08, 0.06, 0.06), BLANC_OURS, fondu=0.03)
    t.boule((0, -0.03, -0.45), (0.035, 0.025, 0.02), NEZ, fondu=0.0)
    visage(t, 0.04, -0.4, 0.07, 0.035, crocs=False)
    from monstres import _crocs
    _crocs(t, -0.1, -0.44, 0.03, 0.02)
    for cc, nom in ((-1, "OreilleG"), (1, "OreilleD")):
        o = s.membre(nom, "Oreille", (cc * 0.12, 0.12, -0.25), cc)
        o.boule((cc * 0.12, 0.13, -0.24), (0.05, 0.05, 0.03), BLANC_OURS, fondu=0.0)
        o.boule((cc * 0.12, 0.13, -0.26), (0.025, 0.025, 0.015), OMBRE, mode="peint")
    q = s.membre("Queue", "Queue", (0, -0.05, 0.37))
    q.boule((0, -0.04, 0.39), (0.05, 0.05, 0.04), BLANC_OURS, fondu=0.0)
    pattes4(s, BLANC_OURS, OMBRE, x=0.15, z_av=-0.08, z_ar=0.24, haut=-0.24, r=0.07, corps=c)
    return s


def abominou():
    s = Sculpteur("Abominou")
    POIL, OMBRE, VISAGE, GLACE = rgb("f2f8ff"), rgb("bcd4ee"), rgb("8ab4e6"), rgb("7ae6ff")
    c = s.membre("Corps")
    c.boule((0, -0.1, 0.02), (0.26, 0.28, 0.22), POIL)
    c.boule((0, -0.14, -0.14), (0.16, 0.18, 0.08), OMBRE, mode="peint")
    t = s.membre("Tete", "Tete", (0, 0.14, -0.02))
    t.boule((0, 0.26, -0.04), (0.17, 0.15, 0.15), POIL)
    t.boule((0, 0.23, -0.15), (0.11, 0.09, 0.05), VISAGE, fondu=0.02)
    visage(t, 0.27, -0.19, 0.055, 0.035, angle=30, bouche_y=0.18)
    for cc in (-1, 1):
        t.cone((cc * 0.1, 0.36, -0.02), (cc * 0.13, 0.46, 0.0), 0.03, 0.008, GLACE, fondu=0.0)
    for cc, nom in ((-1, "BrasG"), (1, "BrasD")):
        c.boule((cc * 0.24, 0.06, 0), (0.09, 0.08, 0.09), POIL, fondu=0.06)
        b = s.membre(nom, "Bras", (cc * 0.27, 0.06, 0), cc, 0.0 if cc < 0 else 0.5)
        b.cone((cc * 0.28, 0.06, 0), (cc * 0.34, -0.18, -0.02), 0.075, 0.07, POIL, fondu=0.0)
        b.boule((cc * 0.35, -0.26, -0.03), (0.1, 0.09, 0.1), GLACE, fondu=0.03)  # poing de glace
        b.boule((cc * 0.33, -0.22, -0.11), (0.04, 0.03, 0.01), BLANC, mode="peint", plat=True)
    jambes2(s, POIL, VISAGE, x=0.12, haut=-0.32, r=0.08, corps=c)
    return s


# ------------------------------------------------------------------ Volcan


def magmouille():
    s = Sculpteur("Magmouille")
    LAVE, ROCHE, BRAISE, CLAIRE = rgb("ff6a1a"), rgb("4a3a3a"), rgb("ffd23a"), rgb("6a5a5a")
    c = s.membre("Corps")
    c.boule((0, -0.3, 0), (0.42, 0.16, 0.4), LAVE)
    c.boule((0, -0.18, 0.03), (0.3, 0.1, 0.28), LAVE, fondu=0.08)
    c.boite((0.02, -0.1, 0.08), (0.24, 0.035, 0.2), ROCHE, arrondi=0.03, rot=(0, 15, 4))
    c.boite((0.16, -0.07, 0.2), (0.1, 0.025, 0.08), CLAIRE, arrondi=0.02, rot=(0, -10, 0))
    for x, z in ((-0.36, -0.2), (0.38, 0.1), (-0.2, 0.3)):
        c.boule((x, -0.38, z), (0.05, 0.04, 0.05), BRAISE, fondu=0.02)
    visage(c, -0.2, -0.33, 0.12, 0.05, iris=BRAISE, bouche_y=-0.32)
    b = s.membre("Bulle", "Antenne", (-0.18, -0.1, -0.1))
    b.boule((-0.18, -0.05, -0.12), (0.06, 0.06, 0.06), BRAISE, fondu=0.0)
    return s


def cendrecroc():
    s = Sculpteur("Cendrecroc")
    CENDRE, FONCE, LAVE, BRAISE = rgb("4a4048"), rgb("2a2228"), rgb("ff5a1a"), rgb("ffd23a")
    c = s.membre("Corps")
    c.boule((0, -0.13, 0.06), (0.2, 0.19, 0.29), CENDRE)
    for z in (-0.05, 0.08, 0.2):
        c.boite((0, -0.0, z), (0.19, 0.008, 0.012), LAVE, arrondi=0.006, mode="peint", plat=True)
    t = s.membre("Tete", "Tete", (0, -0.02, -0.2))
    t.boule((0, 0.0, -0.27), (0.16, 0.14, 0.13), CENDRE)
    t.cone((0, -0.04, -0.33), (0, -0.06, -0.43), 0.08, 0.06, CENDRE, fondu=0.03)
    t.boule((0, -0.03, -0.45), (0.03, 0.025, 0.02), FONCE, fondu=0.0)
    visage(t, 0.04, -0.37, 0.07, 0.035, iris=BRAISE, crocs=False)
    from monstres import _crocs
    _crocs(t, -0.1, -0.44, 0.04, 0.03, couleur=BRAISE)
    for cc, nom in ((-1, "OreilleG"), (1, "OreilleD")):
        o = s.membre(nom, "Oreille", (cc * 0.1, 0.1, -0.24), cc)
        o.cone((cc * 0.1, 0.09, -0.24), (cc * 0.15, 0.22, -0.22), 0.045, 0.008, CENDRE, fondu=0.0)
        o.cone((cc * 0.1, 0.11, -0.25), (cc * 0.14, 0.19, -0.23), 0.02, 0.006, LAVE, mode="peint")
    q = s.membre("Queue", "Flamme", (0, -0.04, 0.33))
    q.courbe([(0, -0.04, 0.33), (0.0, 0.05, 0.42), (0.02, 0.15, 0.44)], [0.04, 0.035, 0.02], CENDRE)
    q.cone((0.02, 0.15, 0.44), (0.03, 0.27, 0.45), 0.05, 0.008, LAVE, fondu=0.0)
    pattes4(s, CENDRE, FONCE, x=0.13, z_av=-0.06, z_ar=0.22, haut=-0.24, r=0.05, corps=c)
    return s


def titanflamme():
    s = Sculpteur("Titanflamme")
    ROCHE, FONCE, LAVE, BRAISE = rgb("5a4040"), rgb("332428"), rgb("ff5a1a"), rgb("ffd23a")
    c = s.membre("Corps")
    c.boule((0, -0.08, 0.02), (0.27, 0.27, 0.21), ROCHE)
    c.boule((0, -0.1, -0.16), (0.13, 0.15, 0.06), LAVE, mode="peint")
    for x, y in ((-0.16, 0.05), (0.15, -0.18), (0.05, 0.12)):
        c.boite((x, y, -0.19), (0.05, 0.006, 0.01), BRAISE, arrondi=0.004, rot=(0, 0, 30), mode="peint", plat=True)
    t = s.membre("Tete", "Tete", (0, 0.16, -0.02))
    t.boule((0, 0.26, -0.04), (0.14, 0.12, 0.13), ROCHE)
    visage(t, 0.27, -0.16, 0.055, 0.035, iris=BRAISE, bouche_y=0.19)
    for x, h in ((-0.07, 0.12), (0.0, 0.16), (0.07, 0.12)):
        t.cone((x, 0.34, -0.02), (x * 1.3, 0.34 + h, 0.0), 0.04, 0.006, LAVE, fondu=0.0)
    for cc, nom in ((-1, "BrasG"), (1, "BrasD")):
        c.boule((cc * 0.25, 0.08, 0), (0.1, 0.09, 0.1), ROCHE, fondu=0.06)
        b = s.membre(nom, "Bras", (cc * 0.28, 0.08, 0), cc, 0.0 if cc < 0 else 0.5)
        b.cone((cc * 0.29, 0.08, 0), (cc * 0.35, -0.16, -0.02), 0.075, 0.07, ROCHE, fondu=0.0)
        b.boule((cc * 0.36, -0.25, -0.03), (0.11, 0.1, 0.11), LAVE, fondu=0.03)  # poing de magma
        b.boule((cc * 0.36, -0.22, -0.12), (0.05, 0.04, 0.01), BRAISE, mode="peint", plat=True)
    jambes2(s, ROCHE, FONCE, x=0.13, haut=-0.3, r=0.085, corps=c)
    return s


MONSTRES = {
    "Champignard": champignard,
    "Roncebete": roncebete,
    "Grumtronc": grumtronc,
    "Momiotte": momiotte,
    "Vautourne": vautourne,
    "Golemsable": golemsable,
    "Bouleneige": bouleneige,
    "Grognours": grognours,
    "Abominou": abominou,
    "Magmouille": magmouille,
    "Cendrecroc": cendrecroc,
    "Titanflamme": titanflamme,
}
