"""Créatures de la Prairie Pétillante, sculptées en voxels fins.

Style : bouille ronde, grosse tête, grands yeux brillants, petites pattes.
Chaque créature est née d'une graine : une petite pousse ou une marque de
graine rappelle son origine, sans en faire une plante.
"""

from sculpteur import BLANC, Sculpteur, rgb

CREME = rgb("fff1d6")
ROSE_JOUE = rgb("ff9fb4")


def _pattes4(s, couleur, chaussette, x=0.12, z_av=-0.08, z_ar=0.16, haut=-0.22, r=0.055, pied=-0.47,
             corps=None, sabot=False, coussinet=None, bande=0.35):
    """Quatre pattes droites. La cuisse (ou l'épaule) est fondue dans le corps
    pour éviter les bosses ; la patte est un fût effilé qui finit par un pied
    discret (ou un sabot net si sabot=True)."""
    for cote, nx in ((-1, "G"), (1, "D")):
        for zz, nz, ph in ((z_av, "Av", 0.0), (z_ar, "Ar", 0.5)):
            px = cote * x
            if corps is not None:
                corps.boule((px * 0.85, haut + 0.03, zz), (r * 1.3, r * 1.6, r * 1.4), couleur, fondu=0.07)
            m = s.membre(f"Patte{nz}{nx}", "Patte", (px, haut, zz), cote, ph if cote < 0 else 0.5 - ph)
            m.cone((px, haut + 0.02, zz), (px, pied + r * 0.8, zz), r, r * 0.88, couleur, fondu=0.0)
            if sabot:
                m.cone((px, pied + r * 0.9, zz), (px, pied + r * 0.35, zz - r * 0.1), r * 0.9, r * 0.95, chaussette, fondu=0.015)
            else:
                if coussinet:  # pied rond plus marqué (forme d'origine du cerf)
                    m.boule((px, pied + r * 0.6, zz - r * 0.3), (r * coussinet[0], r * coussinet[1], r * coussinet[2]), chaussette, fondu=0.025)
                else:
                    m.boule((px, pied + r * 0.5, zz - r * 0.2), (r * 1.0, r * 0.5, r * 1.15), chaussette, fondu=0.04)
            if chaussette != couleur:
                bas = pied + (haut - pied) * (0.22 if sabot else bande)
                m.cone((px, bas, zz), (px, pied, zz), r * 1.3, r * 1.3, chaussette, mode="peint")


def _joues(t, centre_y, z, ecart, r=0.045):
    for c in (-1, 1):
        t.boule((c * ecart, centre_y, z), (r, r * 0.65, r * 0.5), ROSE_JOUE, mode="peint")


def _pousse(t, base, couleur=rgb("7ee05a"), couleur2=rgb("4fb83c"), taille=1.0):
    """Petite pousse de graine sur la tête."""
    x, y, z = base
    t.cone((x, y - 0.02, z), (x, y + 0.07 * taille, z + 0.01), 0.012, 0.009, couleur2, fondu=0.01)
    t.boule((x - 0.045 * taille, y + 0.085 * taille, z), (0.045 * taille, 0.018 * taille, 0.028 * taille), couleur, rot=(0, 0, 20), fondu=0.01)
    t.boule((x + 0.045 * taille, y + 0.095 * taille, z), (0.045 * taille, 0.018 * taille, 0.028 * taille), couleur, rot=(0, 0, -25), fondu=0.01)


# --------------------------------------------------------------- Renardelle

