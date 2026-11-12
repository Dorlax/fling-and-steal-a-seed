"""Aides communes aux monstres des biomes (visage grognon, membres).

Repère : boîte unité [-0.5, 0.5], avant vers -Z, pieds vers y = -0.47.
Rôles d'animation : Patte, Bras, Tete, Queue, Oreille, Aile, Machoire,
Antenne, Flamme, Pendule, Bascule.
"""

import math

from monstres import _crocs, _sourcils
from sculpteur import BLANC, rgb

ROSE_JOUE = rgb("ff9fb4")
BOUCHE = rgb("2a1030")


def visage(t, y, z, ecart, r=0.045, iris=None, sourcil=True, angle=24, crocs=True, bouche_y=None):
    """Deux yeux brillants, sourcils froncés et petits crocs."""
    t.oeil((-ecart, y, z), r, iris=iris)
    t.oeil((ecart, y, z), r, iris=iris)
    if sourcil:
        _sourcils(t, y + r * 1.45, z - 0.005, ecart, r * 1.5, angle)
    if crocs:
        by = bouche_y if bouche_y is not None else y - r * 2.6
        t.boule((0, by, z + 0.01), (ecart * 0.9, r * 0.45, 0.02), BOUCHE, fondu=0.0, plat=True)
        _crocs(t, by - r * 0.2, z - 0.005, ecart * 0.45, r * 0.5)


def joues(t, y, z, ecart, r=0.04):
    for c in (-1, 1):
        t.boule((c * ecart, y, z), (r, r * 0.65, r * 0.5), ROSE_JOUE, mode="peint")


def jambes2(s, couleur, pied, x=0.12, haut=-0.28, r=0.07, z=0.02, corps=None):
    """Deux jambes de bipède trapu, gros pieds."""
    for cc, nom in ((-1, "PatteG"), (1, "PatteD")):
        if corps is not None:
            corps.boule((cc * x, haut + 0.04, z), (r * 1.3, r * 1.3, r * 1.3), couleur, fondu=0.06)
        p = s.membre(nom, "Patte", (cc * x, haut, z), cc, 0.0 if cc < 0 else 0.5)
        p.cone((cc * x, haut + 0.02, z), (cc * x, -0.43, z), r, r * 0.9, couleur, fondu=0.0)
        p.boule((cc * x, -0.455, z - 0.03), (r * 1.15, r * 0.55, r * 1.45), pied, fondu=0.03)


def bras2(s, couleur, main, x=0.24, y=0.0, z=0.0, longueur=0.2, r=0.055, poing=0.075, corps=None):
    """Deux bras pendants avec un poing (rôle Bras)."""
    for cc, nom in ((-1, "BrasG"), (1, "BrasD")):
        if corps is not None:
            corps.boule((cc * (x - 0.02), y, z), (r * 1.4, r * 1.3, r * 1.3), couleur, fondu=0.06)
        b = s.membre(nom, "Bras", (cc * x, y, z), cc, 0.0 if cc < 0 else 0.5)
        b.cone((cc * x, y, z), (cc * (x + 0.05), y - longueur, z - 0.02), r, r * 0.85, couleur, fondu=0.0)
        b.boule((cc * (x + 0.055), y - longueur - poing * 0.6, z - 0.03), (poing, poing * 0.9, poing), main, fondu=0.03)


def pattes4(s, couleur, pied, x=0.13, z_av=-0.1, z_ar=0.16, haut=-0.24, r=0.055, corps=None):
    for cote, nx in ((-1, "G"), (1, "D")):
        for zz, nz, ph in ((z_av, "Av", 0.0), (z_ar, "Ar", 0.5)):
            px = cote * x
            if corps is not None:
                corps.boule((px * 0.85, haut + 0.03, zz), (r * 1.3, r * 1.5, r * 1.4), couleur, fondu=0.07)
            m = s.membre(f"Patte{nz}{nx}", "Patte", (px, haut, zz), cote, ph if cote < 0 else 0.5 - ph)
            m.cone((px, haut + 0.02, zz), (px, -0.43, zz), r, r * 0.88, couleur, fondu=0.0)
            m.boule((px, -0.45, zz - r * 0.2), (r * 1.05, r * 0.5, r * 1.2), pied, fondu=0.04)


def piquants(m, centre, rayon, couleur, couleur2=None, n_th=7, n_ph=5, longueur=0.12, eviter_face=True, r=0.04):
    """Piquants coniques sur une sphère (oursin, bogue, cactus)."""
    cx, cy, cz = centre
    for a in range(n_th):
        th = a / n_th * 2 * math.pi
        for b in range(n_ph):
            ph = (b + 0.5) / n_ph * math.pi
            n = (math.sin(ph) * math.cos(th), math.cos(ph), math.sin(ph) * math.sin(th))
            if eviter_face and n[2] < -0.55 and abs(n[1]) < 0.6:
                continue
            base = (cx + rayon * n[0], cy + rayon * n[1], cz + rayon * n[2])
            pointe = (cx + (rayon + longueur) * n[0], cy + (rayon + longueur) * n[1], cz + (rayon + longueur) * n[2])
            coul = couleur2 if couleur2 and (a + b) % 2 else couleur
            m.cone(base, pointe, r, 0.006, coul, fondu=0.0)


def tentacule(s, nom, base, points, rayons, couleur, cote=0, phase=0.0, bout=None):
    q = s.membre(nom, "Queue", base, cote, phase)
    q.courbe(points, rayons, couleur)
    if bout:
        q.boule(points[-1], (rayons[-1] * 1.8,) * 3, bout, fondu=0.0)
    return q


__all__ = ["visage", "joues", "jambes2", "bras2", "pattes4", "piquants", "tentacule", "BLANC", "rgb"]
