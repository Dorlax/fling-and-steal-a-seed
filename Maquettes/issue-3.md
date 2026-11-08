# Maquette — issue #3 : Lancer et raretés

Demande : [[02 Lancer et raretés]] · Plan : [[Vision]], [[Règles du jeu]] · État : [[État du jeu]]

## Objectif
Le joueur lance une graine depuis sa base vers les Terres Sauvages. La distance
dépend de sa **Force** plus un **bonus de jauge de timing**. Une créature pousse
au point d'atterrissage, avec une rareté tirée par le serveur selon la **zone**
(Proche, Moyenne, Lointaine), aux taux du Plan, toujours affichés à l'écran.

Hors périmètre (demande 03 « Porter et revenus ») : récolter, porter, revenus,
vol. Ici la créature pousse et reste au sol.

## Fichiers à modifier / créer
| Fichier | Rôle |
|---|---|
| `src/shared/Config.luau` | Ajouter la section `Lancer` (réglages ci-dessous) et la table `Raretes`. |
| `src/shared/Jauge.luau` (nouveau) | Logique pure de la jauge : position, couleur, bonus, message. |
| `src/shared/Lancer.luau` (nouveau) | Logique pure : distance, zone, tirage de rareté, texte des taux. |
| `src/server/Lancers.luau` (nouveau) | Côté serveur : début/lâcher de jauge, validation, calcul, création de la graine et de la créature. |
| `src/server/TerresSauvages.luau` (nouveau) | Crée le sol des Terres Sauvages et le dossier `Workspace.Creatures`. |
| `src/server/Principal.server.luau` | Brancher les RemoteEvents et `TerresSauvages.creer()`, nettoyer à la sortie du joueur. |
| `src/client/InterfaceLancer.luau` (nouveau) | Bouton LANCER, jauge animée, message, panneau des taux. |
| `src/client/Principal.client.luau` | `InterfaceLancer.demarrer()`. |
| `default.project.json` | Déclarer les RemoteEvents `DemarrerJauge`, `LacherJauge`, `ResultatLancer` dans ReplicatedStorage. |

Ne pas toucher : Forge, Sauvegarde, Bases (sauf lecture via `Bases.apparitionDe` / le modèle de base).

## Réglages (Config)
```lua
Lancer = {
	DistanceMin = 30,          -- studs, Force 0 et jauge verte
	DistanceParForce = 0.4,    -- studs par point de Force (Force 1000 -> +400)
	DistanceMax = 520,         -- plafond absolu
	DelaiEntreLancers = 3,     -- secondes, contrôlé par le serveur
	MaxCreaturesAuSol = 10,    -- par joueur ; au-delà, la plus ancienne disparaît
	CompensationPingMax = 0.25,-- secondes de latence retirées au maximum
	DureeMaxJauge = 10,        -- au-delà, la jauge est annulée côté serveur
	Jauge = {
		Periode = 1.6,         -- secondes pour monter (0 -> 1) puis redescendre (1 -> 0)
		-- seuils sur la position p (0 = bas, 1 = haut), du bas vers le haut
		Paliers = {
			{ Couleur = "Vert",   Min = 0,    Bonus = 0,  Message = "Pas mal !" },
			{ Couleur = "Jaune",  Min = 0.5,  Bonus = 15, Message = "Bien joué !" },
			{ Couleur = "Orange", Min = 0.75, Bonus = 35, Message = "Super !" },
			{ Couleur = "Rouge",  Min = 0.92, Bonus = 60, Message = "PERFECT !" },
		},
	},
	Zones = {                  -- distance depuis le bord de la base
		{ Nom = "Proche",    Min = 0 },
		{ Nom = "Moyenne",   Min = 150 },
		{ Nom = "Lointaine", Min = 300 },
	},
},
Raretes = {
	Ordre = { "Commune", "Rare", "Epique", "Legendaire", "Mythique" },
	Noms  = { Commune = "Commune", Rare = "Rare", Epique = "Épique", Legendaire = "Légendaire", Mythique = "Mythique" },
	Taux = { -- en %, exactement le tableau du Plan
		Proche    = { Commune = 70, Rare = 22, Epique = 6,  Legendaire = 1.8, Mythique = 0.2 },
		Moyenne   = { Commune = 55, Rare = 28, Epique = 12, Legendaire = 4,   Mythique = 1 },
		Lointaine = { Commune = 40, Rare = 30, Epique = 18, Legendaire = 9,   Mythique = 3 },
	},
	Couleurs = { -- pour la créature et l'affichage
		Commune = {200,200,200}, Rare = {80,160,255}, Epique = {180,90,255},
		Legendaire = {255,190,40}, Mythique = {255,70,120},
	},
},
```
Le haut de la jauge (rouge) est le meilleur moment : « PERFECT ! ».

## Comportement attendu

### Jauge (module pur `Jauge`)
- `Jauge.position(t, periode) -> number` : onde triangle. `p(0) = 0`, monte
  linéairement jusqu'à `p(periode/2) = 1`, redescend à `p(periode) = 0`, se répète.
  `t < 0` est traité comme 0.