def renardelle():
    s = Sculpteur("Renardelle")
    ORANGE, FONCE, NOIR = rgb("ff8a2b"), rgb("6b3a2a"), rgb("2b2233")
    corps = s.membre("Corps")
    corps.boule((0, -0.19, 0.06), (0.17, 0.15, 0.22), ORANGE)
    corps.boule((0, -0.2, -0.04), (0.12, 0.1, 0.12), CREME, mode="peint")
    _pattes4(s, ORANGE, FONCE, x=0.1, z_av=-0.06, z_ar=0.17, haut=-0.26, r=0.05, corps=corps)

    t = s.membre("Tete", "Tete", (0, 0.0, -0.06))
    t.boule((0, 0.13, -0.08), (0.22, 0.19, 0.18), ORANGE)
    # Masque crème du bas du visage et museau pointu.
    t.boule((0, 0.06, -0.18), (0.16, 0.1, 0.1), CREME, mode="peint")
    t.cone((0, 0.07, -0.16), (0, 0.055, -0.33), 0.09, 0.03, CREME, fondu=0.04)
    t.boule((0, 0.065, -0.335), (0.028, 0.022, 0.022), NOIR, fondu=0.0, plat=True)
    t.oeil((-0.095, 0.155, -0.215), 0.05)
    t.oeil((0.095, 0.155, -0.215), 0.05)
    _joues(t, 0.085, -0.235, 0.135)
    for c, nom in ((-1, "OreilleG"), (1, "OreilleD")):
        o = s.membre(nom, "Oreille", (c * 0.12, 0.27, -0.06), c)
        o.cone((c * 0.12, 0.25, -0.06), (c * 0.2, 0.44, -0.04), 0.075, 0.012, ORANGE, fondu=0.0)
        o.cone((c * 0.165, 0.36, -0.045), (c * 0.2, 0.44, -0.04), 0.045, 0.012, FONCE, mode="peint")
        o.cone((c * 0.125, 0.26, -0.09), (c * 0.18, 0.39, -0.075), 0.045, 0.012, ROSE_JOUE, mode="peint")
    _pousse(t, (0, 0.31, -0.06), taille=0.8)

    q = s.membre("Queue", "Queue", (0, -0.12, 0.26))
    q.courbe([(0, -0.14, 0.24), (0.04, -0.06, 0.36), (0.07, 0.08, 0.41), (0.06, 0.2, 0.38)], [0.06, 0.1, 0.105, 0.05], ORANGE)
    q.boule((0.065, 0.17, 0.39), (0.08, 0.08, 0.07), CREME, mode="peint")
    return s


def _aile(s, nom, cote, base, couleur, bout=None, longueur=0.2, rot=(0, 0, 0), epais=0.03):
    """Aile d'oiseau : ellipsoïde plat, bout de plumes d'une autre couleur."""
    x, y, z = base
    a = s.membre(nom, "Aile", base, cote)
    a.boule((x + cote * longueur * 0.45, y - 0.02, z + 0.02), (longueur * 0.55, longueur * 0.3, epais), couleur,
            rot=(rot[0], rot[1], rot[2] * cote), fondu=0.0)
    if bout:
        a.boule((x + cote * longueur * 0.85, y - 0.05, z + 0.03), (longueur * 0.25, longueur * 0.25, epais * 1.1), bout, mode="peint")
    return a


def _pieds_oiseau(s, couleur, x=0.08, y=-0.42, z=0.0):
    """Pattes d'oiseau sous le centre du corps : tige + trois doigts à plat."""
    for c, nom in ((-1, "PatteG"), (1, "PatteD")):
        m = s.membre(nom, "Patte", (c * x, y + 0.05, z), c, 0.0 if c < 0 else 0.5)
        m.cone((c * x, y + 0.07, z), (c * x, -0.465, z), 0.027, 0.024, couleur)
        for dx, dz in ((-0.03, -0.045), (0.0, -0.06), (0.03, -0.045)):
            m.cone((c * x, -0.472, z), (c * x + dx * 1.3, -0.478, z + dz * 1.3), 0.024, 0.019, couleur, fondu=0.015)


# -------------------------------------------------------------- Poussigraine

