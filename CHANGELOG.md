# Journal des modifications

Chaque mise à jour du jeu ajoute ici une section datée (agent Contexte).

## 2026-11-07 — Correctif CI (erreurs de typage du code)
- InterfaceStats : table des boutons typée `{ [string]: TextButton }`.
- Sauvegarde, Bases : raffinements explicites des valeurs optionnelles (DataStore, emplacement, Forge, personnage).
- Forge, Donnees : `require` côté Lune casté en `any` pour que luau-lsp ne tente pas de le résoudre.

## 2026-11-07 — Correctif CI (typage luau-lsp)
- Définitions `globalTypes.d.luau` épinglées sur luau-lsp 1.32.0 (version de rokit.toml) au lieu de `main`, devenue incompatible.

## 2026-11-07 — Forge et stats (issue #1)
- Chaque joueur reçoit une base avec une Forge (modes Force / Vitesse).
- Debout sur sa Forge, la stat du mode actif monte de 1 par seconde (AFK compris), plafond 1000.
- La Vitesse augmente la vitesse de course (16 → 36 au plafond, borné à 50).
- Interface : Force, Vitesse, mode actif, indicateur « Entraînement en cours » et boutons de mode.
- Sauvegarde DataStore `JoueursV1` (arrivée, départ, arrêt du serveur, toutes les 60 s).
