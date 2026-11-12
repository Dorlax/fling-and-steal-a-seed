"""Monstres en voxels : Galaxie, Marais, Récif, Bonbon."""

import math

from monstres import _crocs, _sourcils
from monstres_aide import BLANC, bras2, jambes2, joues, piquants, rgb, tentacule, visage
from sculpteur import Sculpteur

# ----------------------------------------------------------------- Galaxie


def asteroidon():
    s = Sculpteur("Asteroidon")
    ROC, FONCE, CRATERE, FEU = rgb("7a6a8a"), rgb("4a3e5a"), rgb("5a4e6a"), rgb("ff8a3a")
    c = s.membre("Corps")
    c.boule((0, -0.12, 0), (0.3, 0.27, 0.28), ROC)
    for x, y, z in ((0.18, 0.06, 0.12), (-0.2, 0.0, 0.1), (0.1, -0.3, 0.2), (-0.12, 0.1, -0.15)):
        c.boule((x, y, z), (0.07, 0.06, 0.04), CRATERE, mode="creux")
    c.boule((0.2, 0.08, -0.12), (0.06, 0.05, 0.05), FONCE, fondu=0.02)
    visage(c, -0.06, -0.26, 0.1, 0.05, iris=rgb("ffd23a"), bouche_y=-0.22)
    # Traînée de feu derrière (il fonce).
    q = s.membre("Trainee", "Flamme", (0, -0.12, 0.26))
    q.cone((0, -0.1, 0.26), (0.0, -0.05, 0.47), 0.17, 0.02, FEU, fondu=0.0)
    q.cone((0, -0.1, 0.3), (0.0, -0.06, 0.42), 0.09, 0.01, rgb("ffe06a"), mode="peint")
    return s


def zorglouf():
    s = Sculpteur("Zorglouf")
    PEAU, ARMURE, VERRE, OEIL = rgb("7ad04a"), rgb("8a96b8"), rgb("bfefff"), rgb("ff3a8a")
    c = s.membre("Corps")
    c.boule((0, -0.16, 0), (0.18, 0.2, 0.15), ARMURE)
    c.boite((0, -0.14, -0.14), (0.08, 0.06, 0.02), rgb("3ae6d2"), arrondi=0.02, mode="peint", plat=True)
    t = s.membre("Tete", "Tete", (0, 0.04, 0))
    t.boule((0, 0.17, 0), (0.16, 0.15, 0.15), PEAU)
    t.boule((0, 0.2, 0), (0.21, 0.21, 0.2), VERRE, mode="ajout", fondu=0.0)
    t.boule((0, 0.17, 0), (0.16, 0.15, 0.15), PEAU, mode="peint")
    for x in (-0.08, 0.0, 0.08):
        t.oeil((x, 0.2, -0.205), 0.035, iris=OEIL)
    _sourcils(t, 0.25, -0.21, 0.07, 0.05, 20)
    t.cone((0, 0.38, 0), (0, 0.48, 0), 0.012, 0.008, ARMURE, fondu=0.0)
    t.boule((0, 0.49, 0), (0.025, 0.025, 0.025), OEIL, fondu=0.0)
    bras2(s, PEAU, ARMURE, x=0.2, y=-0.06, longueur=0.14, r=0.04, poing=0.055, corps=c)
    jambes2(s, ARMURE, rgb("4a5470"), x=0.09, haut=-0.33, r=0.055, corps=c)
    return s