def poussigraine():
    s = Sculpteur("Poussigraine")
    JAUNE, COQUE, ORANGE = rgb("ffd94a"), rgb("a8663a"), rgb("ff9a2e")
    c = s.membre("Corps")
    c.boule((0, -0.12, 0.02), (0.3, 0.31, 0.29), JAUNE)
    c.boule((0, -0.2, -0.12), (0.18, 0.16, 0.12), rgb("fff3b0"), mode="peint")
    # Demi-coquille de graine posée comme un bonnet.
    t = s.membre("Tete", "Tete", (0, 0.1, 0))
    t.boule((0, 0.14, 0.03), (0.29, 0.17, 0.27), COQUE, fondu=0.0)
    t.boule((0, 0.05, 0.03), (0.31, 0.1, 0.29), COQUE, mode="creux")
    t.boule((0, 0.09, 0.03), (0.3, 0.025, 0.28), rgb("7a4528"), mode="peint")
    for dx, dz in ((-0.1, -0.12), (0.12, -0.05), (0.0, 0.08), (-0.14, 0.1)):
        t.boule((dx, 0.27, dz), (0.03, 0.02, 0.03), rgb("d99a62"), mode="peint")
    _pousse(t, (0, 0.3, 0.03), taille=1.2)
    c.oeil((-0.11, -0.04, -0.245), 0.06)
    c.oeil((0.11, -0.04, -0.245), 0.06)
    c.cone((0, -0.11, -0.27), (0, -0.12, -0.35), 0.045, 0.012, ORANGE, fondu=0.0)
    _joues(c, -0.12, -0.235, 0.17, 0.05)
    _aile(s, "AileG", -1, (-0.28, -0.12, 0.04), JAUNE, rgb("ffbf3a"), 0.14, rot=(0, 0, 30), epais=0.04)
    _aile(s, "AileD", 1, (0.28, -0.12, 0.04), JAUNE, rgb("ffbf3a"), 0.14, rot=(0, 0, 30), epais=0.04)
    _pieds_oiseau(s, ORANGE, x=0.1, y=-0.42, z=0.0)
    return s


# -------------------------------------------------------------- Champichou

def champichou():
    s = Sculpteur("Champichou")
    ROUGE, PIED = rgb("ff4f5e"), rgb("fff0dc")
    c = s.membre("Corps")
    c.cone((0, -0.36, 0), (0, 0.02, 0), 0.2, 0.17, PIED)
    c.boule((0, -0.36, 0), (0.2, 0.09, 0.2), PIED)
    c.oeil((-0.085, -0.12, -0.185), 0.048)
    c.oeil((0.085, -0.12, -0.185), 0.048)
    c.boule((0, -0.2, -0.205), (0.035, 0.018, 0.02), rgb("8a3a3a"), plat=True, fondu=0.0)
    _joues(c, -0.18, -0.19, 0.13)
    t = s.membre("Tete", "Tete", (0, 0.02, 0))
    t.boule((0, 0.12, 0), (0.37, 0.23, 0.35), ROUGE, fondu=0.0)
    t.boule((0, -0.03, 0), (0.44, 0.13, 0.42), ROUGE, mode="creux")
    t.boule((0, 0.0, 0), (0.35, 0.04, 0.33), rgb("ffd6c2"), mode="peint")
    import math as _m
    for i in range(9):
        a = i * 2.4
        rr = 0.15 + 0.12 * ((i * 7) % 3) / 2
        x, z = rr * _m.cos(a), rr * _m.sin(a)
        y = 0.12 + 0.23 * max(0.0, 1 - (x * x / 0.37 ** 2 + z * z / 0.35 ** 2)) ** 0.5
        t.boule((x, y, z), (0.055, 0.04, 0.055), BLANC_POIS, mode="peint")
    for cc, nom in ((-1, "PiedG"), (1, "PiedD")):
        m = s.membre(nom, "Patte", (cc * 0.09, -0.4, -0.05), cc, 0.0 if cc < 0 else 0.5)
        m.cone((cc * 0.1, -0.4, -0.12), (cc * 0.11, -0.455, -0.17), 0.05, 0.05, rgb("f3dcc0"))
        m.boule((cc * 0.11, -0.46, -0.21), (0.065, 0.04, 0.075), rgb("e8c8a8"), fondu=0.03)
    return s


BLANC_POIS = rgb("fffaf2")


# ------------------------------------------------------------------ Lapinou

