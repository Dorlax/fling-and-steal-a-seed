# Maquette : issue #11 — Raids de bases

Demande : [[06 Raids de bases]]
Plan : [[Vision]] (Interactions entre joueurs : « Raids : entrer dans une base pour voler une créature ; la porte se verrouille 60 s quand le propriétaire l'achète »), [[Règles du jeu]] (pièces et créatures gérées par le serveur, un bouton à l'écran pour chaque action, tout original).

## Objectif
Un joueur peut entrer dans la base d'un autre joueur et lui voler une créature exposée avec l'action « Voler ». La créature volée passe en portage chez le voleur, qui doit la ramener dans sa propre base (même dépôt que d'habitude). Le propriétaire est prévenu. Le propriétaire peut acheter un verrou de 60 s (bouton « Verrouiller » dans sa base) : pendant ce temps, personne d'autre ne peut rester dans sa base. Tout est décidé et vérifié par le serveur ; le client ne fait qu'afficher.

## Réglages (src/shared/Config.luau, nouvelle section `Raid`)
```lua
Raid = {
	DistanceVol = 10,       -- studs max entre le voleur et la créature exposée
	DureeVol = 1,           -- secondes de maintien du ProximityPrompt « Voler »
	DureeVerrou = 60,       -- secondes de verrouillage (valeur du Plan)
	Recharge = 60,          -- secondes après la FIN du verrou avant de pouvoir le racheter
	PrixVerrou = 100,       -- pièces
	DistanceVerrou = 10,    -- studs max entre le propriétaire et le bouton « Verrouiller »
	DistanceExpulsion = 8,  -- studs devant la porte, hors de la base, où l'intrus est replacé
	DureeAlerte = 3,        -- secondes d'affichage de « VOLÉ ! »
},
```
Prochaine disponibilité après un achat à l'instant `t` : `pretA = t + DureeVerrou + Recharge`.

## Fichiers à modifier / créer

### Nouveau : `src/shared/Raid.luau` (module pur, testable avec Lune)
Même en-tête que `src/shared/Plaquage.luau` (require Roblox / Lune). Fonctions :
- `Raid.verifierVol(contexte) -> (boolean, string?)` avec
  `contexte = { memeJoueur, voleurVivant, voleurPorte, voleurDansBaseCible, baseVerrouillee, emplacementValide, distance }`.
  Raisons, dans cet ordre : `"soi-même"`, `"indisponible"` (voleur mort), `"porte"` (porte déjà une créature), `"base"` (pas dans la base visitée), `"verrouillee"`, `"creature"` (emplacement vide/invalide), `"portee"` (distance non finie ou > `DistanceVol`).
- `Raid.verifierVerrou(contexte) -> (boolean, string?)` avec
  `contexte = { estProprietaire, vivant, distance, pieces, maintenant, verrouJusqua?, pretA? }`.
  Raisons, dans cet ordre : `"proprietaire"`, `"indisponible"`, `"portee"` (> `DistanceVerrou` ou non finie), `"verrouillee"` (maintenant < verrouJusqua), `"recharge"` (maintenant < pretA), `"pieces"` (pieces non fini ou < `PrixVerrou`).
- `Raid.acheterVerrou(maintenant) -> (verrouJusqua, pretA)` : `maintenant + DureeVerrou`, `maintenant + DureeVerrou + Recharge`.
- `Raid.estVerrouillee(maintenant, verrouJusqua?) -> boolean` (nil ou non fini → false).
- `Raid.doitExpulser(estProprietaire, dansLaBase, verrouillee) -> boolean` : vrai seulement si non propriétaire, dans la base et verrouillée.
- `Raid.retirerEmplacement(liste, numero) -> (nouvelleListe, rarete?)` : copie sans l'élément `numero` (les suivants remontent) ; `numero` non entier, hors bornes ou élément non string → liste copiée inchangée et `nil`. Ne modifie jamais `liste`.
- `Raid.texteVerrou(maintenant, verrouJusqua?, pretA?) -> string` :
  verrouillée → `"VERROUILLÉ " .. ceil(reste) .. " s"` ; en recharge → `"Prêt dans " .. ceil(reste) .. " s"` ; sinon `"Verrouiller : " .. PrixVerrou .. " pièces"`.

### `src/server/Sauvegarde.luau`
- Nouveau `Sauvegarde.retirerCreature(joueur, numero) -> string?` : utilise `Raid.retirerEmplacement`, met à jour la liste et l'attribut `RevenuParSeconde`, renvoie la rareté retirée (ou nil, sans rien changer).

### `src/server/Bases.luau`
- Chaque créature exposée reçoit l'attribut `Emplacement = numero` et un ProximityPrompt `Voler` sur son `Corps` : `ActionText = "Voler"`, `ObjectText` = nom de la rareté, `HoldDuration = DureeVol`, `MaxActivationDistance = DistanceVol`, `RequiresLineOfSight = false`, touches `E` / `ButtonX` (ProximityPrompt = bouton tactile sur mobile et bouton manette sur console). Son `Triggered` appelle un rappel enregistré par `Bases.surVol(rappel)` avec `(declencheur, proprietaire, numero)` ; le serveur ne fait confiance qu'à ces objets, pas à un argument client.
- Construction de la base : ajouter
  - `Porte` : arche cartoon (deux poteaux + linteau, couleurs franches) au bord Z+ du sol (côté Terres Sauvages), avec un BillboardGui `PanneauVerrou` (gros texte épais avec contour) qui affiche `Raid.texteVerrou(...)` ;
  - `BoutonVerrou` : petit socle près de la porte, côté intérieur, avec ProximityPrompt `Verrouiller` (`ActionText = "Verrouiller"`, `ObjectText = "100 pièces"`, touches `R` / `ButtonB`, car `F` / `ButtonY` servent déjà au plaquage) ; rappel via `Bases.surVerrou(rappel)` avec `(declencheur, proprietaire)` ;
  - `Bouclier` : grande boîte rouge translucide couvrant le sol (taille 40 × HAUTEUR_BASE × 40, `CanCollide = false`, `CanQuery = false`, `CanTouch = false`), invisible (`Transparency = 1`) hors verrou, visible (≈ 0,75) pendant le verrou.
- Nouveaux : `Bases.estDansBaseDe(joueur, proprietaire) -> boolean` (même test de boîte que `estDansSaBase` mais sur le sol de `proprietaire`), `Bases.proprietaireDeBaseOu(joueur) -> Player?` (base dans laquelle se trouve le joueur, ou nil), `Bases.pointExpulsion(proprietaire) -> CFrame?` (devant la porte, `DistanceExpulsion` studs à l'extérieur du bord Z+), `Bases.afficherVerrou(proprietaire, maintenant)` (met à jour panneau et bouclier).

### Nouveau : `src/server/Raids.luau`
- État serveur par propriétaire : `verrouJusqua`, `pretA` (non sauvegardés). Recopiés en attributs joueur `VerrouJusqua` / `VerrouPretA` (heure serveur `Workspace:GetServerTimeNow()`) pour l'affichage client.
- `Raids.voler(voleur, proprietaire, numero, maintenant?) -> boolean` : construit le contexte avec `Raid.verifierVol` (vivant, `Portage.porte`, `Bases.estDansBaseDe`, verrou, emplacement présent dans `Sauvegarde.creaturesDe(proprietaire)`, distance HumanoidRootPart ↔ créature exposée). Si valide :
  1. `Sauvegarde.retirerCreature(proprietaire, numero)` puis `Bases.afficherCreatures(proprietaire, ...)` ;
  2. `Portage.porterVolee(voleur, rarete)` (voir Portage) ;
  3. effets : billboard « VOLÉ ! » rebondissant au-dessus du voleur pendant `DureeAlerte` s (style de `Plaquages.afficherEffet`) ;
  4. `AlerteVol:FireClient(proprietaire, "victime", rarete, voleur.Name)` et `AlerteVol:FireClient(voleur, "voleur", rarete, proprietaire.Name)`.
  Renvoie false sans rien changer sinon.
- `Raids.verrouiller(proprietaire, declencheur, maintenant?) -> boolean` : `Raid.verifierVerrou` (estProprietaire = declencheur == proprietaire, distance au `BoutonVerrou`, attribut `Pieces`). Si valide : retire `PrixVerrou` pièces (attribut `Pieces`, côté serveur), `Raid.acheterVerrou`, attributs, `Bases.afficherVerrou`, puis expulse immédiatement les intrus. Refus « pieces » / « recharge » : `MessageJeu` « Pas assez de pièces ! » / « Verrou en recharge ! ».
- `Raids.pas(maintenant?)` (appelé toutes les 0,2 s par la boucle de dépôt existante, ou sa propre boucle) : pour chaque base verrouillée, tout joueur ≠ propriétaire pour qui `Raid.doitExpulser` est vrai est replacé à `Bases.pointExpulsion(proprietaire)` (`PivotTo`) et reçoit `MessageJeu` « Base verrouillée ! ». S'il portait une créature, il la garde. Met aussi à jour le panneau une fois par seconde.
- `Raids.nettoyer(joueur)` : oublie l'état du joueur.

### `src/server/Portage.luau`
- Nouveau `Portage.porterVolee(voleur, rarete) -> boolean` : refuse si le voleur porte déjà ou est mort. Crée une créature portable identique à une créature récoltée (via une nouvelle fonction publique `Lancers.creerCreaturePortable(joueur, rarete, point) -> Model`, qui réutilise `creerCreature` : prompt « Récolter », attributs `Rarete`, `Proprietaire = voleur.UserId`, plus `Volee = true`), puis la met en portage avec exactement le même code que `recolter` (factoriser la partie « soudure + connexions + attribut Porte + vitesse » dans une fonction locale commune, sans changer le comportement de `recolter`).
- Rien d'autre : le dépôt (`verifierDepot`), le plaquage et les monstres (`Portage.lacher`) traitent déjà toute créature portée → la créature volée est lâchée et devient « libre » comme une autre.

### `src/server/Principal.server.luau`
- `remote("AlerteVol")` (serveur → client uniquement, aucun `OnServerEvent`).
- `Bases.surVol` → `Raids.voler` si les deux joueurs sont chargés ; `Bases.surVerrou` → `Raids.verrouiller`.
- Appeler `Raids.pas()` dans la boucle de 0,2 s ; `Raids.nettoyer(joueur)` au départ (avant `Bases.liberer`).

### `default.project.json`
- Ajouter `"AlerteVol": { "$className": "RemoteEvent" }`.

### Nouveau : `src/client/InterfaceRaid.luau` (+ appel depuis `Principal.client.luau`)
- Cache localement (`Enabled = false`) les prompts `Voler` des créatures de SA propre base et le prompt `Verrouiller` des autres bases (confort seulement ; le serveur revérifie).
- `AlerteVol` : gros texte cartoon rebondissant, épais avec contour — victime : « VOLÉ ! » en rouge + « {nom} a pris ta créature {Rareté} ! » ; voleur : « VOLÉ ! » en vert/jaune + « Ramène-la dans ta base ! ».
- Petit compteur à l'écran pour le propriétaire, lu depuis `VerrouJusqua` / `VerrouPretA` : « 🔒 42 s » pendant le verrou, « Prêt dans 30 s » pendant la recharge, caché sinon.

### Hors périmètre (ne pas modifier)
Règles du plaquage et des monstres (`src/shared/Plaquage.luau`, `Monstre.luau`), sauvegarde du verrou (non sauvegardé), Plan/.

## Comportement attendu
1. B entre dans la base de A, maintient « Voler » sur une créature exposée : elle disparaît de la base de A (et de sa sauvegarde, et de ses revenus) et apparaît au-dessus de la tête de B, qui ralentit comme pour un portage normal.
2. A voit « VOLÉ ! » en rouge avec le nom du voleur ; B voit « VOLÉ ! » et un billboard « VOLÉ ! » apparaît au-dessus de lui.
3. B rentre dans sa base : la créature est déposée (« Créature déposée ! ») et lui rapporte des pièces.
4. B porte déjà une créature : « Voler » ne fait rien.
5. B plaqué ou frappé par un monstre : la créature volée tombe et devient libre (récoltable par tous, dont A).
6. A, dans sa base, active « Verrouiller » avec ≥ 100 pièces : −100 pièces, bouclier rouge visible, panneau « VERROUILLÉ 60 s » qui décompte ; tout intrus est replacé devant la porte, y compris ceux qui tentent d'entrer pendant le verrou. A circule librement.
7. Après 60 s : bouclier caché, panneau « Prêt dans 60 s », puis « Verrouiller : 100 pièces ».

## Critères d'acceptation

### Unitaires (Lune, logique pure)
- **C1** `Config.Raid` existe avec `DureeVerrou == 60`, et `DistanceVol`, `DureeVol`, `Recharge`, `PrixVerrou`, `DistanceVerrou`, `DistanceExpulsion`, `DureeAlerte` sont des nombres > 0.
- **C2** `Raid.verifierVol` accepte un contexte valide (`distance = DistanceVol`) et renvoie, dans l'ordre de priorité, `"soi-même"`, `"indisponible"`, `"porte"`, `"base"`, `"verrouillee"`, `"creature"`, `"portee"` (distance > DistanceVol, NaN, `math.huge`).
- **C3** `Raid.verifierVol` refuse avec `"porte"` un voleur qui porte déjà une créature, même si tout le reste est valide.
- **C4** `Raid.verifierVerrou` accepte un propriétaire vivant, à portée, avec `pieces == PrixVerrou`, sans verrou ni recharge ; refuse avec `"proprietaire"`, `"indisponible"`, `"portee"`, `"verrouillee"`, `"recharge"`, `"pieces"` (pieces < prix, NaN, nil).
- **C5** `Raid.acheterVerrou(100)` renvoie `(160, 220)` avec les valeurs par défaut ; `Raid.estVerrouillee(159.9, 160)` vrai, `(160, 160)` faux, `(x, nil)` faux.
- **C6** `Raid.doitExpulser` n'est vrai que pour `(false, true, true)` (les 7 autres combinaisons sont fausses).
- **C7** `Raid.retirerEmplacement({"Commune","Rare","Epique"}, 2)` renvoie `{"Commune","Epique"}, "Rare"` sans modifier l'entrée ; numéros 0, 4, 1.5, nil, "2" → liste identique et `nil`.
- **C8** `Raid.texteVerrou` : `(100, 160, 220)` → `"VERROUILLÉ 60 s"` ; `(159.2, 160, 220)` → `"VERROUILLÉ 1 s"` ; `(170, 160, 220)` → `"Prêt dans 50 s"` ; `(220, 160, 220)` et `(0, nil, nil)` → `"Verrouiller : 100 pièces"`.

### En jeu (vrai serveur)
- **C9** Chaque créature exposée d'une base a un attribut `Emplacement` et un ProximityPrompt nommé `Voler` (ActionText « Voler », MaxActivationDistance = DistanceVol) ; chaque base a `Porte`, `BoutonVerrou` (prompt `Verrouiller`) et `Bouclier` (`CanCollide == false`).
- **C10** Vol réussi : voleur dans la base de la victime, à portée, ne portant rien → `Raids.voler` renvoie true, la victime a une créature de moins (`Sauvegarde.creaturesDe`, `RevenuParSeconde` mis à jour, créatures exposées réaffichées), le voleur a l'attribut `Porte` égal à la rareté volée.
- **C11** Vol refusé sans aucun changement : voleur hors de la base visitée, voleur = propriétaire, emplacement vide/inexistant, voleur trop loin.
- **C12** Un voleur qui porte déjà une créature ne peut pas en voler une deuxième : `Raids.voler` renvoie false, sa créature portée et la base de la victime sont inchangées.
- **C13** Dépôt : le voleur qui entre dans SA base avec la créature volée la dépose (`Sauvegarde.creaturesDe(voleur)` contient la rareté, `Porte` redevient nil).
- **C14** Un voleur plaqué (`Plaquages.plaquer`) ou frappé par un monstre (`Monstres.frapper`) lâche la créature volée : `Porte` nil, créature dans le dossier des créatures des Terres Sauvages avec `Libre == true`.
- **C15** Après un vol, la victime et le voleur reçoivent `AlerteVol` (rôles `"victime"` / `"voleur"`, bonne rareté) ; un billboard « VOLÉ ! » est ajouté au-dessus du voleur.
- **C16** Verrou acheté : `Raids.verrouiller` par le propriétaire avec assez de pièces renvoie true, retire exactement `PrixVerrou` pièces, fixe `VerrouJusqua = t + 60` et `VerrouPretA = t + 120`, rend le `Bouclier` visible (Transparency < 1).
- **C17** Verrou refusé sans changement : déclencheur ≠ propriétaire, pas assez de pièces, verrou déjà actif, en recharge (pièces inchangées).
- **C18** Pendant le verrou, `Raids.pas` replace un intrus présent dans la base hors de la base (`Bases.estDansBaseDe` devient faux) et laisse le propriétaire en place ; après `DureeVerrou` s, l'intrus n'est plus expulsé et le `Bouclier` est de nouveau invisible.
- **C19** Pendant le verrou, `Raids.voler` dans cette base est refusé (raison `"verrouillee"`), même si le voleur y est placé de force avant l'appel.
