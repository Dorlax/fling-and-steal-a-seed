# État du jeu

> Tenu à jour par l'agent Contexte après chaque demande terminée (résumé, 60 lignes max).

## Base et progression
- Chaque joueur a une base avec une Forge (mode Force ou Vitesse), entraînement AFK, stats sauvegardées (DataStore `JoueursV1`). [[01 Forge et stats]]
- La Vitesse change la vitesse de course ; porter une créature la réduit (× 0,8).
- Pièces et créatures de la base sauvegardées ; revenus par seconde selon la rareté (1/3/10/30/100).

## Biomes et progression
- Les Terres Sauvages sont une route de biomes de 600 studs (`Shared.Biomes`) : 1 Prairie Pétillante, 2 Bois Moussu, 3 Dunes Dorées, 4 Glacier Givré, 5 Volcan Ardent, 6 Galaxie Étoilée, 7 Marais Brumeux, 8 Récif Corail, 9 Royaume Bonbon, 10 Jungle Émeraude, 11 Îles Célestes, 12 Manoir Hanté, 13 Savane Dorée, 14 Cité Mécanique, 15 Jardin Zen, 16 Cavernes Lumineuses, 17 Coffre à Jouets, 18 Forêt d'Automne, 19 Ferme Joyeuse, 20 Royaume des Rêves, 21 Plage Soleil. Chaque biome garde Proche / Moyenne / Lointaine et les taux du Plan ; sol, arche d'entrée, décor en blocs et ambiance (client `Ambiances`) propres.
- Valeur des créatures × 1,5 par biome (espèce -> biome) ; chaque biome a 2 créatures par rareté et 1 monstre par sous-zone (un fichier `Especes<Biome>` par biome).
- Monstres plus rapides à chaque biome (`Monstre.vitesse`) : biome 1 = vitesse de Config ; ensuite vitesse d'un joueur au seuil du biome × 0,9 / 1,05 / 1,2 (Proche / Moyenne / Lointaine).
- Monstres seulement dans les biomes où il y a un joueur (et le biome 1), 12 au plus par biome la nuit.
- Force et Vitesse sans limite : linéaires jusqu'à 1 000, puis chaque doublement = un biome de plus au lancer / +20 de vitesse ; aucune limite réelle (PlafondStat 1e300, WalkSpeedMax 1e9).
- Niveaux de Forge achetés en pièces (bouton sous les stats, RemoteEvent `AmeliorerForge`) : gain 1, 2, 5, 10, 20, 50…, coût 100 × 1,9^(n-1) ; sauvegardés (`NiveauForge`).
- Grands nombres raccourcis (`Shared.Nombres` : 1,23 M, 4,5 T… jusqu'à Vg = 1e63, puis « 1,23e75 ») ; pièces plafonnées à 1e300.

## Lancer et raretés
- Lancer une graine avec jauge de timing (Force + bonus de jauge) vers les Terres Sauvages ; zones Proche / Moyenne / Lointaine ; taux de rareté du Plan affichés. [[02 Lancer et raretés]]
- Les créatures atterrissent au sol (max 10), récoltables ; elles disparaissent si on les laisse.

## Tailles des créatures
- Taille tirée par le serveur à la pousse (taux affichés au lancer) : Normale 60 %, Grande 25 %, Géante 10 %, Colossale 4 %, Titan 1 % au biome 1, puis grosses tailles plus fréquentes à chaque biome (poids × (1 + 0,2 × (biome - 1))^(rang - 1), ex. biome 6 : 30/25/20/16/8 %) ; taux du biome atteint affichés au lancer ; échelle ×1 à ×2,8, revenu ×1, ×2, ×4, ×8, ×20 (`Config.Tailles`).
- Fiche de créature sauvegardée « Rarete[:Taille[:Espece]] » (`Shared.Fiche`) ; les anciennes sauvegardes (rareté seule) restent valides (taille Normale).
- La créature pousse depuis la graine (croissance animée de 0,7 s, récolte possible ensuite).

## Porter et revenus
- Créatures libres dans la base : chacune se promène autour de sa place (`Shared.Promenade`, déterministe serveur/client), sauts et pirouettes ; vol vérifié sur sa position calculée. Plus de socles.
- Gestion (bouton « Base », `InterfaceBase`) : vente (2 min de revenu, `VendreCreature`), rangement par valeur (`TrierBase`) ; gains hors ligne 50 % jusqu'à 12 h (`DerniereConnexion`).
- Étages de base (`Config.Bases`) : jusqu'à 3 étages, 10 socles chacun ; étage 2 = 2 500 pièces, étage 3 = 150 000 (bouton sous les stats, RemoteEvent `AcheterEtage`, sauvegardé `Etages`) ; plancher, garde-corps, ascenseurs (plaques lumineuses, touche G) ; raids possibles à tous les étages.
- Agrandissements de base (`Config.Bases.Tailles`) : sol 40, 56 puis 72 studs (6 000 puis 250 000 pièces, RemoteEvent `AgrandirBase`, sauvegardé `Agrandissement`) ; bord avant toujours à Z = 20 ; socles plus espacés ; créatures exposées à leur vraie taille jusqu'à × 1,3 / 2,1 / 2,8 selon le niveau. Bases espacées de 90 studs, monde élargi à 1 200 studs.
- Récolter (ProximityPrompt, 10 studs), porter, déposer automatiquement dans sa base (10 emplacements, « Base pleine ! »). [[03 Porter et revenus]]
- Compteur de pièces, « +N » flottant, « +X / s » ; une créature portée retombe à la mort.

## Passes et Forge double
- Forge évolutive (`MachineForge`, `Config.Forge.Paliers`) : 5 paliers d'agrès selon le niveau (roue/tapis/piste, rocher/haltères/barre/météorite, cordes) ; client `AnimationsForge` anime le personnage (`Shared.PosesForge`, Motor6D.Transform). Gain par niveau : suite 1-2-5 (`Forge.gainPour`).
- Interface : taux de rareté derrière le bouton « % » (haut droite), plus de noms au-dessus des monstres.
- Mode Double de la Forge (`Config.Forge.Double`) : Force et Vitesse ensemble, 60 % chacune, dès le niveau 12 (bouton « Double »).
- Passes Robux (`Config.Passes`, `Shared.Passes`, serveur `PassesRobux`) : × 2 Force, × 2 Vitesse, × 2 Pièces, Ramassage auto ; attributs `Pass<Id>` écrits par le serveur ; onglet « Passes » du Shop (« Bientôt » tant que Id = 0).

## Multijoueur
- Événements de serveur (`Shared.Evenement`, serveur `Evenements`) : un toutes les 8 min pendant 2 min 30, jamais deux fois de suite le même ; Pluie dorée (revenus × 2), Vent porteur (lancers + 300 studs), Graines géantes (taux de taille de 3 biomes plus loin, affichés). Attributs Workspace `Evenement` / `EvenementFin` ; annonce à tous ; pastille en haut à gauche (client `InterfaceEvenement`). Taux de rareté inchangés.
- Record de biome (`RecordBiome`, sauvegardé) battu à chaque lancer plus lointain, annoncé à tout le serveur.
- Classements (`Shared.Classement`, serveur `Classements`) : leaderstats Biome / Revenu/s / Pièces ; bouton « Top » (client `InterfaceClassement`) avec onglets Ce serveur / Monde ; monde via OrderedDataStore `ClassementRevenusV1` (log10 × 1000) et `ClassementBiomesV1`, publié en JSON dans l'attribut `ClassementMonde` de ReplicatedStorage toutes les 2 min.
- Bestiaire à collectionner (`Shared.Collection`, client `InterfaceBestiaire`, bouton « Livre ») : page par biome, aperçus 3D en ViewportFrame, silhouettes des espèces non récoltées ; découvertes sauvegardées (`Decouvertes`) à chaque dépôt d'une nouvelle espèce.
- Effets des espèces (client `EffetsEspeces`, `Shared.Effets`) : particules en blocs d'ambiance par biome + signatures par espèce ; animations signature (rôles Toupie, Helice, Roue, Moulin, Pendule, Bascule, Flamme) ; ondes au sol dès Géante, onde de choc des Colossales/Titans à la pousse.

## Progression avancée
- Multiplicateurs permanents (`Shared.Bonus`) : renaissances (revenus × 2ⁿ, Forge + 50 %·n, prix 1 M × 10ⁿ) et pages complètes du Bestiaire (+ 10 % chacune), inclus dans `RevenuParSeconde` ; boost de la roue (× 2, `BoostJusqua`) et événement appliqués au versement.
- Graines (`Config.Graines`, `Lancer.tauxAvecChance`) achetées et équipées (`Graines`, `Graine`) ; mutations (`Config.Mutations`, fiche « Rarete:Taille:Espece:Mutation », `Modeleur.muter`).
- Roue gratuite toutes les 4 h (`ProchaineRoue`, `TournerRoue`/`ResultatRoue`) ; traînées cosmétiques (`Trainees`, `Trainee`). Serveur `Progression`, client `InterfaceBoutique` (bouton « Shop »).

- Plaquage : bouton PLAQUER (F / Y), portée 8, délai 6 s, protection 4 s ; le porteur lâche sa créature, libre pour tous ; refusé dans les bases. [[04 Plaquage]]
- Monstres comiques par zone, jamais dans une base ; aucun dégât : leur coup fait lâcher la créature, propulse le joueur (vitesse du monstre × Recul, plafond 500 studs/s, + Hauteur) et l'étourdit (PlatformStand 1 / 1,4 / 1,8 s, attribut `EtourdiJusqua`), avec un style comique tiré au hasard (`Shared.Projection` : Boing, Toupie, Fusée, Ballon ; traînée arc-en-ciel, onomatopée, étoiles client `EffetsComiques`) ; cycle jour/nuit avec vagues de nuit. [[05 Monstres]]
- Raids : voler une créature exposée dans la base d'un autre ; verrou de base de 60 s (100 pièces) avec bouclier et décompte. [[06 Raids de bases]]
- Pièges : filet, glu, fausse graine (coût en pièces, nombre limité, protection après piégeage, pas dans les bases). [[07 Pièges]]

## Décor et ambiance
- Pays des Graines : Pépin, mascotte géante animée (espèce `Pepin`, attribut `Mascotte`), et panneau de bienvenue devant la base centrale. Streaming activé (rayon 640) ; petits décors sans ombre ; animations à cadence réduite au loin.
- Bords de la carte : rempart décoré propre à chaque biome des deux côtés (palissade, mur moussu, muraille de grès, mur de glace, falaise de lave, champ de force, corail, sucres d'orge, végétation, nuages et colonnes, grille de manoir), Prairie derrière les bases, dernier biome au bout ; murs invisibles de 1 000 studs derrière ; un joueur sous Y = -30 revient dans sa base (`Config.Limites`).
- Décor cartoon généré par le serveur (`Decor`) : éclairage coloré (atmosphère, saturation, éclat), place de sable sous les bases, chemins devant les portes, arbres (dont roses et dorés), rochers, champignons, fleurs, nuages, collines de bordure.
- Bases ornées : bordure colorée (sans collision) et lampadaires-sucettes ; sol vert vif.
- Bestiaire en blocs (`Shared.Bestiaire`, construit par `Modeleur`) : deux espèces de créature par rareté (Poussigraine/Champichou, Lapinou/Tortipousse, Renardelle/Hibouflor, Cerfaurore/Lionfeuille, Dragonnet/Phenigraine), tirées au hasard ; deux monstres par zone (Gloupinou/Piquerelle, Ronchonbulle/Croquelune, Grobidou/Brasaurus). Le `Corps` reste la racine invisible (taille et règles inchangées).
- Auras de rareté : étincelles dès Épique, halo arc-en-ciel en Mythique.
- Finition : ombrage automatique en 3 tons des gros blocs (bande sombre, dessus clair), détails par espèce (griffes, dents, rayures…), contours cartoon (Highlight) sur les 20 modèles les plus proches.
- Textures pixel-art 16×16 (Pelage, Écailles, Gelée) teintées par la couleur de chaque gros bloc (`Bestiaire.Textures`, images du compte du propriétaire).
- Animations client (`Animations`, calculs dans `Shared.Anime`) : sautillement des créatures, dandinement des monstres, pattes qui marchent, ailes, queues, oreilles, coup de bras/mâchoire quand un monstre frappe (attribut `FrappeA`).
- Interface : boutons de pièges en rangée en bas à gauche (ne recouvrent plus les stats).

## À faire
- Créer les 4 passes sur Roblox et mettre leurs Id dans `Config.Passes`.
- Skins de graines (cosmétiques du Plan).
- Test du cycle jour/nuit à la main (vérifié seulement par les tests automatiques).
