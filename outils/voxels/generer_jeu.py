"""Écrit les données voxel des espèces dans src/shared/Voxels/<Nom>.luau
(utilisées en jeu par ConstructeurVoxels, côté client).

python3 generer_jeu.py [nom ...]   (défaut : toutes les espèces sculptées)
La résolution baisse automatiquement si une pièce dépasse 19 000 triangles.
"""

import json
import os
import sys

import numpy as np

from studio_export import TOUT, exporter

ICI = os.path.dirname(os.path.abspath(__file__))
SORTIE = os.path.join(ICI, "..", "..", "src", "shared", "Voxels")


def triangles_max(tete, runs_b64, res):
    # Estimation fiable : 2 triangles par face visible, recalculée ici.
    import base64
    runs = base64.b64decode(runs_b64)
    pr = 0
    pire = 0
    for m in tete["membres"]:
        b0, b1 = m["b0"], m["b1"]
        d = [b1[i] - b0[i] + 1 for i in range(3)]
        occ = np.zeros(d, dtype=bool)
        for x in range(d[0]):
            for y in range(d[1]):
                nr = runs[pr]
                pr += 1
                for _ in range(nr):
                    a, l = runs[pr], runs[pr + 1]
                    pr += 2
                    occ[x, y, a : a + l] = True
        pad = np.pad(occ, 1)
        faces = 0
        for ax in range(3):
            for sg in (-1, 1):
                sl = [slice(1, d[i] + 1) for i in range(3)]
                sl[ax] = slice(1 + sg, d[ax] + 1 + sg)
                faces += int((occ & ~pad[tuple(sl)]).sum())
        pire = max(pire, faces * 2)
    return pire


def ecrire(nom):
    for res in (80, 72, 64):
        tete, runs, cols = exporter(nom, res)
        pire = triangles_max(tete, runs, res)
        if pire <= 19000:
            break
    os.makedirs(SORTIE, exist_ok=True)
    texte = (
        "-- Généré par outils/voxels/generer_jeu.py : ne pas modifier à la main.\n"
        f"-- {nom} : résolution {res}, pièce la plus lourde {pire} triangles.\n"
        "return {\n"
        f"\ttete = [[{json.dumps(tete, separators=(',', ':'))}]],\n"
        f"\truns = [[{runs}]],\n"
        f"\tcols = [[{cols}]],\n"
        "}\n"
    )
    with open(os.path.join(SORTIE, f"{nom}.luau"), "w") as f:
        f.write(texte)
    print(nom, res, pire, len(texte))


if __name__ == "__main__":
    for n in sys.argv[1:] or list(TOUT):
        ecrire(n)