def krakosmos():
    s = Sculpteur("Krakosmos")
    NUIT, CLAIR, LUEUR, ETOILE = rgb("3a2a8a"), rgb("6a5ac8"), rgb("ff6ad8"), rgb("fff6a0")
    c = s.membre("Corps")
    c.boule((0, 0.1, 0.02), (0.24, 0.27, 0.23), NUIT)
    for x, y, z in ((-0.12, 0.25, -0.12), (0.15, 0.18, -0.14), (0.05, 0.32, 0.1), (-0.18, 0.05, 0.12), (0.2, 0.0, 0.08)):
        c.boule((x, y, z), (0.015, 0.015, 0.015), ETOILE, mode="peint", plat=True)
    visage(c, 0.02, -0.2, 0.09, 0.05, iris=LUEUR, bouche_y=-0.1)
    for i in range(6):
        a = i / 6 * 2 * math.pi + 0.3
        dx, dz = math.cos(a), math.sin(a)
        pts = [(dx * 0.15, -0.12, dz * 0.15), (dx * 0.26, -0.3, dz * 0.26), (dx * 0.35, -0.42, dz * 0.33),
               (dx * 0.43, -0.4, dz * 0.4)]
        tentacule(s, f"Tentacule{i + 1}", pts[0], pts, [0.06, 0.045, 0.03, 0.02], CLAIR, cote=1 if dx > 0 else -1,
                  phase=i / 6, bout=LUEUR)
    return s


# ------------------------------------------------------------------ Marais


def vasepouf():
    s = Sculpteur("Vasepouf")
    VASE, FONCE, BULLE, ALGUE = rgb("6a7a3a"), rgb("4a5228"), rgb("c8e07a"), rgb("4aa03a")
    c = s.membre("Corps")
    c.boule((0, -0.28, 0), (0.36, 0.2, 0.34), VASE)
    c.boule((0, -0.12, 0.02), (0.22, 0.16, 0.2), VASE, fondu=0.1)
    c.boule((0.1, -0.42, 0.1), (0.25, 0.05, 0.2), FONCE, mode="peint")
    for x, z in ((-0.15, 0.15), (0.18, 0.05)):
        c.cone((x, -0.1, z), (x * 1.2, 0.02, z), 0.02, 0.008, ALGUE, fondu=0.0)
    visage(c, -0.12, -0.24, 0.09, 0.045, iris=rgb("ffe06a"), bouche_y=-0.26)
    for i, (x, y, z, r) in enumerate(((-0.15, 0.08, 0.0, 0.05), (0.12, 0.1, 0.1, 0.035))):
        b = s.membre(f"Bulle{i + 1}", "Antenne", (x, y - 0.05, z))
        b.boule((x, y, z), (r, r, r), BULLE, fondu=0.0)
        b.boule((x - r * 0.3, y + r * 0.3, z - r * 0.5), (r * 0.25,) * 3, BLANC, mode="peint", plat=True)
    return s


def moustiroc():
    s = Sculpteur("Moustiroc")
    CORPS, RAYURE, AILE, DARD = rgb("5a4a3a"), rgb("d8b04a"), rgb("d8f2ff"), rgb("2a2228")
    c = s.membre("Corps")
    c.boule((0, -0.02, 0.12), (0.12, 0.11, 0.2), CORPS)
    for z in (0.05, 0.13, 0.21):
        c.boite((0, -0.02, z), (0.125, 0.115, 0.012), RAYURE, arrondi=0.1, mode="peint")
    t = s.membre("Tete", "Tete", (0, 0.02, -0.08))
    t.boule((0, 0.04, -0.14), (0.11, 0.1, 0.1), CORPS)
    t.oeil((-0.06, 0.08, -0.22), 0.045, iris=rgb("ff3a3a"))
    t.oeil((0.06, 0.08, -0.22), 0.045, iris=rgb("ff3a3a"))
    _sourcils(t, 0.14, -0.235, 0.06, 0.06, 28)
    t.cone((0, 0.0, -0.22), (0, -0.04, -0.45), 0.018, 0.003, DARD, fondu=0.0)
    for cc, nom in ((-1, "AileG"), (1, "AileD")):
        a = s.membre(nom, "Aile", (cc * 0.06, 0.08, 0.02), cc)
        a.boule((cc * 0.22, 0.18, 0.06), (0.17, 0.07, 0.015), AILE, rot=(0, 0, cc * -25), fondu=0.0)
    for i, z in enumerate((-0.04, 0.06, 0.16)):
        for cc, cote in ((-1, "G"), (1, "D")):
            p = s.membre(f"Patte{i + 1}{cote}", "Patte", (cc * 0.08, -0.08, z), cc, (i / 3) if cc < 0 else 0.5 - i / 3)
            p.courbe([(cc * 0.08, -0.08, z), (cc * 0.2, -0.2, z), (cc * 0.24, -0.46, z)], [0.018, 0.014, 0.01], DARD)
    return s


