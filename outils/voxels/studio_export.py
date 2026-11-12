"""Export compact pour Roblox Studio, transmis en texte (base64).

Par membre : boîte englobante, puis l'occupation colonne par colonne en
plages (nombre de plages, puis début/longueur de chaque plage), puis un octet
de couleur (palette de 256 max) par voxel visible, dans l'ordre x, y, z.
Le Luau recalcule les faces visibles, l'arrondi léger et construit un
EditableMesh coloré par face."""

import base64
import json
import sys

import numpy as np
from PIL import Image

import especes
import monstres
from sculpteur import Sculpteur

from catalogue import TOUT  # noqa: E402


def _exposes(occ):
    res = occ.shape[0]
    pad = np.pad(occ, 1)
    vis = np.zeros_like(occ)
    for ax in range(3):
        for sg in (-1, 1):
            sl = [slice(1, res + 1)] * 3
            sl[ax] = slice(1 + sg, res + 1 + sg)
            vis |= occ & ~pad[tuple(sl)]
    return vis


def exporter(nom, res=80):
    Sculpteur.__init__.__defaults__ = (res, "arrondi")
    s = TOUT[nom]()
    s.peindre()
    blocs = []
    for m in s.membres:
        occ = m.d < 0
        if occ.any():
            blocs.append((m, occ, _exposes(occ)))
    # Palette commune réduite à 256 couleurs.
    toutes = np.concatenate([m.couleur[vis] for m, occ, vis in blocs]).astype(np.uint8)
    img = Image.fromarray(toutes[None, :, :]).quantize(colors=256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    indices = np.array(img).ravel().astype(np.uint8)
    pal = np.array(img.getpalette()[: 256 * 3]).reshape(-1, 3)[: int(indices.max()) + 1]
    runs, couleurs, membres = bytearray(), bytearray(), []
    debut = 0
    for m, occ, vis in blocs:
        xs, ys, zs = np.nonzero(occ)
        b0 = [int(xs.min()), int(ys.min()), int(zs.min())]
        b1 = [int(xs.max()), int(ys.max()), int(zs.max())]
        r0 = len(runs)
        for x in range(b0[0], b1[0] + 1):
            for y in range(b0[1], b1[1] + 1):
                col = occ[x, y, b0[2] : b1[2] + 1].astype(np.int8)
                d = np.diff(np.concatenate([[0], col, [0]]))
                starts, ends = np.nonzero(d == 1)[0], np.nonzero(d == -1)[0]
                runs.append(len(starts))
                for a, e in zip(starts, ends):
                    runs += bytes((int(a), int(e - a)))
        n = int(vis.sum())  # ordre de np.nonzero = x, y, z croissants
        couleurs += indices[debut : debut + n].tobytes()
        debut += n
        membres.append({"n": m.nom, "r": m.role, "j": [round(float(v), 4) for v in m.joint], "c": m.cote,
                        "ph": m.phase, "p": s._parent(m), "b0": b0, "b1": b1, "nr": len(runs) - r0, "nc": n})
    tete = {"nom": nom, "res": res, "membres": membres, "pal": pal.astype(int).ravel().tolist()}
    return tete, base64.b64encode(bytes(runs)).decode(), base64.b64encode(bytes(couleurs)).decode()


if __name__ == "__main__":
    t, r, c = exporter(sys.argv[1], int(sys.argv[2]) if len(sys.argv) > 2 else 80)
    print(len(json.dumps(t, separators=(",", ":"))), len(r), len(c))
