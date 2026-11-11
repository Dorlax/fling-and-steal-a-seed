"""Poses automatiques par rôle de membre (Patte, Bras, Aile, Queue, Oreille,
Tete…). Chaque animation est une boucle : fonction(sculpteur, t) avec t dans
[0, 1[, qui renvoie {nom du membre: (rotation en degrés (x, y, z),
translation (x, y, z))}. La clé « racine » déplace toute la créature
(pivot au sol).

Conventions : l'avant est -z ; une rotation x négative penche vers l'avant.
Ces mêmes poses servent de référence pour les animations en jeu.
"""

import math

TAU = 2 * math.pi


def _s(t, f=1.0, ph=0.0):
    return math.sin(TAU * (f * t + ph))


def _doux(e):
    e = min(1.0, max(0.0, e))
    return e * e * (3 - 2 * e)


def _base(s, t, ampl=1.0, freq=1.0):
    """Cycle de marche commun (pattes, bras, queue, oreilles, ailes, tête)."""
    pose = {}
    for m in s.membres:
        ph = m.phase
        if m.role == "Patte":
            pose[m.nom] = ((28 * ampl * _s(t, freq, ph), 0, 0), (0, 0.012 * ampl * max(0, _s(t, freq, ph + 0.25)), 0))
        elif m.role == "Bras":
            pose[m.nom] = ((-25 * ampl * _s(t, freq, ph), 0, 0), (0, 0, 0))
        elif m.role == "Queue":
            pose[m.nom] = ((0, 18 * ampl * _s(t, freq), 6 * _s(t, freq * 2)), (0, 0, 0))
        elif m.role == "Oreille":
            pose[m.nom] = ((0, 0, m.cote * 6 * ampl * _s(t, freq * 2)), (0, 0, 0))
        elif m.role == "Aile":
            pose[m.nom] = ((0, 0, m.cote * 14 * ampl * _s(t, freq * 2)), (0, 0, 0))
        elif m.role == "Tete":
            pose[m.nom] = ((4 * ampl * _s(t, freq * 2), 3 * _s(t, freq), 0), (0, 0, 0))
    return pose


def _sans_pattes(s):
    return not any(m.role in ("Patte", "Bras") for m in s.membres)


def marche(s, t):
    pose = _base(s, t)
    if _sans_pattes(s):  # gelée : avance par petits bonds
        pose["racine"] = ((-6 * _s(t, 2, 0.25), 0, 4 * _s(t)), (0, 0.07 * abs(_s(t, 2)), 0))
    else:
        pose["racine"] = ((0, 0, 2 * _s(t)), (0, 0.012 * abs(_s(t, 2)), 0))
    return pose


def course(s, t):
    pose = _base(s, t, ampl=1.7, freq=2)
    if _sans_pattes(s):
        pose["racine"] = ((-12, 0, 5 * _s(t, 2)), (0, 0.12 * abs(_s(t, 3)), 0))
    else:
        pose["racine"] = ((-8, 0, 3 * _s(t, 2)), (0, 0.035 * abs(_s(t, 4)), 0))
    return pose


def repos(s, t):
    """Respiration, regard qui balaie, oreilles qui frétillent, queue lente."""
    pose = {}
    tic = _doux((t - 0.62) / 0.05) * (1 - _doux((t - 0.72) / 0.05))
    for m in s.membres:
        if m.role == "Tete":
            pose[m.nom] = ((3 * _s(t, 2), 20 * _s(t), 4 * _s(t, 1, 0.25)), (0, 0, 0))
        elif m.role == "Oreille":
            pose[m.nom] = ((0, 0, m.cote * 18 * tic), (0, 0, 0))
        elif m.role == "Queue":
            pose[m.nom] = ((0, 12 * _s(t, 2), 0), (0, 0, 0))
        elif m.role == "Aile":
            pose[m.nom] = ((0, 0, m.cote * 6 * _s(t, 2)), (0, 0, 0))
        elif m.role == "Bras":
            pose[m.nom] = ((4 * _s(t, 2), 0, m.cote * 3 * _s(t, 2)), (0, 0, 0))
    pose["racine"] = ((0, 0, 0), (0, 0.006 * (1 + _s(t, 2)), 0))
    return pose


def plaquage(s, t):
    """Élan en arrière, bond en avant (le monstre percute le joueur), retour."""
    if t < 0.35:
        e, recul, bond = _doux(t / 0.35), 1.0, 0.0
        incl, z, y, j = 12 * e, 0.07 * e, -0.03 * e, -25 * e
    elif t < 0.55:
        e = _doux((t - 0.35) / 0.2)
        incl = 12 - 40 * e
        z = 0.07 - 0.3 * e
        y = -0.03 + 0.03 * e + 0.12 * math.sin(math.pi * e)
        j = -25 + 65 * e
        bond = e
    else:
        e = 1 - _doux((t - 0.55) / 0.45)
        incl, z, y, j, bond = -28 * e, -0.23 * e, 0.0, 40 * e, e
    pose = {}
    for m in s.membres:
        if m.role == "Patte":
            sens = 1 if "Av" in m.nom else (-1 if "Ar" in m.nom else -m.cote)
            pose[m.nom] = ((sens * j, 0, 0), (0, 0, 0))
        elif m.role == "Bras":
            pose[m.nom] = ((95 * bond, 0, m.cote * -10 * bond), (0, 0, 0))
        elif m.role == "Tete":
            pose[m.nom] = ((-12 * bond, 0, 0), (0, 0, 0))
        elif m.role == "Queue":
            pose[m.nom] = ((25 * bond, 0, 0), (0, 0, 0))
        elif m.role == "Oreille":
            pose[m.nom] = ((25 * bond, 0, 0), (0, 0, 0))
        elif m.role == "Aile":
            pose[m.nom] = ((0, 0, m.cote * 35 * bond), (0, 0, 0))
    pose["racine"] = ((incl, 0, 0), (0, y, z))
    return pose


def drole(s, t):
    """Saut avec pirouette, pattes repliées, oreilles qui volent, bras en l'air."""
    saut = math.sin(math.pi * t)
    pose = {}
    for m in s.membres:
        if m.role == "Patte":
            pose[m.nom] = ((35 * saut * (1 if "Av" in m.nom else -1), 0, 0), (0, 0.03 * saut, 0))
        elif m.role == "Bras":
            pose[m.nom] = ((0, 0, m.cote * 130 * saut), (0, 0, 0))
        elif m.role == "Oreille":
            pose[m.nom] = ((0, 0, m.cote * 30 * saut), (0, 0, 0))
        elif m.role == "Aile":
            pose[m.nom] = ((0, 0, m.cote * 45 * _s(t, 3)), (0, 0, 0))
        elif m.role == "Queue":
            pose[m.nom] = ((0, 30 * _s(t, 2), 0), (0, 0, 0))
        elif m.role == "Tete":
            pose[m.nom] = ((-10 * saut, 0, 10 * _s(t, 2)), (0, 0, 0))
    pose["racine"] = ((0, 360 * _doux(t), 0), (0, 0.26 * saut, 0))
    return pose


POSES = {"marche": marche, "course": course, "repos": repos, "plaquage": plaquage, "drole": drole}
