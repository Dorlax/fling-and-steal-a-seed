# État du jeu

> Tenu à jour par l'agent Contexte après chaque demande terminée (résumé, 60 lignes max).

## Base et progression
- Chaque joueur a une base avec une Forge (mode Force ou Vitesse), entraînement AFK, stats sauvegardées (DataStore `JoueursV1`). [[01 Forge et stats]]
- La Vitesse change la vitesse de course ; porter une créature la réduit (× 0,8).
- Pièces et créatures de la base sauvegardées ; revenus par seconde selon la rareté (1/3/10/30/100).

## Lancer et raretés
- Lancer une graine avec jauge de timing (Force + bonus de jauge) vers les Terres Sauvages ; zones Proche / Moyenne / Lointaine ; taux de rareté du Plan affichés. [[02 Lancer et raretés]]
- Les créatures atterrissent au sol (max 10), récoltables ; elles disparaissent si on les laisse.

## Porter et revenus
- Récolter (ProximityPrompt, 10 studs), porter, déposer automatiquement dans sa base (10 emplacements, « Base pleine ! »). [[03 Porter et revenus]]
- Compteur de pièces, « +N » flottant, « +X / s » ; une créature portée retombe à la mort.

## Interactions
- Plaquage : bouton PLAQUER (F / Y), portée 8, délai 6 s, protection 4 s ; le porteur lâche sa créature, libre pour tous ; refusé dans les bases. [[04 Plaquage]]
- Monstres comiques par zone (Gloupinou, Ronchonbulle, Grobidou), jamais dans une base ; leur coup fait lâcher la créature ; cycle jour/nuit avec vagues de nuit. [[05 Monstres]]
- Raids : voler une créature exposée dans la base d'un autre ; verrou de base de 60 s (100 pièces) avec bouclier et décompte. [[06 Raids de bases]]
- Pièges : filet, glu, fausse graine (coût en pièces, nombre limité, protection après piégeage, pas dans les bases). [[07 Pièges]]

## Décor et ambiance
- Décor cartoon généré par le serveur (`Decor`) : éclairage coloré (atmosphère, saturation, éclat), place de sable sous les bases, chemins devant les portes, arbres (dont roses et dorés), rochers, champignons, fleurs, nuages, collines de bordure.
- Bases ornées : bordure colorée (sans collision) et lampadaires-sucettes ; sol vert vif.
- Bestiaire en blocs (`Shared.Bestiaire`, construit par `Modeleur`) : une espèce de créature par rareté (Poussigraine, Lapinou, Renardelle, Cerfaurore, Dragonnet) ; deux monstres par zone (Gloupinou/Piquerelle, Ronchonbulle/Croquelune, Grobidou/Brasaurus). Le `Corps` reste la racine invisible (taille et règles inchangées).
- Auras de rareté : étincelles dès Épique, halo arc-en-ciel en Mythique.
- Finition : ombrage automatique en 3 tons des gros blocs (bande sombre, dessus clair), détails par espèce (griffes, dents, rayures…), contours cartoon (Highlight) sur les 20 modèles les plus proches.
- Animations client (`Animations`, calculs dans `Shared.Anime`) : sautillement des créatures, dandinement des monstres, pattes qui marchent, ailes, queues, oreilles, coup de bras/mâchoire quand un monstre frappe (attribut `FrappeA`).
- Interface : boutons de pièges en rangée en bas à gauche (ne recouvrent plus les stats).

## À faire
- Passes Robux (x2 Force, x2 Vitesse, x2 Pièces, Ramassage auto), cosmétiques.
- Test du cycle jour/nuit à la main (vérifié seulement par les tests automatiques).
