"""Sculpteur de créatures en voxels fins (style pixel), pour Fling & Steal a Seed.

Une créature tient dans une boîte de 1 x 1 x 1 : pieds à y = -0.5, avant vers
-z, droite vers +x (mêmes conventions que src/shared/Bestiaire.luau).

On sculpte avec des volumes doux (distances signées) : ellipsoïdes, cônes
arrondis (pattes, queues, cornes) et boîtes arrondies, fondus entre eux
membre par membre (corps, tête, pattes…) pour garder les animations du jeu.

Ensuite :
  * ombrage façon pixel art : 3 tons francs par couleur (ombre, base,
    lumière), tramage régulier aux transitions, léger grain ;
  * maillage en petits cubes, en style « cubes » ou « arrondi léger »
    (les marches entre cubes sont adoucies, le grain des couleurs reste) ;
  * aperçu PNG avec contour cartoon ;
  * export OBJ + MTL + palette PNG, un objet par membre.
"""

from __future__ import annotations

import json
import math
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

# ---------------------------------------------------------------- couleurs

def rgb(h: str) -> tuple[int, int, int]:
    h = h.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))  # type: ignore


NOIR_OEIL = rgb("1d1626")
BLANC = rgb("ffffff")
CONTOUR = np.array(rgb("2a1f3d"), dtype=np.float32)

# Matrice de Bayer 4x4 pour le tramage des transitions.
BAYER = (np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) + 0.5) / 16.0


def _rot(deg) -> np.ndarray:
    """Matrice de rotation (degrés x, y, z, appliquées dans cet ordre)."""
    if deg is None:
        return np.eye(3, dtype=np.float32)
    ax, ay, az = (math.radians(d) for d in deg)
    rx = np.array([[1, 0, 0], [0, math.cos(ax), -math.sin(ax)], [0, math.sin(ax), math.cos(ax)]])
    ry = np.array([[math.cos(ay), 0, math.sin(ay)], [0, 1, 0], [-math.sin(ay), 0, math.cos(ay)]])
    rz = np.array([[math.cos(az), -math.sin(az), 0], [math.sin(az), math.cos(az), 0], [0, 0, 1]])
    return (rz @ ry @ rx).astype(np.float32)


def smin(a, b, k):
    """Union douce de deux distances signées (k = rayon du congé)."""
    if k <= 0:
        return np.minimum(a, b)
    h = np.clip(0.5 + 0.5 * (b - a) / k, 0.0, 1.0)
    return b * (1 - h) + a * h - k * h * (1 - h)


# ---------------------------------------------------------------- membre

