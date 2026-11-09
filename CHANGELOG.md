# Journal des modifications

Chaque mise à jour du jeu ajoute ici une section datée (agent Contexte).








## 2026-11-09 — Créatures libres dans la base, vente et gains hors ligne
- Plus de socles : chaque créature se promène librement autour de sa place (marche, pauses, sauts et pirouettes), calculé de la même façon par le serveur et les clients à partir de l'heure du serveur (`Shared.Promenade`) ; les vols restent vérifiés par le serveur.
- Bouton « Base » : liste des créatures (aperçu 3D, rareté, taille, revenu, étage), vente avec confirmation (prix = 2 min de revenu), « Ranger par valeur » (les meilleures au rez-de-chaussée). RemoteEvents `VendreCreature` et `TrierBase`, tout vérifié par le serveur.
- Gains hors ligne : au retour, 50 % du revenu pendant l'absence (12 h au plus), annoncé au joueur.

## 2026-11-09 — Optimisation et identité du Pays des Graines
- Streaming activé (rayon 640, minimum 160) : chaque joueur ne charge que les biomes autour de lui, au lieu des 21 biomes d'un coup.
- Petits éléments de décor sans ombre portée ; animations des créatures à pleine cadence de près, une image sur 2 ou 3 au-delà de 50 / 100 studs.
- Pépin, mascotte géante du Pays des Graines (graine souriante à pousse, socle fleuri, animée, cœurs et pollen) devant les bases, et panneau « Bienvenue au Pays des Graines ! ».
- Aperçus 3D partagés (`Apercu`) entre le Bestiaire et les futures interfaces.

## 2026-11-09 — Effets et animations signature des espèces
- Effets en petits blocs autour de chaque espèce (client `EffetsEspeces`, données `Shared.Effets`) : ambiance de son biome (pollen, lucioles, poussière, flocons, braises, étoiles, bulles, confettis, feuilles, plumes, brume, vapeur, pétales, éclats de cristal, paille, Zzz, gouttes) et effets signature pour ~80 espèces (flammes des créatures de feu, vapeur des machines, notes du piano et du tambour, Zzz des dormeurs, cœurs des peluches, poussière d'étoiles des fées, jets d'eau…).
- Animations signature : toupie qui tourne, tornade qui tourbillonne, hélices et roues qui tournent, moulin, aiguilles et balancier de l'horloge, cheval à bascule, flammes qui frémissent (nouveaux rôles d'`Anime`).
- Grosses tailles : effets plus fréquents et plus gros, onde au sol régulière dès Géante, onde de choc et gerbe de poussière quand une Colossale ou une Titan sort de terre.
- Économie : 14 modèles proches au plus, 180 particules à l'écran au plus.

## 2026-11-09 — Bestiaire à collectionner et finitions
- Bouton « Livre » : album du Bestiaire, une page par biome (210 créatures), aperçus 3D qui tournent, silhouette noire tant qu'une espèce n'a pas été récoltée, rareté et revenu de chaque espèce, les 3 monstres du biome ; ouvre sur le biome où se trouve le joueur.
- Découvertes sauvegardées (`Decouvertes`) : déposer une nouvelle espèce dans sa base l'ajoute (« Nouvelle espèce au Bestiaire : X ! (n/210) ») ; les créatures déjà en base comptent.
- Finitions du bestiaire : hauteur des panneaux mesurée sur les blocs (panneaux des monstres bien placés), matériau Métal rendu (Cité Mécanique), flaque d'eau sous les nageurs (poisson, requin, dauphin, raie, léviathan, koï), perchoir du paresseux.

## 2026-11-09 — Ferme Joyeuse, Royaume des Rêves, Plage Soleil
- Biomes 19 (Ferme Joyeuse), 20 (Royaume des Rêves) et 21 (Plage Soleil) : 39 nouvelles espèces dessinées à la main (`EspecesFerme`, `EspecesReves`, `EspecesPlage`), décors en blocs (granges, enclos, moulins, potagers ; nuages-lits, lunes, étoiles tombées, bulles de rêve ; palmiers à cocos, parasols, châteaux de sable, étoiles de mer) et remparts propres.