def croquemarais():
    s = Sculpteur("Croquemarais")
    PEAU, FONCE, ALGUE, NENU = rgb("3a7a5a"), rgb("23503a"), rgb("6ab04a"), rgb("ff8ac8")
    c = s.membre("Corps")
    c.boule((0, -0.12, 0.02), (0.27, 0.28, 0.22), PEAU)
    c.boule((0, -0.16, -0.15), (0.16, 0.18, 0.08), rgb("8ac8a0"), mode="peint")
    for x, y in ((-0.2, 0.05), (0.18, -0.1), (-0.05, 0.2)):
        c.cone((x, y, -0.05), (x * 1.1, y - 0.2, -0.12), 0.03, 0.012, ALGUE, fondu=0.02)
    t = s.membre("Tete", "Tete", (0, 0.14, -0.02))
    t.boule((0, 0.25, -0.04), (0.16, 0.13, 0.15), PEAU)
    visage(t, 0.28, -0.17, 0.06, 0.04, iris=rgb("ffe06a"), bouche_y=0.19)
    t.boule((0.06, 0.38, 0.0), (0.1, 0.012, 0.1), ALGUE, fondu=0.0)  # nénuphar sur la tête
    t.boule((0.08, 0.41, 0.0), (0.035, 0.03, 0.035), NENU, fondu=0.0)
    bras2(s, PEAU, FONCE, x=0.28, y=0.04, longueur=0.24, r=0.065, poing=0.085, corps=c)
    jambes2(s, PEAU, FONCE, x=0.13, haut=-0.32, r=0.08, corps=c)
    return s


# ------------------------------------------------------------------- Récif


def oursinou():
    s = Sculpteur("Oursinou")
    CORPS, PIQUE, PIQUE2 = rgb("6a3a9a"), rgb("2a1a4a"), rgb("a06ad8")
    c = s.membre("Corps")
    c.boule((0, -0.2, 0), (0.24, 0.23, 0.24), CORPS)
    piquants(c, (0, -0.2, 0), 0.2, PIQUE, PIQUE2, n_th=10, n_ph=6, longueur=0.15, r=0.03)
    visage(c, -0.16, -0.235, 0.08, 0.045, iris=rgb("ffe06a"), bouche_y=-0.3)
    joues(c, -0.27, -0.22, 0.13)
    return s


def murenoire():
    s = Sculpteur("Murenoire")
    PEAU, TACHE, VENTRE = rgb("2a3a4a"), rgb("e6d24a"), rgb("6a7a8a")
    c = s.membre("Corps")
    c.courbe([(0, -0.38, 0.32), (0.08, -0.3, 0.14), (-0.05, -0.14, 0.02), (0.0, 0.02, -0.08)],
             [0.1, 0.12, 0.12, 0.12], PEAU)
    for x, y, z in ((0.07, -0.3, 0.15), (-0.08, -0.17, 0.03), (0.06, -0.05, -0.05), (-0.03, -0.35, 0.28)):
        c.boule((x, y, z), (0.025, 0.025, 0.025), TACHE, mode="peint")
    t = s.membre("Tete", "Tete", (0, 0.02, -0.1))
    t.boule((0, 0.08, -0.16), (0.14, 0.13, 0.16), PEAU)
    t.boule((0, 0.02, -0.26), (0.08, 0.04, 0.06), VENTRE, fondu=0.03)
    visage(t, 0.13, -0.27, 0.06, 0.035, iris=TACHE, crocs=False)
    _crocs(t, 0.04, -0.3, 0.035, 0.022)
    m = s.membre("Machoire", "Machoire", (0, 0.0, -0.18))
    m.boule((0, -0.02, -0.25), (0.08, 0.03, 0.08), PEAU, fondu=0.0)
    _crocs(m, 0.0, -0.31, 0.035, 0.02, vers_haut=True)
    q = s.membre("Queue", "Queue", (0, -0.4, 0.34))
    q.boule((0, -0.4, 0.4), (0.02, 0.07, 0.07), TACHE, fondu=0.0)
    return s