class Membre:
    def __init__(self, sculpteur: "Sculpteur", nom: str, role: str | None, joint, cote: int = 0, phase: float = 0.0,
                 parent: str | None = None):
        self.s = sculpteur
        self.parent = parent
        self.nom = nom
        self.role = role
        self.joint = joint
        self.cote = cote
        self.phase = phase
        n = sculpteur.res
        self.d = np.full((n, n, n), 9.0, dtype=np.float32)  # distance signée
        self.col = np.zeros((n, n, n, 3), dtype=np.float32)
        self.plat = np.zeros((n, n, n), dtype=bool)  # pas d'ombrage (yeux, reflets)

    # -- outils internes
    def _coords(self, centre, rot):
        s = self.s
        p = np.stack([s.X - centre[0], s.Y - centre[1], s.Z - centre[2]], axis=-1)
        if rot is not None:
            p = p @ _rot(rot)  # rotation inverse (transposée appliquée à droite)
        return p

    def _ajouter(self, dp, couleur, mode, fondu, plat=False):
        couleur = np.array(couleur, dtype=np.float32)
        if mode == "peint":
            m = (dp < 0.004) & (self.d < 0.02)
            self.col[m] = couleur
            self.plat[m] = plat
            return self
        if mode == "creux":
            self.d = np.maximum(self.d, -dp)
            return self
        neuf = smin(self.d, dp, fondu)
        # La couleur du volume ajouté gagne là où il est le plus proche.
        m = (dp <= self.d + fondu * 0.25) & (dp < 0.03)
        self.col[m] = couleur
        self.plat[m] = plat
        self.d = neuf
        return self

    # -- volumes
    def boule(self, centre, rayons, couleur, rot=None, mode="ajout", fondu=0.03, plat=False):
        p = self._coords(centre, rot)
        r = np.array(rayons, dtype=np.float32)
        k0 = np.linalg.norm(p / r, axis=-1)
        k1 = np.linalg.norm(p / (r * r), axis=-1) + 1e-6
        return self._ajouter(k0 * (k0 - 1.0) / k1, couleur, mode, fondu, plat)

    def cone(self, a, b, ra, rb, couleur, mode="ajout", fondu=0.03, plat=False):
        """Cône arrondi de a (rayon ra) à b (rayon rb) : pattes, queues, cornes."""
        s = self.s
        a = np.array(a, dtype=np.float32)
        b = np.array(b, dtype=np.float32)
        ab = b - a
        l2 = float(ab @ ab) + 1e-9
        px, py, pz = s.X - a[0], s.Y - a[1], s.Z - a[2]
        t = np.clip((px * ab[0] + py * ab[1] + pz * ab[2]) / l2, 0.0, 1.0)
        qx, qy, qz = px - ab[0] * t, py - ab[1] * t, pz - ab[2] * t
        d = np.sqrt(qx * qx + qy * qy + qz * qz) - (ra + (rb - ra) * t)
        return self._ajouter(d, couleur, mode, fondu, plat)

    def courbe(self, points, rayons, couleur, mode="ajout", fondu=0.03, plat=False):
        """Suite de cônes : queue en mèche, trompe, cou…"""
        for i in range(len(points) - 1):
            self.cone(points[i], points[i + 1], rayons[i], rayons[i + 1], couleur, mode, fondu if i == 0 else 0.02, plat)
        return self

    def boite(self, centre, demi, couleur, arrondi=0.02, rot=None, mode="ajout", fondu=0.03, plat=False):
        p = self._coords(centre, rot)
        q = np.abs(p) - (np.array(demi, dtype=np.float32) - arrondi)
        d = np.linalg.norm(np.maximum(q, 0.0), axis=-1) + np.minimum(q.max(axis=-1), 0.0) - arrondi
        return self._ajouter(d, couleur, mode, fondu, plat)

    def oeil(self, centre, rayon, regard=(0, 0, -1), iris=None):
        """Gros oeil brillant : globe sombre (ou iris coloré) + deux reflets."""
        self.boule(centre, (rayon, rayon * 1.12, rayon * 0.75), iris or NOIR_OEIL, fondu=0.0, plat=True)
        if iris:
            g = np.array(regard, dtype=np.float32)
            self.boule(np.array(centre) + g * rayon * 0.5, (rayon * 0.55, rayon * 0.6, rayon * 0.4), NOIR_OEIL, mode="peint", plat=True)
        g = np.array(regard, dtype=np.float32)
        hx = np.array(centre) + g * rayon * 0.6 + np.array([-rayon * 0.35, rayon * 0.4, 0])
        self.boule(hx, (rayon * 0.32,) * 3, BLANC, mode="peint", plat=True)
        hx2 = np.array(centre) + g * rayon * 0.6 + np.array([rayon * 0.3, -rayon * 0.35, 0])
        self.boule(hx2, (rayon * 0.15,) * 3, BLANC, mode="peint", plat=True)
        return self


# ---------------------------------------------------------------- sculpteur