def lapinou():
    s = Sculpteur("Lapinou")
    BLANC_L, LILAS, ROSE = rgb("f6f1ff"), rgb("c9b5ff"), rgb("ffb3c8")
    c = s.membre("Corps")
    c.boule((0, -0.27, 0.07), (0.21, 0.19, 0.21), BLANC_L)
    c.boule((0, -0.3, -0.08), (0.12, 0.1, 0.07), LILAS, mode="peint")
    q = s.membre("Queue", "Queue", (0, -0.25, 0.25))
    q.boule((0, -0.24, 0.28), (0.07, 0.07, 0.06), LILAS)
    t = s.membre("Tete", "Tete", (0, -0.12, -0.02))
    t.boule((0, 0.0, -0.04), (0.22, 0.19, 0.19), BLANC_L)
    t.boule((0, 0.15, 0.02), (0.15, 0.06, 0.12), LILAS, mode="peint")
    t.oeil((-0.09, 0.01, -0.19), 0.052, iris=rgb("8a6cff"))
    t.oeil((0.09, 0.01, -0.19), 0.052, iris=rgb("8a6cff"))
    t.boule((0, -0.06, -0.225), (0.025, 0.017, 0.015), ROSE, fondu=0.0, plat=True)
    t.boite((0, -0.105, -0.215), (0.025, 0.022, 0.01), BLANC, arrondi=0.008, fondu=0.0)
    _joues(t, -0.06, -0.2, 0.135)
    for cc, nom in ((-1, "OreilleG"), (1, "OreilleD")):
        o = s.membre(nom, "Oreille", (cc * 0.08, 0.15, -0.02), cc)
        o.courbe([(cc * 0.08, 0.13, -0.02), (cc * 0.11, 0.3, 0.0), (cc * 0.15, 0.44, 0.04)], [0.05, 0.06, 0.035], BLANC_L, fondu=0.0)
        o.courbe([(cc * 0.085, 0.18, -0.055), (cc * 0.11, 0.3, -0.04), (cc * 0.14, 0.4, -0.01)], [0.025, 0.035, 0.018], ROSE, mode="peint")
        o.boule((cc * 0.15, 0.43, 0.04), (0.04, 0.04, 0.04), LILAS, mode="peint")
    for cc in (-1, 1):
        n = "G" if cc < 0 else "D"
        c.boule((cc * 0.13, -0.34, 0.11), (0.085, 0.1, 0.11), BLANC_L, fondu=0.08)
        ar = s.membre(f"PatteAr{n}", "Patte", (cc * 0.13, -0.42, 0.08), cc, 0.5)
        ar.boule((cc * 0.13, -0.46, 0.0), (0.055, 0.032, 0.115), BLANC_L, fondu=0.0)
        ar.boule((cc * 0.13, -0.49, -0.03), (0.03, 0.01, 0.05), ROSE, mode="peint")
        av = s.membre(f"PatteAv{n}", "Patte", (cc * 0.075, -0.3, -0.11), cc, 0.0)
        av.cone((cc * 0.075, -0.32, -0.11), (cc * 0.075, -0.455, -0.135), 0.04, 0.036, BLANC_L, fondu=0.0)
        av.boule((cc * 0.075, -0.465, -0.145), (0.04, 0.025, 0.05), BLANC_L, fondu=0.02)
    return s


# -------------------------------------------------------------- Tortipousse