def gueulabysse():
    s = Sculpteur("Gueulabysse")
    PEAU, FONCE, LUEUR, DENT = rgb("2a2a4a"), rgb("15152a"), rgb("6affe6"), rgb("f6f2e0")
    c = s.membre("Corps")
    c.boule((0, -0.1, 0.06), (0.25, 0.24, 0.27), PEAU)
    c.boule((0, -0.15, -0.16), (0.2, 0.12, 0.1), FONCE, mode="creux")  # gueule immense
    for i in range(7):
        x = -0.15 + i * 0.05
        c.cone((x, -0.06, -0.2), (x, -0.13, -0.22), 0.018, 0.003, DENT, fondu=0.0)
        c.cone((x + 0.025, -0.24, -0.2), (x + 0.025, -0.17, -0.22), 0.016, 0.003, DENT, fondu=0.0)
    visage(c, 0.06, -0.23, 0.09, 0.04, iris=LUEUR, crocs=False)
    a = s.membre("Lanterne", "Antenne", (0, 0.13, -0.05))
    a.courbe([(0, 0.13, -0.05), (0, 0.27, -0.12), (0, 0.27, -0.26)], [0.015, 0.012, 0.01], PEAU)
    a.boule((0, 0.25, -0.28), (0.045, 0.045, 0.045), LUEUR, fondu=0.0)
    for cc, nom in ((-1, "NageoireG"), (1, "NageoireD")):
        n = s.membre(nom, "Aile", (cc * 0.22, -0.1, 0.08), cc)
        n.boule((cc * 0.3, -0.14, 0.12), (0.09, 0.06, 0.02), FONCE, rot=(0, cc * 30, cc * -20), fondu=0.0)
    q = s.membre("Queue", "Queue", (0, -0.1, 0.32))
    q.cone((0, -0.1, 0.3), (0, -0.1, 0.4), 0.08, 0.03, PEAU, fondu=0.0)
    q.boule((0, -0.1, 0.44), (0.015, 0.11, 0.06), FONCE, fondu=0.0)
    return s


# ------------------------------------------------------------------ Bonbon


def gelatinou():
    s = Sculpteur("Gelatinou")
    GELEE, CLAIR, FONCE = rgb("ff5aa0"), rgb("ffc0dc"), rgb("c02a6a")
    c = s.membre("Corps")
    c.cone((0, -0.44, 0), (0, -0.02, 0), 0.32, 0.24, GELEE, fondu=0.0)
    c.boule((0, 0.0, 0), (0.24, 0.06, 0.24), GELEE, fondu=0.04)
    for i in range(10):
        a = i / 10 * 2 * math.pi
        c.boite((math.cos(a) * 0.29, -0.22, math.sin(a) * 0.29), (0.012, 0.2, 0.012), FONCE, arrondi=0.01,
                rot=(0, -math.degrees(a), 0), mode="peint")
    c.boule((-0.14, -0.08, -0.2), (0.05, 0.08, 0.03), CLAIR, mode="peint")
    visage(c, -0.18, -0.29, 0.1, 0.05, bouche_y=-0.32)
    b = s.membre("Cerise", "Antenne", (0, 0.06, 0))
    b.cone((0, 0.05, 0), (0.04, 0.18, 0.0), 0.008, 0.006, rgb("4a9a3a"), fondu=0.0)
    b.boule((0, 0.1, 0), (0.06, 0.06, 0.06), rgb("e6203a"), fondu=0.0)
    return s


