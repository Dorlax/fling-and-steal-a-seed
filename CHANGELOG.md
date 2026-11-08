# Journal des modifications

Chaque mise à jour du jeu ajoute ici une section datée (agent Contexte).

## 2026-11-08 — Porter et revenus (issue #5)
- Bouton « Récolter » (ProximityPrompt, maintien 0,5 s, 10 studs) sur chaque créature : seul son propriétaire peut la récolter, vérifié par le serveur.
- La créature portée flotte au-dessus de la tête ; le joueur marche à 80 % de sa vitesse.
- Dépôt automatique en entrant dans sa base (10 emplacements, « Base pleine ! » au-delà) ; les créatures s'affichent en rangées avec « +N/s ».
- Revenus chaque seconde : Commune 1, Rare 3, Épique 10, Légendaire 30, Mythique 100 pièces/s.
- Compteur de pièces en haut au centre, « +N » flottant, ligne « +X / s », messages du serveur.
- Mort en portant : la créature retombe au sol et reste récoltable ; une créature portée n'est plus retirée par la limite de 10 au sol.
- Pièces et créatures de la base sauvegardées (DataStore), nettoyées au chargement.

## 2026-11-08 — Lancer et raretés (issue #3)
- Bouton LANCER (souris, toucher, manette R2, touche F) : 1er appui = jauge de timing, 2e appui = lâcher.
- Distance = 30 + 0,4 × Force + bonus de jauge (0 / 15 / 35 / 60, « PERFECT ! » en haut), plafond 520 studs.
- Terres Sauvages devant les bases, avec bornes des zones Proche / Moyenne (150) / Lointaine (300).
- Une graine vole jusqu'au point d'atterrissage et une créature y pousse ; rareté tirée par le serveur selon la zone, aux taux du Plan.
- Panneau « Taux de rareté » toujours visible ; 10 créatures au sol max par joueur, retirées à son départ.
- Tout est calculé côté serveur (délai de 3 s entre lancers, ping compensé au plus de 0,25 s) ; les arguments du client sont ignorés.

## 2026-11-07 — Correctif CI (RemoteEvent ChoisirModeForge absent en test)
- Le RemoteEvent `ChoisirModeForge` est déclaré dans `default.project.json` : il existe dès le chargement de la place, même quand les Scripts ne tournent pas (tests Open Cloud). `Principal.server.luau` réutilise l'instance existante.

## 2026-11-07 — Correctif CI (dossier build manquant)
- Le dossier `build/` est maintenant présent dans le dépôt (`build/.gitkeep`) : `rojo build … -o build/jeu.rbxl` ne plante plus en CI. Son contenu généré reste ignoré.

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