def tortipousse():
    s = Sculpteur("Tortipousse")
    PEAU, CARA, BORD = rgb("8fe07a"), rgb("3fae6a"), rgb("f2d36b")
    c = s.membre("Corps")
    c.boule((0, -0.17, 0.08), (0.3, 0.2, 0.32), CARA, fondu=0.0)
    c.boule((0, -0.33, 0.08), (0.34, 0.07, 0.36), CARA, mode="creux")
    c.boule((0, -0.3, 0.08), (0.31, 0.04, 0.33), BORD, fondu=0.02)
    # Écailles hexagonales peintes sur la carapace.
    import math as _m
    for i, (x, z) in enumerate([(0, 0.08), (-0.15, -0.05), (0.15, -0.05), (-0.15, 0.2), (0.15, 0.2), (0, -0.14), (0, 0.29)]):
        y = -0.17 + 0.2 * max(0.0, 1 - (x * x / 0.09 + (z - 0.08) ** 2 / 0.1)) ** 0.5
        c.boule((x, y, z), (0.08, 0.03, 0.08), rgb("62cc85"), mode="peint")
    _pousse(c, (0.02, 0.03, 0.08), taille=1.4)
    t = s.membre("Tete", "Tete", (0, -0.2, -0.2))
    t.cone((0, -0.24, -0.16), (0, -0.16, -0.3), 0.08, 0.1, PEAU)
    t.boule((0, -0.1, -0.33), (0.17, 0.15, 0.15), PEAU)
    t.oeil((-0.075, -0.07, -0.465), 0.045)
    t.oeil((0.075, -0.07, -0.465), 0.045)
    t.boite((0, -0.155, -0.475), (0.04, 0.006, 0.01), rgb("2f6b3a"), arrondi=0.005, fondu=0.0, plat=True)
    _joues(t, -0.14, -0.455, 0.11, 0.035)
    for cc in (-1, 1):
        for zz, nz, ph in ((-0.1, "Av", 0.0), (0.26, "Ar", 0.5)):
            m = s.membre(f"Patte{nz}{'G' if cc < 0 else 'D'}", "Patte", (cc * 0.18, -0.3, zz), cc, ph)
            # Patte trapue qui sort en biais de sous la carapace.
            m.boule((cc * 0.16, -0.31, zz), (0.08, 0.06, 0.08), PEAU, fondu=0.0)
            m.cone((cc * 0.17, -0.31, zz), (cc * 0.27, -0.42, zz + (-0.03 if nz == "Av" else 0.03)), 0.065, 0.075, PEAU, fondu=0.03)
            m.boule((cc * 0.28, -0.45, zz + (-0.04 if nz == "Av" else 0.03)), (0.085, 0.04, 0.085), PEAU, fondu=0.03)
            for dx in (-0.035, 0.0, 0.035):
                m.boule((cc * 0.28 + dx, -0.46, zz + (-0.12 if nz == "Av" else -0.05)), (0.017, 0.015, 0.015), rgb("e9ffd8"), mode="peint")
    q = s.membre("Queue", "Queue", (0, -0.3, 0.38))
    q.cone((0, -0.3, 0.36), (0, -0.33, 0.47), 0.04, 0.012, PEAU)
    return s


# --------------------------------------------------------------- Hibouflor

def hibouflor():
    s = Sculpteur("Hibouflor")
    PLUME, VENTRE, FLEUR = rgb("6a7cff"), rgb("dfe6ff"), rgb("ff7fc4")
    c = s.membre("Corps")
    c.boule((0, -0.13, 0.02), (0.28, 0.33, 0.25), PLUME)
    c.boule((0, -0.2, -0.16), (0.19, 0.2, 0.1), VENTRE, mode="peint")
    for i, (x, y) in enumerate([(-0.08, -0.12), (0.08, -0.12), (0.0, -0.2), (-0.08, -0.28), (0.08, -0.28)]):
        c.boule((x, y, -0.235), (0.035, 0.018, 0.02), rgb("aab8ff"), mode="peint")
    # Disque facial et gros yeux à iris doré.
    c.boule((-0.1, 0.07, -0.19), (0.11, 0.11, 0.06), VENTRE, fondu=0.02)
    c.boule((0.1, 0.07, -0.19), (0.11, 0.11, 0.06), VENTRE, fondu=0.02)
    c.oeil((-0.1, 0.07, -0.235), 0.07, iris=rgb("ffc23a"))
    c.oeil((0.1, 0.07, -0.235), 0.07, iris=rgb("ffc23a"))
    c.cone((0, 0.0, -0.24), (0, -0.05, -0.29), 0.035, 0.01, rgb("ffa23a"), fondu=0.0)
    for cc, nom in ((-1, "OreilleG"), (1, "OreilleD")):
        o = s.membre(nom, "Oreille", (cc * 0.16, 0.16, -0.02), cc)
        o.cone((cc * 0.15, 0.12, -0.02), (cc * 0.24, 0.32, 0.0), 0.07, 0.015, PLUME, fondu=0.0)
    # Fleur sur la tête.
    import math as _m
    for i in range(5):
        a = i * 2 * _m.pi / 5
        c.boule((0.06 * _m.cos(a), 0.235, 0.02 + 0.06 * _m.sin(a)), (0.05, 0.02, 0.05), FLEUR, fondu=0.0)
    c.boule((0, 0.25, 0.02), (0.035, 0.025, 0.035), rgb("ffe066"), fondu=0.0)
    _aile(s, "AileG", -1, (-0.26, -0.08, 0.04), PLUME, rgb("4a58d8"), 0.16, rot=(0, 0, 75), epais=0.05)
    _aile(s, "AileD", 1, (0.26, -0.08, 0.04), PLUME, rgb("4a58d8"), 0.16, rot=(0, 0, 75), epais=0.05)
    _pieds_oiseau(s, rgb("ffa23a"), x=0.09, y=-0.42, z=0.0)
    return s