- `Jauge.palier(p) -> palier` : le palier dont `Min` est le plus grand ≤ p
  (p borné à [0, 1]). Renvoie la table du palier (Couleur, Bonus, Message).

### Distance, zone, rareté (module pur `Lancer`)
- `Lancer.distance(force, bonusJauge) -> number` :
  `min(DistanceMax, DistanceMin + forceNettoyee × DistanceParForce + bonusJauge)`.
  Force non numérique, NaN ou négative -> 0 ; Force > PlafondStat -> PlafondStat.
  La jauge **s'ajoute** à la Force.
- `Lancer.zone(distance) -> "Proche" | "Moyenne" | "Lointaine"` selon `Zones`.
- `Lancer.tirerRarete(zone, aleatoire) -> string` : `aleatoire ∈ [0, 1[`, parcourt
  `Raretes.Ordre` en cumulant les taux (en fraction) ; renvoie la première rareté
  dont le cumul dépasse `aleatoire`. Le tirage ne dépend **que** de la zone
  (jamais de la jauge).
- `Lancer.texteTaux(zone) -> string` : ex. pour Proche
  `"Proche : Commune 70 % · Rare 22 % · Épique 6 % · Légendaire 1,8 % · Mythique 0,2 %"`
  (virgule décimale française, pas de « .0 »).

### Serveur (`Lancers`)
Flux en deux temps, le client n'envoie **aucune valeur** de résultat :
1. `DemarrerJauge:FireServer()` -> le serveur vérifie : données chargées,
   personnage vivant, base existante, délai `DelaiEntreLancers` écoulé depuis le
   dernier lancer, pas de jauge déjà en cours. Il mémorise `debut = os.clock()`.
2. `LacherJauge:FireServer()` (arguments ignorés) -> si une jauge est en cours :
   `t = os.clock() - debut - min(ping, CompensationPingMax)` avec
   `ping = joueur:GetNetworkPing()` ; si `t > DureeMaxJauge` le lancer est
   annulé. Sinon : `p = Jauge.position(t)`, `palier = Jauge.palier(p)`,
   `distance = Lancer.distance(Force attribut, palier.Bonus)`,
   `zone = Lancer.zone(distance)`, `rarete = Lancer.tirerRarete(zone, Random)`.
3. Point d'atterrissage : depuis le bord de la base du joueur côté +Z
   (`centre base + (0, 0, 20)`), à `distance` studs dans la direction +Z, posé
   sur le sol des Terres Sauvages.
4. Une graine (petite sphère lumineuse) vole en arc jusqu'au point (effet
   visuel, ~1 s), puis une **créature** apparaît : un `Model` nommé
   `Creature` dans `Workspace.Creatures`, avec les attributs
   `Rarete`, `Zone`, `Proprietaire` (UserId), `Distance`, couleur selon la rareté,
   un panneau au-dessus (nom de rareté, gros texte avec contour).
5. Si le joueur a plus de `MaxCreaturesAuSol` créatures au sol, la plus ancienne
   est détruite. À la sortie du joueur, ses créatures au sol sont détruites.
6. `ResultatLancer:FireClient(joueur, { Distance, Couleur, Message, Zone, Rarete })`.
7. Le délai entre lancers démarre au lâcher.

Toute fonction serveur accepte un faux joueur (table avec `GetAttribute`,
`SetAttribute`, `UserId`, `Character`, `GetNetworkPing`) pour les tests en jeu :
exposer `Lancers.demarrer(joueur, maintenant?)` et
`Lancers.lacher(joueur, maintenant?, aleatoire?) -> resultat?` où `maintenant`
remplace `os.clock()` et `aleatoire` remplace le tirage, pour des tests
déterministes. Les RemoteEvents n'utilisent jamais ces paramètres optionnels
(le serveur ignore tout argument venant du client).

### Terres Sauvages (`TerresSauvages`)
- `TerresSauvages.creer()` : une Part ancrée `Workspace.TerresSauvages`, herbe
  vert vif, qui couvre en X toutes les bases et en Z de +20 à
  `+20 + DistanceMax + 40`, surface à Y = 0. Idempotent.
- Crée `Workspace.Creatures` (Folder) s'il n'existe pas.
- Trois panneaux au sol / bornes colorées marquant le début des zones Moyenne
  (150) et Lointaine (300).

### Client (`InterfaceLancer`)
- Un gros bouton **LANCER** (TextButton, `Activated` : souris et toucher) en bas
  à droite ; à la manette, `ContextActionService` lie `ButtonR2` à la même action
  (et la touche `F` au clavier). Le bouton reste affiché sur toutes les plateformes.
- 1er appui : `DemarrerJauge`, la jauge verticale (dégradé vert, jaune, orange,
  rouge de bas en haut) s'affiche, un curseur suit `Jauge.position` en local.
- 2e appui : `LacherJauge` ; la jauge se cache.
- À `ResultatLancer` : message du palier en gros texte épais avec contour,
  couleur du palier, animation rebondissante (« PERFECT ! » pour le rouge),
  puis « +{Distance} m · {Rareté} ». Effet plus généreux pour Épique et au-dessus.
