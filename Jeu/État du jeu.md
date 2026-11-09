# État du jeu

> Tenu à jour par l'agent Contexte après chaque demande terminée (résumé, 60 lignes max).

## Base et progression
- Chaque joueur a une base avec une Forge (mode Force ou Vitesse), entraînement AFK, stats sauvegardées (DataStore `JoueursV1`). [[01 Forge et stats]]
- La Vitesse change la vitesse de course ; porter une créature la réduit (× 0,8).
- Pièces et créatures de la base sauvegardées ; revenus par seconde selon la rareté (1/3/10/30/100).

## Biomes et progression
- Les Terres Sauvages sont une route de biomes de 600 studs (`Shared.Biomes`) : 1 Prairie Pétillante, 2 Bois Moussu, 3 Dunes Dorées, 4 Glacier Givré, 5 Volcan Ardent, 6 Galaxie Étoilée, 7 Marais Brumeux, 8 Récif Corail, 9 Royaume Bonbon. Chaque biome garde Proche / Moyenne / Lointaine et les taux du Plan ; sol, arche d'entrée, décor en blocs et ambiance (client `Ambiances`) propres.
- Valeur des créatures × 1,5 par biome (espèce -> biome) ; chaque biome a 2 créatures par rareté et 1 monstre par sous-zone (un fichier `Especes<Biome>` par biome).
- Monstres plus rapides à chaque biome (`Monstre.vitesse`) : biome 1 = vitesse de Config ; ensuite vitesse d'un joueur au seuil du biome × 0,9 / 1,05 / 1,2 (Proche / Moyenne / Lointaine).
- Monstres seulement dans les biomes où il y a un joueur (et le biome 1), 12 au plus par biome la nuit.
- Force et Vitesse sans limite : linéaires jusqu'à 1 000, puis chaque doublement = un biome de plus au lancer / +20 de vitesse ; aucune limite réelle (PlafondStat 1e300, WalkSpeedMax 1e9).
- Niveaux de Forge achetés en pièces (bouton sous les stats, RemoteEvent `AmeliorerForge`) : gain × 1,6 par niveau, coût 100 × 1,9^(n-1) ; sauvegardés (`NiveauForge`).
- Grands nombres raccourcis (`Shared.Nombres` : 1,23 M, 4,5 T).

## Lancer et raretés
- Lancer une graine avec jauge de timing (Force + bonus de jauge) vers les Terres Sauvages ; zones Proche / Moyenne / Lointaine ; taux de rareté du Plan affichés. [[02 Lancer et raretés]]
- Les créatures atterrissent au sol (max 10), récoltables ; elles disparaissent si on les laisse.

## Tailles des créatures
- Taille tirée par le serveur à la pousse (taux affichés au lancer) : Normale 60 %, Grande 25 %, Géante 10 %, Colossale 4 %, Titan 1 % au biome 1, puis grosses tailles plus fréquentes à chaque biome (poids × (1 + 0,2 × (biome - 1))^(rang - 1), ex. biome 6 : 30/25/20/16/8 %) ; taux du biome atteint affichés au lancer ; échelle ×1 à ×2,8, revenu ×1, ×2, ×4, ×8, ×20 (`Config.Tailles`).
- Fiche de créature sauvegardée « Rarete[:Taille[:Espece]] » (`Shared.Fiche`) ; les anciennes sauvegardes (rareté seule) restent valides (taille Normale).
- La créature pousse depuis la graine (croissance animée de 0,7 s, récolte possible ensuite).

## Porter et revenus
- Bases façon vitrine : un socle numéroté par emplacement, liseré lumineux à la couleur de la rareté posée ; les créatures trônent dessus.
- Étages de base (`Config.Bases`) : jusqu'à 3 étages, 10 socles chacun ; étage 2 = 2 500 pièces, étage 3 = 150 000 (bouton sous les stats, RemoteEvent `AcheterEtage`, sauvegardé `Etages`) ; plancher, garde-corps, ascenseurs (plaques lumineuses, touche G) ; raids possibles à tous les étages.
- Agrandissements de base (`Config.Bases.Tailles`) : sol 40, 56 puis 72 studs (6 000 puis 250 000 pièces, RemoteEvent `AgrandirBase`, sauvegardé `Agrandissement`) ; bord avant toujours à Z = 20 ; socles plus espacés ; créatures exposées à leur vraie taille jusqu'à × 1,3 / 2,1 / 2,8 selon le niveau. Bases espacées de 90 studs, monde élargi à 1 200 studs.
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
- Bestiaire en blocs (`Shared.Bestiaire`, construit par `Modeleur`) : deux espèces de créature par rareté (Poussigraine/Champichou, Lapinou/Tortipousse, Renardelle/Hibouflor, Cerfaurore/Lionfeuille, Dragonnet/Phenigraine), tirées au hasard ; deux monstres par zone (Gloupinou/Piquerelle, Ronchonbulle/Croquelune, Grobidou/Brasaurus). Le `Corps` reste la racine invisible (taille et règles inchangées).
- Auras de rareté : étincelles dès Épique, halo arc-en-ciel en Mythique.
- Finition : ombrage automatique en 3 tons des gros blocs (bande sombre, dessus clair), détails par espèce (griffes, dents, rayures…), contours cartoon (Highlight) sur les 20 modèles les plus proches.
- Textures pixel-art 16×16 (Pelage, Écailles, Gelée) teintées par la couleur de chaque gros bloc (`Bestiaire.Textures`, images du compte du propriétaire).
- Animations client (`Animations`, calculs dans `Shared.Anime`) : sautillement des créatures, dandinement des monstres, pattes qui marchent, ailes, queues, oreilles, coup de bras/mâchoire quand un monstre frappe (attribut `FrappeA`).
- Interface : boutons de pièges en rangée en bas à gauche (ne recouvrent plus les stats).

## À faire
- Passes Robux (x2 Force, x2 Vitesse, x2 Pièces, Ramassage auto), cosmétiques.
- Test du cycle jour/nuit à la main (vérifié seulement par les tests automatiques).