# -------------------------------------------------------------- Cerfaurore

def cerfaurore():
    s = Sculpteur("Cerfaurore")
    FAON, VENTRE, BOIS = rgb("e8a066"), rgb("fff0dc"), rgb("ffb8e6")
    c = s.membre("Corps")
    c.boule((0, -0.1, 0.08), (0.15, 0.13, 0.22), FAON)
    c.boule((0, -0.15, 0.06), (0.1, 0.07, 0.16), VENTRE, mode="peint")
    for x, y, z in ((-0.1, -0.03, 0.02), (0.1, -0.02, 0.1), (-0.09, 0.0, 0.17), (0.08, -0.05, 0.0), (0.0, 0.02, 0.12), (-0.04, 0.03, 0.22)):
        c.boule((x, y, z), (0.025, 0.02, 0.025), VENTRE, mode="peint")
    _pattes4(s, FAON, rgb("7a4a35"), x=0.09, z_av=-0.05, z_ar=0.2, haut=-0.15, r=0.04, corps=c,
             coussinet=(1.05, 0.62, 1.3), bande=0.4)
    q = s.membre("Queue", "Queue", (0, -0.04, 0.29))
    q.cone((0, -0.04, 0.28), (0, 0.0, 0.34), 0.04, 0.035, VENTRE)
    t = s.membre("Tete", "Tete", (0, 0.0, -0.08))
    t.cone((0, -0.05, -0.06), (0, 0.08, -0.12), 0.07, 0.07, FAON)
    t.boule((0, 0.15, -0.14), (0.17, 0.15, 0.15), FAON)
    t.cone((0, 0.11, -0.22), (0, 0.09, -0.3), 0.08, 0.05, VENTRE, fondu=0.03)
    t.boule((0, 0.1, -0.33), (0.026, 0.02, 0.016), rgb("3a2530"), fondu=0.0, plat=True)
    t.oeil((-0.075, 0.17, -0.255), 0.045)
    t.oeil((0.075, 0.17, -0.255), 0.045)
    _joues(t, 0.11, -0.27, 0.11, 0.035)
    for cc in (-1, 1):
        t.boule((cc * 0.17, 0.2, -0.12), (0.08, 0.03, 0.04), FAON, rot=(0, 0, cc * -20), fondu=0.01)
        # Bois de lumière (aurore) qui brillent.
        t.courbe([(cc * 0.07, 0.27, -0.12), (cc * 0.1, 0.36, -0.1), (cc * 0.17, 0.44, -0.08)], [0.022, 0.018, 0.012], BOIS, fondu=0.01, plat=True)
        t.cone((cc * 0.1, 0.36, -0.1), (cc * 0.04, 0.44, -0.12), 0.016, 0.01, rgb("ffe08a"), fondu=0.01, plat=True)
        t.cone((cc * 0.14, 0.41, -0.09), (cc * 0.21, 0.45, -0.13), 0.014, 0.009, rgb("b8e6ff"), fondu=0.01, plat=True)
    return s


# -------------------------------------------------------------- Lionfeuille