- Panneau **Taux de rareté** toujours visible (repliable mais pas masqué par
  défaut) avec les trois lignes `Lancer.texteTaux(zone)`.
- Le client n'affiche que ce que le serveur renvoie ; il ne calcule ni distance
  ni rareté.

## Critères d'acceptation
Tests unitaires (Lune, `tests/unitaires`) sauf mention « en jeu ».

- **C1** Taux : pour chaque zone, la somme des taux `Config.Raretes.Taux` vaut
  100 (à 1e-9 près), chaque taux est > 0 et les valeurs sont exactement celles
  du Plan (ex. Proche Mythique = 0,2 ; Lointaine Légendaire = 9).
- **C2** `Jauge.position` : `p(0) = 0`, `p(0,8) = 1`, `p(0,4) = 0,5`,
  `p(1,6) = 0`, `p(2,4) = 1` (période 1,6), toujours dans [0, 1], `p(-1) = 0`.
- **C3** `Jauge.palier` : 0 -> Vert, 0,49 -> Vert, 0,5 -> Jaune, 0,8 -> Orange,
  0,92 -> Rouge avec Message `"PERFECT !"`, 1 -> Rouge ; bonus croissants
  Vert < Jaune < Orange < Rouge.
- **C4** `Lancer.distance` : Force 0 + bonus 0 = 30 ; Force 100 + bonus 0 = 70 ;
  la jauge s'ajoute (Force 100 + bonus 60 = 130) ; plus de Force donne plus de
  distance à bonus égal ; Force `"abc"`, NaN ou -5 donne 30 ; résultat jamais
  > `DistanceMax`.
- **C5** `Lancer.zone` : 0 et 149,9 -> Proche ; 150 -> Moyenne ; 299 -> Moyenne ;
  300 et 520 -> Lointaine.
- **C6** `Lancer.tirerRarete` : Proche 0 -> Commune, 0,6999 -> Commune,
  0,70 -> Rare, 0,9999 -> Mythique ; Lointaine 0,95 -> Légendaire (cumul
  0,88..0,97) ; pour chaque zone, chaque rareté est atteinte par au moins une
  valeur de [0, 1[ (toutes les raretés restent possibles).
- **C7** La rareté ne dépend pas de la jauge : `Lancer.tirerRarete` a pour seuls
  paramètres `(zone, aleatoire)` ; pour une même distance et un même aléatoire,
  la rareté est identique quel que soit le palier (vérifié en comparant les
  résultats de `Lancer.zone` + `tirerRarete` pour deux bonus qui laissent la
  distance dans la même zone).
- **C8** `Lancer.texteTaux("Proche")` contient `"Commune 70 %"`,
  `"Légendaire 1,8 %"`, `"Mythique 0,2 %"` ; `texteTaux("Moyenne")` contient
  `"Mythique 1 %"` (pas de `"1,0"`).
- **C9** *(en jeu)* Validation serveur : `Lancers.lacher` sans `demarrer`
  préalable renvoie `nil` ; un second `demarrer` pendant une jauge en cours est
  ignoré ; un `demarrer` moins de `DelaiEntreLancers` s après un lâcher est
  refusé ; une jauge lâchée après `DureeMaxJauge` est annulée (renvoie `nil`).
- **C10** *(en jeu)* Résultat serveur : avec un faux joueur Force 100, ping 0,
  `demarrer(j, 0)` puis `lacher(j, 0.8, 0)` renvoie Couleur `"Rouge"`,
  Message `"PERFECT !"`, Distance 130, Zone `"Proche"`, Rarete `"Commune"` ;
  le ping est compensé au plus de `CompensationPingMax`.
- **C11** *(en jeu)* Créature : après un lancer réussi, `Workspace.Creatures`
  contient un nouveau Model `Creature` avec les attributs `Rarete`, `Zone`,
  `Proprietaire` = UserId et `Distance` cohérents avec le résultat, placé à
  ±2 studs (en Z) de `bord de base + Distance`, au-dessus du sol des Terres
  Sauvages ; au-delà de `MaxCreaturesAuSol` la plus ancienne disparaît.
- **C12** *(en jeu)* Démarrage : `Workspace.TerresSauvages` et
  `Workspace.Creatures` existent ; les RemoteEvents `DemarrerJauge`,
  `LacherJauge`, `ResultatLancer` existent dans ReplicatedStorage.
- **C13** *(en jeu)* Le serveur ignore les arguments du client : appeler le
  gestionnaire de `LacherJauge` avec `(joueur, 9999, "Mythique", {Distance = 999})`
  donne le même résultat que sans argument (la distance et la rareté ne
  viennent que du serveur).

## Vérifications manuelles (Studio, non bloquantes)
- Le bouton LANCER fonctionne à la souris, au toucher (émulateur mobile) et à
  la manette (R2), la jauge est lisible, « PERFECT ! » rebondit.
- Le panneau des taux est visible dès l'arrivée.