class Sculpteur:
    def __init__(self, nom: str, res: int = 96, style: str = "arrondi"):
        self.nom = nom
        self.res = res
        self.style = style  # "cubes" ou "arrondi" (arrondi léger)
        self.vox = 1.0 / res
        c = (np.arange(res, dtype=np.float32) + 0.5) / res - 0.5
        self.X, self.Y, self.Z = np.meshgrid(c, c, c, indexing="ij")
        self.membres: list[Membre] = []

    def membre(self, nom, role=None, joint=(0, 0, 0), cote=0, phase=0.0, parent=None) -> Membre:
        m = Membre(self, nom, role, joint, cote, phase, parent)
        self.membres.append(m)
        return m

    # ------------------------------------------------------------ ombrage
    def peindre(self, lumiere=(-0.45, 0.8, -0.55), grain=0.045, seed=1):
        """Ombrage pixel art : 3 tons par couleur selon la lumière, tramage
        de Bayer aux transitions, léger grain par voxel."""
        rng = np.random.default_rng(seed)
        union = np.min(np.stack([m.d for m in self.membres]), axis=0)
        g = np.stack(np.gradient(union), axis=-1)
        n = g / (np.linalg.norm(g, axis=-1, keepdims=True) + 1e-6)
        L = np.array(lumiere, dtype=np.float32)
        L /= np.linalg.norm(L)
        lum = 0.5 + 0.5 * (n @ L)
        # Occlusion simple : le bas et les creux sont un peu plus sombres.
        lum -= 0.10 * np.clip(-self.Y - 0.25, 0, 1) * 2
        I, J, K = np.indices(union.shape)
        seuil = BAYER[(I + K) % 4, J % 4] * 0.12 - 0.06
        t = lum + seuil
        ombre = t < 0.45
        clair = t > 0.76
        bruit = 1.0 + rng.uniform(-grain, grain, union.shape).astype(np.float32)
        froid = np.array([70, 55, 135], dtype=np.float32)
        chaud = np.array([255, 246, 215], dtype=np.float32)
        for m in self.membres:
            c = m.col.copy()
            sh = ombre & ~m.plat
            li = clair & ~m.plat
            c[sh] = c[sh] * 0.70 * 0.82 + froid * 0.18
            c[li] = np.minimum(c[li] * 1.10 * 0.8 + chaud * 0.2, 255)
            nb = ~m.plat
            c[nb] *= bruit[nb][:, None]
            m.couleur = np.clip(c, 0, 255).astype(np.uint8)

    # ------------------------------------------------------------ maillage
    def _faces(self, occ, couleur):
        """Faces visibles des voxels pleins : (coins (F,4,3), couleurs (F,3))."""
        n = self.res
        pad = np.pad(occ, 1)
        quads, cols = [], []
        # (axe, signe) -> coins unitaires d'une face
        coins = {
            (0, -1): [(0, 0, 0), (0, 0, 1), (0, 1, 1), (0, 1, 0)],
            (0, 1): [(1, 0, 0), (1, 1, 0), (1, 1, 1), (1, 0, 1)],
            (1, -1): [(0, 0, 0), (1, 0, 0), (1, 0, 1), (0, 0, 1)],
            (1, 1): [(0, 1, 0), (0, 1, 1), (1, 1, 1), (1, 1, 0)],
            (2, -1): [(0, 0, 0), (0, 1, 0), (1, 1, 0), (1, 0, 0)],
            (2, 1): [(0, 0, 1), (1, 0, 1), (1, 1, 1), (0, 1, 1)],
        }
        for (ax, sg), cc in coins.items():
            sl = [slice(1, n + 1)] * 3
            sl[ax] = slice(1 + sg, n + 1 + sg)
            visible = occ & ~pad[tuple(sl)]
            idx = np.argwhere(visible)
            if len(idx) == 0:
                continue
            quads.append(idx[:, None, :] + np.array(cc)[None, :, :])
            cols.append(couleur[visible])
        return np.concatenate(quads), np.concatenate(cols)

    def _maillage(self, occ, couleur, lissage=None):
        q, c = self._faces(occ, couleur)
        cle = q.reshape(-1, 3)
        uniq, inv = np.unique(cle, axis=0, return_inverse=True)
        inv = inv.reshape(-1, 4)
        v = uniq.astype(np.float32)
        if (lissage is None and self.style == "arrondi") or (lissage and lissage > 0):
            # Arrondi léger : chaque sommet glisse vers la moyenne de ses voisins.
            # Les marches entre cubes s'adoucissent, les couleurs restent par face.
            force = 0.55 if lissage is None else lissage
            a = inv.reshape(-1)
            b = np.roll(inv, -1, axis=1).reshape(-1)
            for _ in range(2):
                somme = np.zeros_like(v)
                nb = np.zeros(len(v), dtype=np.float32)
                np.add.at(somme, a, v[b]); np.add.at(nb, a, 1)
                np.add.at(somme, b, v[a]); np.add.at(nb, b, 1)
                v = v + force * (somme / nb[:, None] - v)
        v = v * self.vox - 0.5
        return v, inv, c

    # ------------------------------------------------------------ rendu
    def _rendu(self, maillages, taille=520, lacet=-32.0, tangage=-18.0, fond=(246, 248, 255), zoom=0.86, sol=0.0):
        """Rend une liste de (sommets, quads, couleurs) en image PIL :
        z-buffer par échantillonnage des quads, contour cartoon, ombre au sol."""
        v = np.concatenate([m[0] for m in maillages])
        decal = np.cumsum([0] + [len(m[0]) for m in maillages[:-1]])
        f = np.concatenate([m[1] + d for m, d in zip(maillages, decal)])
        c = np.concatenate([m[2] for m in maillages])
        ry, rx = math.radians(lacet), math.radians(tangage)
        Ry = np.array([[math.cos(ry), 0, math.sin(ry)], [0, 1, 0], [-math.sin(ry), 0, math.cos(ry)]])
        Rx = np.array([[1, 0, 0], [0, math.cos(rx), -math.sin(rx)], [0, math.sin(rx), math.cos(rx)]])
        p = v @ (Rx @ Ry).T
        echelle = taille * zoom
        sx = p[:, 0] * echelle + taille / 2
        sy = -p[:, 1] * echelle + taille / 2 + taille * 0.02
        sz = p[:, 2]
        k = 7
        u = (np.arange(k) + 0.5) / k
        U, V = np.meshgrid(u, u)
        U, V = U.ravel(), V.ravel()
        w = np.stack([(1 - U) * (1 - V), U * (1 - V), U * V, (1 - U) * V], axis=1)
        X = (w @ sx[f].T).T.ravel()
        Y = (w @ sy[f].T).T.ravel()
        Zs = (w @ sz[f].T).T.ravel()
        C = np.repeat(c, k * k, axis=0)
        xi, yi = X.astype(np.int32), Y.astype(np.int32)
        ok = (xi >= 0) & (xi < taille) & (yi >= 0) & (yi < taille)
        xi, yi, Zs, C = xi[ok], yi[ok], Zs[ok], C[ok]
        ordre = np.argsort(-Zs, kind="stable")  # du plus loin au plus proche
        img = np.zeros((taille, taille, 3), dtype=np.float32)
        prof = np.full((taille, taille), np.inf, dtype=np.float32)
        img[yi[ordre], xi[ordre]] = C[ordre]
        prof[yi[ordre], xi[ordre]] = Zs[ordre]
        masque = np.isfinite(prof)
        bord = np.zeros_like(masque)
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1), (2, 0), (-2, 0), (0, 2), (0, -2)):
            m2 = np.roll(np.roll(masque, dy, 0), dx, 1)
            p2 = np.roll(np.roll(prof, dy, 0), dx, 1)
            with np.errstate(invalid="ignore"):
                bord |= (~masque & m2) | (masque & m2 & (p2 - prof > 0.06))
        out = np.empty_like(img)
        out[:] = np.array(fond, dtype=np.float32)
        out[masque] = img[masque]
        out[bord] = CONTOUR
        im = Image.fromarray(out.astype(np.uint8))
        # Ombre portée au sol (rétrécit quand la créature saute).
        ombre = Image.new("L", im.size, 0)
        dd = ImageDraw.Draw(ombre)
        pied = 0.5 * echelle * math.cos(rx) + taille / 2 + taille * 0.02
        lg = 0.3 / (1 + sol * 4)
        dd.ellipse([taille * (0.5 - lg), pied - taille * 0.035, taille * (0.5 + lg), pied + taille * 0.035], fill=int(70 / (1 + sol * 3)))
        ombre = ombre.filter(ImageFilter.GaussianBlur(8))
        sombre = Image.new("RGB", im.size, (200, 205, 225))
        fond_img = Image.new("RGB", im.size, fond)
        fond_img = Image.composite(sombre, fond_img, ombre)
        fond_img.paste(im, (0, 0), Image.fromarray(((masque | bord) * 255).astype(np.uint8)))
        return fond_img

    def apercu(self, chemin, taille=520, lacet=-32.0, tangage=-18.0, fond=(246, 248, 255), zoom=0.86):
        union_occ = np.zeros((self.res,) * 3, dtype=bool)
        couleur = np.zeros((self.res,) * 3 + (3,), dtype=np.uint8)
        for m in self.membres:
            occ = m.d < 0
            couleur[occ] = m.couleur[occ]
            union_occ |= occ
        im = self._rendu([self._maillage(union_occ, couleur)], taille, lacet, tangage, fond, zoom)
        os.makedirs(os.path.dirname(chemin) or ".", exist_ok=True)
        im.save(chemin)
        return chemin

    # ------------------------------------------------------------ animation
    def _parent(self, m):
        if m.parent:
            return m.parent
        if m.role in ("Oreille", "Antenne", "Machoire", "Corne"):
            return "Tete" if any(x.nom == "Tete" for x in self.membres) else None
        return None

    def animer(self, chemin, anim, images=24, duree=1.0, taille=360, lacet=-32.0, tangage=-14.0, zoom=0.72, bande=None):
        """GIF d'une animation. `anim` : nom d'une pose auto (voir animations.py)
        ou fonction (sculpteur, t dans [0, 1[) -> {membre: (rot°, translation)}."""
        import animations
        if not hasattr(self, "_mailles"):
            self._mailles = {}
            for m in self.membres:
                occ = m.d < 0
                if occ.any():
                    self._mailles[m.nom] = self._maillage(occ, m.couleur)
        par_nom = {m.nom: m for m in self.membres}
        fonction = anim if callable(anim) else animations.POSES[anim]
        frames = []
        for i in range(images):
            t = i / images
            pose = fonction(self, t)
            racine = pose.get("racine", ((0, 0, 0), (0, 0, 0)))

            def monde(nom, v):
                # Transformations du membre puis de ses parents puis de la racine.
                while nom:
                    m = par_nom[nom]
                    rot, tr = pose.get(nom, ((0, 0, 0), (0, 0, 0)))
                    j = np.array(m.joint, dtype=np.float32)
                    v = (v - j) @ _rot(rot).T + j + np.array(tr, dtype=np.float32)
                    nom = self._parent(m)
                pivot = np.array([0, -0.5, 0], dtype=np.float32)
                return (v - pivot) @ _rot(racine[0]).T + pivot + np.array(racine[1], dtype=np.float32)

            liste = [(monde(n, v), f, c) for n, (v, f, c) in self._mailles.items()]
            frames.append(self._rendu(liste, taille, lacet, tangage, zoom=zoom, sol=max(0.0, racine[1][1])))
        os.makedirs(os.path.dirname(chemin) or ".", exist_ok=True)
        if bande:  # planche de contrôle : 8 images de l'animation côte à côte
            sel = frames[:: max(1, images // 8)][:8]
            pl = Image.new("RGB", (taille * len(sel), taille))
            for i, fr in enumerate(sel):
                pl.paste(fr, (i * taille, 0))
            pl.save(bande)
        frames[0].save(chemin, save_all=True, append_images=frames[1:], duration=int(1000 * duree / images), loop=0, disposal=2)
        return chemin

    # ------------------------------------------------------------ export
    def exporter(self, dossier):
        """OBJ + MTL + palette PNG (un objet par membre) et manifeste JSON."""
        os.makedirs(dossier, exist_ok=True)
        lots = []
        toutes = []
        for m in self.membres:
            occ = m.d < 0
            if not occ.any():
                continue
            v, f, c = self._maillage(occ, m.couleur)
            lots.append((m, v, f, c))
            toutes.append(c)
        pal, inv_pal = np.unique(np.concatenate(toutes), axis=0, return_inverse=True)
        cote = int(math.ceil(math.sqrt(len(pal))))
        tex = np.zeros((cote, cote, 3), dtype=np.uint8)
        tex.reshape(-1, 3)[: len(pal)] = pal
        Image.fromarray(tex).save(os.path.join(dossier, "palette.png"))
        with open(os.path.join(dossier, f"{self.nom}.mtl"), "w") as fm:
            fm.write("newmtl palette\nKd 1 1 1\nmap_Kd palette.png\n")
        manifeste = {"nom": self.nom, "membres": []}
        base_v = 1
        base_vt = 1
        debut = 0
        with open(os.path.join(dossier, f"{self.nom}.obj"), "w") as fo:
            fo.write(f"mtllib {self.nom}.mtl\n")
            for m, v, f, c in lots:
                ids = inv_pal[debut : debut + len(c)].ravel()
                debut += len(c)
                fo.write(f"o {m.nom}\nusemtl palette\n")
                # Roblox : avant vers -z, on garde le repère tel quel.
                fo.write("".join(f"v {x:.5f} {y:.5f} {z:.5f}\n" for x, y, z in v))
                uvx = ((ids % cote) + 0.5) / cote
                uvy = 1.0 - ((ids // cote) + 0.5) / cote
                fo.write("".join(f"vt {a:.5f} {b:.5f}\n" for a, b in zip(uvx, uvy)))
                fv = f + base_v
                vt = np.arange(len(f)) + base_vt
                fo.write("".join(
                    f"f {a}/{t} {b}/{t} {c_}/{t}\nf {a}/{t} {c_}/{t} {d}/{t}\n"
                    for (a, b, c_, d), t in zip(fv, vt)
                ))
                manifeste["membres"].append({
                    "nom": m.nom, "role": m.role, "joint": list(m.joint), "cote": m.cote,
                    "phase": m.phase, "triangles": int(len(f) * 2),
                })
                base_v += len(v)
                base_vt += len(f)
        with open(os.path.join(dossier, "manifeste.json"), "w") as fj:
            json.dump(manifeste, fj, ensure_ascii=False, indent=1)
        return manifeste