def lionfeuille():
    s = Sculpteur("Lionfeuille")
    FAUVE, VENTRE, FEUILLE, FEUILLE2 = rgb("ffc94d"), rgb("fff2c8"), rgb("58d36a"), rgb("2fae5a")
    c = s.membre("Corps")
    c.boule((0, -0.19, 0.08), (0.18, 0.15, 0.22), FAUVE)
    c.boule((0, -0.24, 0.0), (0.11, 0.08, 0.12), VENTRE, mode="peint")
    _pattes4(s, FAUVE, rgb("ffe39a"), x=0.11, z_av=-0.05, z_ar=0.19, haut=-0.26, r=0.058, corps=c)
    q = s.membre("Queue", "Queue", (0, -0.12, 0.28))
    q.courbe([(0, -0.14, 0.27), (0.03, -0.04, 0.38), (0.03, 0.08, 0.42)], [0.03, 0.025, 0.02], FAUVE)
    q.boule((0.03, 0.11, 0.42), (0.06, 0.045, 0.03), FEUILLE, rot=(0, 0, 30), fondu=0.0)
    t = s.membre("Tete", "Tete", (0, 0.02, -0.08))
    # Crinière de feuilles autour de la tête.
    import math as _m
    for i in range(12):
        a = i * 2 * _m.pi / 12
        col = FEUILLE if i % 2 == 0 else FEUILLE2
        t.boule((0.25 * _m.cos(a), 0.12 + 0.24 * _m.sin(a), -0.03), (0.09, 0.05, 0.04), col, rot=(0, 0, _m.degrees(a)), fondu=0.0)
    t.boule((0, 0.12, -0.06), (0.25, 0.25, 0.1), FEUILLE2, fondu=0.02)
    t.boule((0, 0.12, -0.12), (0.18, 0.16, 0.15), FAUVE, fondu=0.0)
    t.boule((0, 0.06, -0.24), (0.09, 0.06, 0.06), VENTRE, fondu=0.02)
    t.boule((0, 0.09, -0.29), (0.03, 0.022, 0.018), rgb("8a4a3a"), fondu=0.0, plat=True)
    t.oeil((-0.075, 0.15, -0.255), 0.046)
    t.oeil((0.075, 0.15, -0.255), 0.046)
    _joues(t, 0.07, -0.26, 0.12, 0.035)
    for cc in (-1, 1):
        t.boule((cc * 0.12, 0.26, -0.1), (0.04, 0.04, 0.025), FAUVE, fondu=0.0)
    return s


# ---------------------------------------------------------------- Dragonnet

def dragonnet():
    s = Sculpteur("Dragonnet")
    ECAILLE, VENTRE, CORNE, AILE = rgb("39c6c0"), rgb("fff0b8"), rgb("ffe7a8"), rgb("8a6cff")
    c = s.membre("Corps")
    c.boule((0, -0.2, 0.06), (0.18, 0.18, 0.2), ECAILLE)
    c.boule((0, -0.22, -0.06), (0.12, 0.13, 0.1), VENTRE, mode="peint")
    for i, (y, z) in enumerate(((-0.03, 0.06), (-0.06, 0.16), (-0.12, 0.24))):
        c.cone((0, y, z), (0, y + 0.06, z + 0.03), 0.03, 0.006, AILE, fondu=0.01)
    _pattes4(s, ECAILLE, ECAILLE, x=0.11, z_av=-0.05, z_ar=0.17, haut=-0.26, r=0.06, corps=c)
    q = s.membre("Queue", "Queue", (0, -0.28, 0.24))
    q.courbe([(0, -0.3, 0.22), (0.05, -0.36, 0.34), (0.14, -0.38, 0.42), (0.22, -0.34, 0.45)], [0.07, 0.05, 0.035, 0.02], ECAILLE)
    q.boule((0.25, -0.33, 0.45), (0.05, 0.03, 0.03), AILE, rot=(0, 0, 30), fondu=0.0)
    t = s.membre("Tete", "Tete", (0, -0.02, -0.06))
    t.boule((0, 0.12, -0.08), (0.21, 0.18, 0.18), ECAILLE)
    t.boule((0, 0.06, -0.2), (0.13, 0.08, 0.09), ECAILLE, fondu=0.04)
    for cc in (-1, 1):
        t.boule((cc * 0.04, 0.08, -0.29), (0.012, 0.01, 0.01), rgb("1d4a4a"), plat=True, mode="peint")
    t.oeil((-0.09, 0.15, -0.225), 0.055, iris=rgb("ffb52e"))
    t.oeil((0.09, 0.15, -0.225), 0.055, iris=rgb("ffb52e"))
    _joues(t, 0.07, -0.23, 0.13, 0.035)
    for cc in (-1, 1):
        t.courbe([(cc * 0.09, 0.25, -0.03), (cc * 0.12, 0.32, 0.02), (cc * 0.13, 0.35, 0.09)], [0.035, 0.022, 0.008], CORNE, fondu=0.01)
        t.boule((cc * 0.2, 0.17, 0.0), (0.06, 0.025, 0.035), AILE, rot=(0, 0, cc * -30), fondu=0.0)
    for cc, nom in ((-1, "AileG"), (1, "AileD")):
        a = s.membre(nom, "Aile", (cc * 0.12, -0.08, 0.08), cc)
        a.cone((cc * 0.12, -0.07, 0.08), (cc * 0.3, 0.1, 0.14), 0.025, 0.015, ECAILLE, fondu=0.0)
        a.boule((cc * 0.25, 0.0, 0.14), (0.13, 0.1, 0.015), AILE, rot=(0, cc * -20, cc * 35), fondu=0.02)
    return s


