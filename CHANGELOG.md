# Journal des modifications

Chaque mise à jour du jeu ajoute ici une section datée (agent Contexte).

## 2026-11-08 — Peaufinage interface et effets (issue #15)
- Nouveau module pur `Shared/Style` (couleurs, dégradé des jauges, recharges, file de bandeaux) et fabrique client `Habillage` (textes, boutons, jauges, rebonds, nombres flottants).
- Toute l'interface en police ronde FredokaOne avec contour noir épais ; gros boutons colorés qui rebondissent (LANCER vert, PLAQUER orange, Force rouge, Vitesse bleu, pièges à leur couleur).
- Jauge de lancer en dégradé continu ; nouvelles barres de recharge pour PLAQUER, les pièges et le verrou de base.
- Messages du serveur et « VOLÉ ! » dans un bandeau unique qui glisse en haut de l'écran, un message à la fois.
- Un seul « BOUM ! » au plaquage (gros, blanc, rebondissant) : celui du serveur est caché côté client.
- Panneaux des créatures (couleur de rareté, revenu en base) et des monstres (couleur du danger) agrandis et plus lisibles ; « Récolter », « Voler » et « Verrouiller » en gros boutons avec jauge de maintien.
- Aucune règle ni valeur de `Config` modifiée, aucun fichier serveur touché.

## 2026-11-08 — Correctif typage des pièges (issue #13)
- `src/server/Pieges.luau` : conversions explicites après les vérifications de nil (`BasePart?`, `Humanoid?`) pour que luau-lsp passe en CI.

## 2026-11-08 — Pièges (issue #13)
- Trois pièges à poser dans les Terres Sauvages : Filet (immobilise 3 s), Flaque de glu (ralentit ×0,3 tant qu'on est dedans), Fausse graine (ressemble à une créature « Récolter » ; immobilise 2 s).
- Prix en pièces, 3 pièges actifs max par joueur, 5 s entre deux poses, 90 s de durée de vie, 4 s de protection après un effet ; pose interdite dans les bases et trop près d'un autre piège.
- Tout est décidé par le serveur (nouveau module `Pieges`, logique pure `Piege`) ; le client n'envoie que le nom du type via `PoserPiege`.
- Le poseur n'est jamais affecté par ses pièges ; une victime garde la créature qu'elle porte.
- Trois gros boutons à gauche de l'écran (touches Z/X/C, croix directionnelle à la manette) et « PIÉGÉ ! » au centre pendant l'immobilisation.

## 2026-11-08 — Correctif tests en jeu des raids (issue #11)
- La créature volée est désormais portée dans le personnage du voleur (et oubliée proprement si ce personnage est détruit).

## 2026-11-08 — Correctif typage CI (issue #11)
- Corrige les erreurs luau-lsp (valeurs possiblement nil) dans InterfaceRaid, Bases, Portage et Raids, sans changement de comportement.

## 2026-11-08 — Raids de bases (issue #11)
- Action « Voler » (ProximityPrompt, E / ButtonX, bouton tactile) sur chaque créature exposée d'une autre base : la créature quitte la base de la victime (sauvegarde et revenus compris) et passe en portage chez le voleur, à déposer dans sa propre base. Impossible si le voleur porte déjà une créature.
- Alerte cartoon « VOLÉ ! » (billboard rebondissant au-dessus du voleur, message à l'écran pour la victime et le voleur, RemoteEvent `AlerteVol`).
- Une créature volée se comporte comme une créature récoltée : lâchée et libre si le voleur est plaqué ou frappé par un monstre.
- Porte en arche, bouton « Verrouiller » (R / ButtonB, 100 pièces) et bouclier rouge : verrou de 60 s qui replace les intrus devant la porte, puis 60 s de recharge ; panneau et compteur à l'écran.
- Tout est vérifié par le serveur (`Raids`, logique pure dans `Raid`).

## 2026-11-08 — Correctif typage CI (issue #9)
- Typage strict corrigé dans Monstres (serveur, effet « PAF ! ») : la pièce support est explicitement typée BasePart pour luau-lsp. Aucun changement de comportement.

## 2026-11-08 — Monstres (issue #9)
- Monstres cartoon dans les Terres Sauvages : Gloupinou (Proche), Ronchonbulle (Moyenne), Grobidou (Lointaine), plus nombreux, rapides et forts en s'éloignant ; vitesse toujours inférieure à celle d'un joueur entraîné.
- Ils poursuivent le joueur valide le plus proche (hors base, non protégé), sinon errent dans leur zone ; ils n'entrent jamais dans une base et rentrent chez eux s'ils s'éloignent trop.
- Coup : dégâts selon la zone, la créature portée tombe à 4 studs (libre, récoltable par tous), « PAF ! », puis 3 s de protection.
- Cycle jour/nuit (4 min / 2 min) : nuit bleu-violet, yeux des monstres brillants, vagues plus nombreuses ; messages « La nuit tombe… » et « Le jour se lève ! ».
- `Portage.lacher` (utilisé par le plaquage et les monstres). Aucun nouveau RemoteEvent.

## 2026-11-08 — Correctif typage CI (issue #7)
- Typage strict corrigé dans InterfacePlaquage (client) et Plaquages (serveur) : valeurs optionnelles explicitement vérifiées pour luau-lsp. Aucun changement de comportement.

## 2026-11-08 — Plaquage (issue #7)
- Gros bouton rond « PLAQUER ! » en bas à droite (tactile), touche F au clavier et Y à la manette ; le serveur choisit la cible (porteur valide le plus proche, 8 studs max).
- La cible lâche sa créature à 4 studs (côté opposé au plaqueur) : elle devient « libre », récoltable par n'importe qui, et disparaît après 60 s si personne ne la prend.
- La cible tombe au sol 1,5 s (« BOUM ! » et étoiles qui tournent au-dessus de la tête), puis est protégée 4 s ; le plaqueur attend 6 s avant le prochain plaquage (compte à rebours sur le bouton).
- Pas de plaquage depuis sa propre base, ni d'une cible dans sa propre base ; anti-spam des requêtes (0,2 s).

## 2026-11-08 — Correctif chargement des tests en jeu (issue #5)
- `tests/en-jeu/C7_portage.luau` ne compilait pas dans Roblox (« Ambiguous syntax » ligne 175 : une instruction commençant par `(` après un appel). Ajout d'un `;` séparateur, sans changement de logique du test.

## 2026-11-08 — Correctif typage Portage, suite (issue #5)
- Corrige la dernière erreur luau-lsp de `src/server/Portage.luau` (ligne 157 : `PrimaryPart` typé `BasePart?` dans la soudure), sans changement de comportement.

## 2026-11-08 — Correctif typage Portage (issue #5)
- Corrige les erreurs luau-lsp de `src/server/Portage.luau` (conversions `BasePart?`, `Portee?`, rareté `string`), sans changement de comportement.

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