def croquebiscuit():
    s = Sculpteur("Croquebiscuit")
    PAIN, GLACAGE, BOUTON = rgb("c07a3a"), rgb("ffffff"), rgb("ff3a5a")
    c = s.membre("Corps")
    c.boite((0, -0.18, 0), (0.17, 0.17, 0.06), PAIN, arrondi=0.06)
    for y, coul in ((-0.08, BOUTON), (-0.18, rgb("3ad06a")), (-0.28, rgb("3a8aff"))):
        c.boule((0, y, -0.06), (0.025, 0.025, 0.015), coul, fondu=0.0)
    t = s.membre("Tete", "Tete", (0, 0.0, 0))
    t.boule((0, 0.13, 0), (0.15, 0.14, 0.065), PAIN)
    t.courbe([(-0.12, 0.2, -0.05), (0.0, 0.26, -0.06), (0.12, 0.2, -0.05)], [0.012, 0.012, 0.012], GLACAGE, fondu=0.0)
    visage(t, 0.13, -0.065, 0.055, 0.035, angle=32, bouche_y=0.06)
    for cc, nom in ((-1, "BrasG"), (1, "BrasD")):
        b = s.membre(nom, "Bras", (cc * 0.15, -0.08, 0), cc, 0.0 if cc < 0 else 0.5)
        b.cone((cc * 0.15, -0.08, 0), (cc * 0.32, -0.04, 0), 0.06, 0.05, PAIN, fondu=0.0)
        b.courbe([(cc * 0.27, -0.06, -0.05), (cc * 0.28, -0.02, -0.055)], [0.008, 0.008], GLACAGE, fondu=0.0)
    for cc, nom in ((-1, "PatteG"), (1, "PatteD")):
        p = s.membre(nom, "Patte", (cc * 0.08, -0.32, 0), cc, 0.0 if cc < 0 else 0.5)
        p.cone((cc * 0.08, -0.3, 0), (cc * 0.12, -0.44, 0), 0.07, 0.06, PAIN, fondu=0.0)
        p.courbe([(cc * 0.09, -0.4, -0.055), (cc * 0.14, -0.4, -0.055)], [0.008, 0.008], GLACAGE, fondu=0.0)
    return s


def gateaugeant():
    s = Sculpteur("Gateaugeant")
    GENOISE, CREME, ROSE, FRAISE = rgb("f2c27a"), rgb("fff6ec"), rgb("ff9ac8"), rgb("e6203a")
    c = s.membre("Corps")
    c.cylindre((0, -0.27, 0), 0.38, 0.19, GENOISE, arrondi=0.04, fondu=0.0)
    c.cylindre((0, -0.26, 0), 0.39, 0.025, ROSE, arrondi=0.01, mode="peint")
    c.cylindre((0, -0.06, 0), 0.36, 0.035, CREME, arrondi=0.03, fondu=0.0)
    for i in range(12):
        a = i / 12 * 2 * math.pi
        c.boule((math.cos(a) * 0.37, -0.1, math.sin(a) * 0.37), (0.04, 0.06, 0.04), CREME, fondu=0.0)
    c.boule((0, -0.24, -0.33), (0.2, 0.06, 0.06), rgb("4a1a2a"), mode="creux")  # gueule pleine de crème
    c.boule((0, -0.26, -0.33), (0.17, 0.035, 0.05), CREME, fondu=0.0)
    _crocs(c, -0.19, -0.38, 0.1, 0.03)
    visage(c, -0.12, -0.38, 0.13, 0.045, crocs=False, angle=28)
    for i, (x, z) in enumerate(((-0.15, 0.0), (0.0, 0.12), (0.15, -0.05))):
        b = s.membre(f"Bougie{i + 1}", "Flamme", (x, 0.0, z))
        b.cone((x, -0.02, z), (x, 0.13, z), 0.02, 0.02, rgb("8ad0ff") if i % 2 else ROSE, fondu=0.0)
        b.cone((x, 0.14, z), (x, 0.21, z), 0.022, 0.004, rgb("ffd23a"), fondu=0.0)
    c.boule((0.22, 0.0, 0.18), (0.05, 0.05, 0.05), FRAISE, fondu=0.0)
    return s


MONSTRES = {
    "Asteroidon": asteroidon,
    "Zorglouf": zorglouf,
    "Krakosmos": krakosmos,
    "Vasepouf": vasepouf,
    "Moustiroc": moustiroc,
    "Croquemarais": croquemarais,
    "Oursinou": oursinou,
    "Murenoire": murenoire,
    "Gueulabysse": gueulabysse,
    "Gelatinou": gelatinou,
    "Croquebiscuit": croquebiscuit,
    "Gateaugeant": gateaugeant,
}
