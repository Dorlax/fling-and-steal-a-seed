---
issue: https://github.com/Dorlax/fling-and-steal-a-seed/issues/13
demande: "[[07 Pièges]]"
---
# Maquette : Pièges (issue #13)

Liens : [[07 Pièges]] · [[Vision]] · [[Règles du jeu]]

## Objectif
Les joueurs posent trois pièges dans les Terres Sauvages pour gêner les
autres pendant le trajet risqué (cf. [[Vision]] : « Pièges : filet, flaque de
glu, fausse graine ») :
- **Filet** : immobilise la victime quelques secondes ;
- **Flaque de glu** : ralentit fortement tant qu'on est dedans ;
- **Fausse graine** : ressemble à une graine posée au sol ; qui la « récolte »
  est immobilisé brièvement.

Chaque piège coûte des pièces, est limité en nombre par joueur, a un délai
entre deux poses et une durée de vie. Le poseur n'est jamais affecté par ses
propres pièges ; une victime est protégée quelques secondes après avoir été
piégée ; une victime qui porte une créature **la garde**. Tout est décidé et
vérifié par le serveur ([[Règles du jeu]] : pièces gérées par le serveur ;
chaque action a un bouton à l'écran sur PC, mobile et console).

## Réglages (src/shared/Config.luau, nouvelle section `Pieges`)
```lua
Pieges = {
	Ordre = { "Filet", "Glu", "FausseGraine" },
	Types = {
		Filet = { Nom = "Filet", Prix = 50, Couleur = { 255, 140, 30 }, Duree = 3 },
		Glu = { Nom = "Glu", Prix = 40, Couleur = { 120, 255, 60 }, Multiplicateur = 0.3, Rayon = 6 },
		FausseGraine = { Nom = "Fausse graine", Prix = 60, Couleur = { 255, 215, 60 }, Duree = 2 },
	},
	MaxParJoueur = 3, -- pièges actifs par joueur, tous types confondus
	DelaiPose = 5, -- secondes entre deux poses du même joueur
	DureeVie = 90, -- secondes avant disparition d'un piège non déclenché
	DureeProtection = 4, -- secondes d'immunité après la fin d'un effet
	RayonDeclenchement = 4, -- studs (filet) entre la racine du joueur et le piège
	DistanceRecolteFausse = 10, -- studs (= Creatures.DistanceRecolte)
	EcartMin = 6, -- studs minimum entre deux pièges (tous poseurs)
	MargeBases = 6, -- pose interdite à Z < BordBases + MargeBases
	IntervalleBoucle = 0.1, -- secondes entre deux passages de la boucle serveur
	IntervalleMinRequetes = 0.2, -- anti-spam de PoserPiege
	-- Noms d'Enum.KeyCode (F, E, ButtonX, ButtonY, ButtonR2 sont déjà pris).
	Touches = {
		Clavier = { Filet = "Z", Glu = "X", FausseGraine = "C" },
		Manette = { Filet = "DPadLeft", Glu = "DPadUp", FausseGraine = "DPadRight" },
	},
},
```
Les valeurs sont des points de départ ; le Bâtisseur ne les change pas sans
raison, les tests lisent Config plutôt que des nombres en dur.

## Fichiers
| Fichier | Action |
|---|---|
| `src/shared/Config.luau` | ajouter la section `Pieges` ci-dessus |
| `src/shared/Piege.luau` | **nouveau** module pur (Lune) : validations et calculs |
| `src/server/Pieges.luau` | **nouveau** : pose, déclenchement, effets, boucle, nettoyage |
| `src/server/Entrainement.luau` | `appliquerVitesse` tient compte des effets de piège |
| `src/server/Principal.server.luau` | RemoteEvent `PoserPiege`, `Pieges.demarrer()`, `Pieges.nettoyer` au départ |
| `default.project.json` | déclarer `PoserPiege` (RemoteEvent) dans ReplicatedStorage |
| `src/client/InterfacePieges.luau` | **nouveau** : 3 boutons + touches clavier/manette |
| `src/client/Principal.client.luau` | `InterfacePieges.demarrer()` |
| `tests/unitaires/…`, `tests/en-jeu/…` | écrits par le Testeur |

Ne pas toucher à Portage, Plaquages, Raids, Monstres, Lancers (sauf lecture
de leurs fonctions publiques existantes).

## Module pur `src/shared/Piege.luau`
Même style que `Plaquage.luau` (`--!strict`, require compatible Lune,
nombres non finis / `nil` traités comme invalides).

- `Piege.estType(valeur: any): boolean` — vrai seulement pour une chaîne de
  `Config.Pieges.Ordre`.
- `Piege.verifierPose(contexte): (boolean, string?)` — contexte :
  `{ typePiege: any, vivant: boolean, immobilise: boolean, pieces: any,
  actifs: number, maintenant: number, pretA: number?, position: {X,Y,Z},
  dansUneBase: boolean, distancePlusProche: number? }`.
  Raisons, dans cet ordre : `"type"`, `"indisponible"` (mort ou immobilisé),
  `"delai"`, `"limite"` (actifs ≥ MaxParJoueur), `"pieces"` (pièces non
  finies ou < prix), `"zone"` (dans une base, ou hors des Terres Sauvages :
  Z < BordBases + MargeBases, Z > BordBases + DistanceMax + 40, |X| > 400),
  `"ecart"` (distancePlusProche < EcartMin). Sinon `true, nil`.
  `BordBases` = `Config.Monstres.BordBases`.
- `Piege.peutAffecter(contexte): (boolean, string?)` — contexte :
  `{ memePoseur: boolean, vivante: boolean, maintenant: number,
  protegeeJusqua: number?, immobileJusqua: number? }`.
  Raisons : `"poseur"`, `"morte"`, `"protegee"` (maintenant < protegeeJusqua),
  `"deja"` (maintenant < immobileJusqua). Sinon `true, nil`.
- `Piege.estExpire(poseA: number, maintenant: number): boolean` —
  vrai si `maintenant >= poseA + DureeVie` (valeurs invalides → `true`).
- `Piege.dansRayon(distance: any, rayon: number): boolean` — distance finie
  et `<= rayon`.
- `Piege.walkSpeed(base: number, immobilise: boolean, englue: boolean): number`
  — `0` si immobilisé ; sinon `base × Glu.Multiplicateur` si englué ; sinon `base`.
  Le résultat n'est jamais négatif ni NaN (base invalide → `Forge.WalkSpeedBase`).
- `Piege.texteBouton(typePiege: string, maintenant: number, pretA: number?,
  actifs: number): string` — `"<Nom> <Prix>"` (ex. « Filet 50 ») si prêt ;
  les secondes restantes arrondies au supérieur pendant le délai ; `"MAX"` si
  `actifs >= MaxParJoueur`.

## Serveur `src/server/Pieges.luau`
API (les paramètres `maintenant` optionnels servent uniquement aux tests en
jeu ; le gestionnaire du RemoteEvent ne les transmet jamais) :
- `Pieges.poser(joueur, typePiege: any, maintenant: number?): Model?`
- `Pieges.declencherFausse(joueur, piege: Model, maintenant: number?): boolean`
- `Pieges.pas(maintenant: number?)` — expiration, filets, glu, fin d'effets.
- `Pieges.traiterRequete(joueur, typePiege: any, ...)` — anti-spam
  (`os.clock`, IntervalleMinRequetes) puis `poser` ; tout autre argument ignoré.
- `Pieges.actifsDe(joueur): number`, `Pieges.dossier(): Folder`
  (`Workspace.Pieges`), `Pieges.demarrer()`, `Pieges.nettoyer(joueur)`.

### Pose
1. Le client n'envoie que le nom du type (`PoserPiege:FireServer("Filet")`).
   Toute autre valeur (nombre, table, position…) est refusée par `estType`.
2. La position est calculée par le serveur : sous la `HumanoidRootPart` du
   poseur, posée à la surface du sol (Y = 0 des Terres Sauvages).
3. `dansUneBase` = `Bases.proprietaireDeBaseOu(joueur) ~= nil`.
4. Si `Piege.verifierPose` accepte : retirer `Prix` à l'attribut `Pieces`,
   noter `pretA = maintenant + DelaiPose` (attribut `PiegePretA` du joueur),
   créer le modèle dans `Workspace.Pieges` avec les attributs `Type`,
   `PoseA`, et `PoseurId` (UserId) ; mettre à jour l'attribut
   `PiegesActifs` du joueur. Message au poseur : « Piège posé ! Hé hé hé… ».
5. Sinon : aucun débit, aucun modèle, message selon la raison
   (« Pas assez de pièces ! », « Pas dans une base ! », « Trop de pièges ! »,
   « Patiente un peu… », « Trop près d'un autre piège ! »).

### Apparence (cartoon, couleurs vives de Config)
- Filet : disque plat orange avec quadrillage (Neon fin), légèrement visible.
- Glu : grande flaque verte brillante de diamètre `2 × Rayon`, `CanCollide = false`.
- Fausse graine : même gabarit et même `ProximityPrompt` « Récolter »
  (`MaxActivationDistance = DistanceRecolteFausse`, `HoldDuration =
  Creatures.DureeRecolte`) qu'une graine/créature au sol, couleur dorée
  lumineuse. Rien dans son nom visible ni son texte ne dit « fausse ».
- Toutes les pièces : `Anchored = true`, `CanCollide = false`.

### Déclenchement (boucle `pas`, toutes les IntervalleBoucle s)
Pour chaque joueur vivant et chaque piège, avec `Piege.peutAffecter`
(`memePoseur` = UserId du joueur == `PoseurId`) :
- **Filet** : si la racine est à ≤ RayonDeclenchement (distance horizontale)
  et `peutAffecter` → immobiliser `Filet.Duree` s, détruire le filet.
- **Glu** : si la racine est à ≤ `Glu.Rayon` (horizontal) et `peutAffecter` →
  attribut `Englue = true` (ralenti). Dès qu'il sort de toutes les glus
  (ou qu'elles expirent) → `Englue = nil`, protection
  `maintenant + DureeProtection`. La glu n'est pas consommée.
- **Fausse graine** (ProximityPrompt.Triggered → `declencherFausse`) : le
  serveur revérifie la distance (≤ DistanceRecolteFausse) et `peutAffecter` ;
  si accepté → immobiliser `FausseGraine.Duree` s, détruire la fausse graine.
  Le poseur qui active sa propre fausse graine n'est pas affecté (message
  « C'est ta propre fausse graine ! ») et elle reste en place.
- **Immobiliser** : attribut `ImmobileJusqua = maintenant + Duree` ; à la
  fin, attribut retiré et `ProtegePiegeJusqua = fin + DureeProtection`.
  Pendant l'immobilisation : `WalkSpeed = 0`, `JumpPower`/`JumpHeight = 0`
  (restaurés ensuite).
- Après chaque début/fin d'effet : `Entrainement.appliquerVitesse(joueur)`.
- **La créature portée est gardée** : aucun appel à `Portage.lacher*`,
  l'attribut `Porte` est inchangé.
- Expiration : tout piège avec `Piege.estExpire` est détruit (petit « pouf »).
- Les monstres ne déclenchent jamais de piège.

### Effets et messages comiques
- Filet : BillboardGui « PRIS AU FILET ! » + filet orange au-dessus de la
  tête pendant l'effet ; victime : « Gigote, gigote ! Tu es pris au filet ! » ;
  poseur : « Ton filet a attrapé <Nom> ! ».
- Glu : « SPLOTCH ! » vert ; victime : « Beurk ! Tu colles ! ».
- Fausse graine : « HA HA ! FAUSSE GRAINE ! » ; victime : « Oups, c'était une
  fausse graine ! » ; poseur : « <Nom> a mordu à l'hameçon ! ».
- Messages par le RemoteEvent existant `MessageJeu`.

### Départ et nettoyage
`Pieges.nettoyer(joueur)` : détruit tous ses pièges, oublie délais,
protections et effets. Les pièges ne sont pas sauvegardés.

## Vitesse (`Entrainement.appliquerVitesse`)
Calcul : `Forge.walkSpeedPour(Vitesse)` → ×portage si `Porte` →
`Piege.walkSpeed(…, ImmobileJusqua actif, Englue == true)`. Le portage reste
appliqué avec la glu (les deux se cumulent).

## Client `src/client/InterfacePieges.luau`
- Trois gros boutons colorés (≥ 90 px, tactile) en colonne à gauche de
  l'écran, chacun avec icône/couleur du piège et `Piege.texteBouton`
  (prix, délai restant via `PiegePretA`, « MAX » via `PiegesActifs`).
- Clic/tap, touche clavier (`Touches.Clavier`) ou manette
  (`Touches.Manette`) → `PoserPiege:FireServer(type)`, rien d'autre.
- Petit rebond (Tween) à l'appui ; grisé pendant le délai ou à MAX.
- Pendant `ImmobileJusqua` : texte rebondissant « PIÉGÉ ! » au centre.

## Critères d'acceptation
Unitaires (Lune, `Piege` + `Config`) :
- **C1** `Config.Pieges` contient Filet, Glu et FausseGraine, chacun avec un
  `Prix` > 0 ; `MaxParJoueur`, `DelaiPose`, `DureeVie`, `DureeProtection` > 0 ;
  `Glu.Multiplicateur` est strictement entre 0 et 1 ; `Filet.Duree` et
  `FausseGraine.Duree` > 0.
- **C2** `Piege.estType` accepte les trois noms et refuse `nil`, `"Bombe"`,
  `1`, `{}`.
- **C3** `Piege.verifierPose` accepte un contexte valide et renvoie
  respectivement `"pieces"` (pièces < prix ou NaN), `"limite"` (actifs =
  MaxParJoueur), `"delai"` (maintenant < pretA), `"zone"` (dans une base ;
  Z < BordBases + MargeBases), `"ecart"` et `"indisponible"`.
- **C4** `Piege.peutAffecter` renvoie `false, "poseur"` pour le poseur,
  `false, "protegee"` pendant la protection, `false, "deja"` pendant une
  immobilisation, et `true` une fois la protection finie.
- **C5** `Piege.walkSpeed` : 0 si immobilisé ; `base × Multiplicateur` si
  englué ; `base` sinon ; jamais négatif ni NaN (base NaN/`nil` →
  `Forge.WalkSpeedBase` éventuellement multiplié).
- **C6** `Piege.estExpire` : faux juste avant `poseA + DureeVie`, vrai à
  partir de cette valeur et pour des entrées invalides.
- **C7** `Piege.texteBouton` : « Filet 50 » (nom + prix de Config) si prêt,
  « 3 » à 2,2 s du délai, « MAX » si actifs ≥ MaxParJoueur.

En jeu (serveur réel, `tests/en-jeu`) :
- **C8** Pose valide dans les Terres Sauvages : le prix est débité, un modèle
  apparaît dans `Workspace.Pieges` avec `Type`, `PoseurId`, `PoseA` ;
  `PiegesActifs` et `PiegePretA` sont mis à jour.
- **C9** Pose refusée dans sa base (ou toute base), avec trop peu de pièces,
  pendant le délai, au-delà de `MaxParJoueur`, ou avec un type invalide
  (`123`, `{}`, `"Bombe"`) : aucun débit, aucun nouveau modèle.
- **C10** `traiterRequete` ignore tout argument en plus du type (une position
  envoyée par le client n'est pas utilisée : le piège est sous le poseur).
- **C11** Filet : un autre joueur à ≤ RayonDeclenchement est immobilisé
  (`ImmobileJusqua` posé, WalkSpeed 0) puis libéré après `Filet.Duree`
  (WalkSpeed restauré), le filet est détruit.
- **C12** Glu : WalkSpeed = vitesse normale × Multiplicateur tant que la
  victime est dedans, restauré dès qu'elle en sort ; la glu reste en place.
- **C13** Fausse graine : `declencherFausse` par un autre joueur à portée
  l'immobilise `FausseGraine.Duree` s et détruit le piège ; hors portée →
  refus, piège intact.
- **C14** Le poseur n'est affecté par aucun de ses pièges (filet, glu,
  fausse graine) et ses pièges restent en place.
- **C15** Protection : juste après la fin d'un effet, la même victime sur un
  second filet n'est pas affectée ; après `DureeProtection`, elle l'est.
- **C16** Une victime qui porte une créature la garde : attribut `Porte`
  inchangé après filet, glu et fausse graine ; aucune créature lâchée.
- **C17** Un piège non déclenché disparaît après `DureeVie` (`pas` avec un
  `maintenant` avancé) et `PiegesActifs` diminue.
- **C18** `Pieges.nettoyer(joueur)` détruit tous ses pièges et efface ses
  effets (plus d'`ImmobileJusqua` ni d'`Englue`).
- **C19** Client : `InterfacePieges` crée trois boutons (un par type) dans le
  PlayerGui, et `default.project.json` déclare le RemoteEvent `PoserPiege`
  (vérifiable par la présence de `ReplicatedStorage.PoserPiege` en jeu).