## 2026-11-09 — Cavernes, Coffre à Jouets, Forêt d'Automne
- Biomes 16 (Cavernes Lumineuses), 17 (Coffre à Jouets) et 18 (Forêt d'Automne) : 39 nouvelles espèces dessinées à la main (`EspecesCavernes`, `EspecesJouets`, `EspecesAutomne`), décors en blocs (cristaux, stalagmites, champignons phosphorescents, wagonnets ; piles de cubes, crayons géants, ballons, rails ; arbres roux, tas de feuilles, bottes de paille, cèpes) et remparts propres.

## 2026-11-09 — Savane, Cité Mécanique, Jardin Zen
- Biomes 13 (Savane Dorée), 14 (Cité Mécanique) et 15 (Jardin Zen) : 39 nouvelles espèces dessinées à la main (`EspecesSavane`, `EspecesMecanique`, `EspecesZen`), décors en blocs (acacias, termitières, herbes hautes ; engrenages géants, tuyaux à vapeur, lampadaires à gaz ; cerisiers, bambous, lanternes de pierre, portiques) et remparts propres.
- Plafond de pièces relevé à 1e300 (progression quasi infinie) ; grands nombres : suffixes jusqu'à « Vg » (1e63), puis notation « 1,23e75 ».

## 2026-11-09 — Bords de carte et coups de monstres
- Remparts décorés autour de la carte, un style par biome, avec murs invisibles très hauts ; filet de sécurité qui ramène à la base un joueur tombé.
- Les monstres ne font plus de dégâts : leur coup fait lâcher la créature, propulse le joueur (plus fort dans les biomes lointains, car le monstre est plus rapide) et l'étourdit 1 à 1,8 s.
- Projections comiques tirées au hasard : Boing, Toupie (le joueur tourne sur lui-même), Fusée (décollage vertical), Ballon (le joueur flotte accroché à trois ballons puis POP) ; traînée arc-en-ciel, onomatopée colorée (« FIUUUU ! », « POUET ! »…), étoiles qui tournent autour de la tête pendant l'étourdissement.

## 2026-11-09 — Jungle, Îles Célestes, Manoir Hanté
- Biomes 10 (Jungle Émeraude), 11 (Îles Célestes) et 12 (Manoir Hanté) : 39 nouvelles espèces dessinées à la main (`EspecesJungle`, `EspecesCiel`, `EspecesManoir`).
- Décors en blocs : arbres tropicaux à lianes, fleurs géantes, ruines à glyphes, fougères ; nuages escaladables, colonnes de marbre, arcs-en-ciel, plumes dorées ; tombes, arbres tordus, citrouilles lumineuses, lanternes fantômes.
## 2026-11-09 — Multijoueur : événements et classements
- Événements de serveur pour tout le monde, un toutes les 8 min pendant 2 min 30 : Pluie dorée (revenus × 2), Vent porteur (lancers + 300 studs), Graines géantes (tailles comme 3 biomes plus loin). Annonce à tous, pastille avec le temps restant ; les taux de rareté ne changent jamais.
- Record de biome par joueur (sauvegardé `RecordBiome`), annoncé à tout le serveur quand il est battu.
- Liste des joueurs : Biome, Revenu/s, Pièces.
- Bouton « Top » : classement de ce serveur et du monde entier (revenus / s et biome le plus loin, OrderedDataStore mis à jour toutes les 2 min).

## 2026-11-08 — Marais, Récif, Bonbon
- Biomes 7 (Marais Brumeux), 8 (Récif Corail) et 9 (Royaume Bonbon) : 39 nouvelles espèces dessinées à la main (`EspecesMarais`, `EspecesRecif`, `EspecesBonbon`).
- Décors en blocs : arbres morts, flaques à nénuphars, roseaux, feux follets ; coraux, algues, coquillages géants, bulles ; sucettes, sucres d'orge, cupcakes géants, dragées.
## 2026-11-08 — Tailles selon le biome
- Plus le biome d'atterrissage est loin, plus les grosses tailles sortent souvent (toujours aléatoire) ; taux du biome atteint affichés dans le panneau des taux.
## 2026-11-08 — Agrandissement des bases
- Trois tailles de base (40, 56, 72 studs), achetées en pièces ; la base est reconstruite au même endroit, socles plus espacés.
- Créatures exposées à leur vraie taille (3 studs × taille), réduites seulement au-delà de ce que la base permet (× 1,3 / 2,1 / 2,8).
- Bases espacées de 90 studs ; Terres Sauvages et décor élargis à 1 200 studs.
## 2026-11-08 — Étages de base
- Jusqu'à 3 étages par base, 10 socles chacun, achetés en pièces ; ascenseurs entre les étages ; capacité de la base = 10 × étages (sauvegardé).
- Les raids et le verrou couvrent tous les étages.
## 2026-11-08 — Glacier, Volcan, Galaxie ; monstres plus rapides ; socles
- Biomes 4 (Glacier Givré), 5 (Volcan Ardent) et 6 (Galaxie Étoilée) : 39 nouvelles espèces dessinées à la main, décors en blocs (sapins, igloos, pics de glace ; cônes fumants, mares de lave, obsidienne ; cristaux, astéroïdes, planètes).
- Monstres de plus en plus rapides à chaque biome : il faut entraîner sa Vitesse pour leur échapper.
- Force et Vitesse sans aucune limite réelle.
- Socles d'exposition dans les bases, colorés selon la rareté.
## 2026-11-08 — Biomes, niveaux de Forge et bestiaire élargi
- Moteur de biomes (`Shared.Biomes`) : route de biomes de 600 studs, sols, arches, décors en blocs (Forêt, Désert) et ambiance par biome ; valeur × 1,5 par biome.
- Biomes 2 (Bois Moussu) et 3 (Dunes Dorées) : 26 nouvelles espèces dessinées à la main (10 créatures + 3 monstres chacun).
- Monstres limités aux biomes occupés (12 au plus par biome la nuit).
- Progression sans limite : Force/Vitesse logarithmiques au-delà de 1 000, niveaux de Forge achetés en pièces, nombres raccourcis.
## 2026-11-08 — Tailles des créatures et espèces « graine »
- Cinq tailles (Normale → Titan) tirées par le serveur, taux affichés dans le panneau des taux ; revenu × 1 à × 20 selon la taille (`Config.Tailles`, `Shared.Fiche`).
- Sauvegarde : chaque créature de base est une fiche « Rarete[:Taille[:Espece]] », compatible avec les anciennes sauvegardes.
- Cinq nouvelles espèces sur le thème plante (Champichou, Tortipousse, Hibouflor, Lionfeuille, Phenigraine) : deux espèces par rareté.
- La créature sort de terre et grandit à l'atterrissage de la graine ; panneaux et messages indiquent la taille (« Géante Épique »).
## 2026-11-08 — Textures pixel-art
- Trois motifs 16×16 en niveaux de gris (Pelage, Écailles, Gelée), créés dans Blender et envoyés sur Roblox ; `Modeleur` les pose sur les faces visibles des gros blocs, teintés par leur couleur.
## 2026-11-08 — Finition du bestiaire
- Ombrage automatique en trois tons des gros blocs (`Bestiaire.ombrer`) : bande sombre en bas, dessus clair.
- Détails par espèce : griffes, rangées de dents, rayures, ventres, intérieurs d'oreilles, nervures d'ailes.
- Contours cartoon côté client (Highlight) sur les modèles proches (20 au plus).
## 2026-11-08 — Bestiaire en blocs et animations des membres
- Nouveau style « jouet en blocs » (inspiré des jeux de référence) : `Shared.Bestiaire` décrit chaque espèce, `Modeleur` la construit autour d'un `Corps` invisible.
- Créatures : une espèce par rareté (Poussigraine, Lapinou, Renardelle, Cerfaurore, Dragonnet), auras de rareté.
- Monstres : deux espèces par zone (Gloupinou, Piquerelle, Ronchonbulle, Croquelune, Grobidou, Brasaurus) ; le nom affiché est celui de l'espèce.
- Animations client : pattes, bras, ailes, queues, oreilles, tête et mâchoire ; coup animé quand un monstre frappe. Aucune règle ni valeur de Config modifiée.

## 2026-11-08 — Modèles détaillés et animations
- Créatures ornées selon la rareté : pousse (Commune), oreilles (Rare), ailes et étincelles (Épique), couronne dorée (Légendaire), auréole d'étoiles (Mythique).
- Monstres détaillés par zone : antenne et gouttes (Gloupinou), sourcils froncés, cornes et piquants (Ronchonbulle), grandes cornes, dents, bras et taches (Grobidou) ; pieds et reflets pour tous.
- Animations locales (client) : les créatures posées sautillent et regardent autour d'elles, les monstres se dandinent. Aucune règle de jeu modifiée.

## 2026-11-08 — Décor cartoon et ambiance

- Nouveau module serveur `Decor` : éclairage coloré (Atmosphere, ColorCorrection, Bloom, SunRays) appliqué avant le cycle jour/nuit ; place de sable sous les bases ; chemins devant les portes ; arbres, rochers, champignons, fleurs, nuages et collines de bordure (graine fixe, purement visuel, `CanQuery = false`).
- Bases : sol vert vif, bordure colorée sans collision et quatre lampadaires-sucettes (dossier `Ornements`).
- Créatures (au sol et exposées) : reflets dans les yeux, joues roses, petits pieds (`Decor.mignonner`).
- Interface : boutons de pièges en rangée en bas à gauche, panneau des stats légèrement remonté (plus de chevauchement).

## 2026-11-08 — Correctif typage interface (issue #15)

- InterfacePieges : le champ `jauge` utilise le type `Habillage.Jauge`.
- Panneaux : genre affiné après le test de nil ; `Adornee` affecté seulement si le support est une BasePart.

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