# -------------------------------------------------------------- Phenigraine

def phenigraine():
    s = Sculpteur("Phenigraine")
    ROUGE, OR, FLAMME, VENTRE = rgb("ff5a3c"), rgb("ffc53a"), rgb("ffef8a"), rgb("ffd0a0")
    c = s.membre("Corps")
    c.boule((0, -0.13, 0.02), (0.26, 0.29, 0.25), ROUGE)
    c.boule((0, -0.2, -0.14), (0.17, 0.17, 0.1), VENTRE, mode="peint")
    c.oeil((-0.1, -0.0, -0.215), 0.06, iris=rgb("ffd23a"))
    c.oeil((0.1, -0.0, -0.215), 0.06, iris=rgb("ffd23a"))
    c.cone((0, -0.08, -0.24), (0, -0.12, -0.31), 0.04, 0.01, OR, fondu=0.0)
    _joues(c, -0.08, -0.22, 0.16, 0.04)
    # Crête de flammes (lumineuse).
    for i, (x, h, z) in enumerate(((0, 0.36, 0.0), (-0.08, 0.3, 0.04), (0.08, 0.31, 0.03), (0, 0.27, 0.1))):
        c.cone((x, 0.12, z), (x * 1.4, h, z + 0.05), 0.06, 0.008, OR if i else FLAMME, fondu=0.02, plat=i == 0)
    _aile(s, "AileG", -1, (-0.24, -0.08, 0.04), ROUGE, OR, 0.18, rot=(0, 0, 70), epais=0.045)
    _aile(s, "AileD", 1, (0.24, -0.08, 0.04), ROUGE, OR, 0.18, rot=(0, 0, 70), epais=0.045)
    q = s.membre("Queue", "Queue", (0, -0.2, 0.24))
    for dx, col in ((-0.07, OR), (0.0, FLAMME), (0.07, OR)):
        q.courbe([(dx * 0.5, -0.22, 0.22), (dx, -0.25, 0.35), (dx * 1.8, -0.18, 0.46)], [0.05, 0.04, 0.012], col, fondu=0.02, plat=col == FLAMME)
    _pieds_oiseau(s, OR, x=0.09, y=-0.42, z=0.0)
    return s


ESPECES = {
    "Poussigraine": poussigraine,
    "Champichou": champichou,
    "Lapinou": lapinou,
    "Tortipousse": tortipousse,
    "Renardelle": renardelle,
    "Hibouflor": hibouflor,
    "Cerfaurore": cerfaurore,
    "Lionfeuille": lionfeuille,
    "Dragonnet": dragonnet,
    "Phenigraine": phenigraine,
}
