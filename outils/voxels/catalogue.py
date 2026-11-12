"""Toutes les espèces sculptées (créatures et monstres), par nom."""

import importlib

import especes
import monstres

LOTS = ["monstres_lot1", "monstres_lot2", "monstres_lot3", "monstres_lot4", "monstres_lot5"]

TOUT = {**especes.ESPECES, **monstres.MONSTRES}
MONSTRES_BIOMES = {}
for _nom in LOTS:
    try:
        _m = importlib.import_module(_nom)
    except ModuleNotFoundError as e:
        if e.name != _nom:
            raise
        continue
    MONSTRES_BIOMES.update(_m.MONSTRES)
TOUT.update(MONSTRES_BIOMES)
