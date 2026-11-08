# Maquette : issue #7 (Plaquage)

Demande : [[04 Plaquage]]
Plan : [[Vision]] (Interactions entre joueurs : plaquage), [[Règles du jeu]]
Dépend de : [[issue-5]] (portage des créatures), [[issue-3]] (créatures au sol)

## Objectif
Un joueur peut plaquer un joueur proche qui porte une créature. Le porteur lâche
la créature à côté de lui (récoltable par n'importe qui, y compris le plaqueur),
tombe au sol un court instant, puis est protégé contre un nouveau plaquage
pendant quelques secondes. Un bouton à l'écran (PC, mobile, console) déclenche
l'action ; portée, délai et cible sont décidés et vérifiés par le serveur.
Effet cartoon : « BOUM ! » et étoiles au-dessus de la tête de la cible.

## Interprétation de « pas de plaquage dans sa propre base »
Les deux cas sont refusés :
- le plaqueur se trouve dans sa propre base ;
- la cible se trouve dans sa propre base (elle y est à l'abri, par exemple quand
  elle attend avec « Base pleine ! »).

## Fichiers à modifier / créer
- `src/shared/Config.luau` : nouvelle section `Plaquage`.
- `src/shared/Plaquage.luau` (nouveau, module pur testable avec Lune) :
  règles de validation, choix de la cible, texte du bouton.
- `src/server/Plaquages.luau` (nouveau) : traitement serveur du plaquage
  (délais, mise au sol, protection, effet visuel).
- `src/server/Portage.luau` : `Portage.lacherParPlaquage(joueur)` et récolte
  des créatures « libres » par n'importe qui.
- `src/server/Principal.server.luau` : RemoteEvent `Plaquer`, nettoyage au départ.
- `src/client/InterfacePlaquage.luau` (nouveau) + `src/client/Principal.client.luau` :
  bouton à l'écran et raccourcis clavier / manette.
- `default.project.json` : RemoteEvent `Plaquer` dans ReplicatedStorage.
- Ne pas toucher à `Plan/`.

## Réglages (Config.Plaquage)
| Clé | Valeur | Rôle |
|---|---|---|
| `Portee` | 8 | studs max entre les deux HumanoidRootPart |
| `DelaiRecuperation` | 6 | secondes entre deux plaquages réussis du même joueur |
| `DureeAuSol` | 1.5 | secondes pendant lesquelles la cible reste au sol |
| `DureeProtection` | 4 | secondes pendant lesquelles la cible ne peut pas être replaquée (≥ DureeAuSol) |
| `DistanceChute` | 4 | studs entre la cible et la créature lâchée |
| `DureeVieLachee` | 60 | secondes avant disparition d'une créature lâchée non récoltée |
| `IntervalleMinRequetes` | 0.2 | secondes : requêtes plus rapprochées ignorées (anti-spam) |
| `Touches` | `{ Clavier = "F", Manette = "ButtonY" }` | noms d'`Enum.KeyCode` (E et ButtonX sont déjà pris par « Récolter ») |

## Comportement attendu

### Module pur `Shared/Plaquage`
- `Plaquage.verifier(contexte) -> (boolean, string?)` : renvoie `true` ou
  `false` + une raison courte. `contexte` contient des valeurs simples :
  `memeJoueur`, `plaqueurVivant`, `plaqueurAuSol`, `plaqueurDansSaBase`,
  `cibleVivante`, `ciblePorte` (booléen), `cibleDansSaBase`, `distance`,
  `maintenant`, `pretA` (fin du délai du plaqueur, ou nil),
  `protegeeJusqua` (fin de protection de la cible, ou nil).
  Ordre des refus (première raison trouvée) :
  1. `memeJoueur` -> « soi-même » ; 2. plaqueur mort ou au sol -> « indisponible » ;
  3. `maintenant < pretA` -> « recuperation » ; 4. plaqueur dans sa base -> « base » ;
  5. cible morte ou ne porte rien -> « cible » ; 6. cible dans sa base -> « base » ;
  7. `maintenant < protegeeJusqua` -> « protegee » ;
  8. `distance` non fini ou > `Portee` -> « portee ». Sinon `true`.
  La distance exactement égale à `Portee` est acceptée.
- `Plaquage.choisirCible(candidats) -> number?` : `candidats` est une liste de
  `{ distance, valide }` ; renvoie l'indice du candidat valide le plus proche
  (égalité : le premier), ou nil.
- `Plaquage.texteBouton(maintenant, pretA) -> string` : « PLAQUER ! » si prêt
  (`pretA` nil ou dépassé), sinon le nombre de secondes restantes arrondi
  au supérieur (« 3 »).

### Serveur
- RemoteEvent `Plaquer` (client -> serveur) : **tous les arguments sont ignorés**.
  Le serveur choisit lui-même la cible : le joueur porteur valide le plus proche
  (via `Plaquage.verifier` + `Plaquage.choisirCible`). Joueur non chargé
  (`Sauvegarde.estCharge`) ou requête à moins de `IntervalleMinRequetes`
  de la précédente : ignorée.
- API testable : `Plaquages.plaquer(plaqueur, candidats: {Player}?, maintenant: number?) -> Player?`
  (renvoie la cible plaquée ou nil ; `candidats` par défaut = `Players:GetPlayers()`,
  `maintenant` par défaut = `Workspace:GetServerTimeNow()`),
  `Plaquages.traiterRequete(joueur, ...)` (branché sur `Plaquer.OnServerEvent`,
  ignore `...` et appelle `plaquer(joueur)`), et `Plaquages.nettoyer(joueur)`.
- Pas de cible valide : rien ne change, le délai n'est **pas** consommé,
  message « Personne à plaquer ! » via `MessageJeu`.
- Plaquage réussi :
  - `Portage.lacherParPlaquage(cible)` : la créature est désoudée, posée au
    sol à `DistanceChute` studs de la cible (côté opposé au plaqueur), placée
    dans le dossier des créatures des Terres Sauvages, ProximityPrompt
    « Récolter » réactivé, attribut `Libre = true` ; elle ne fait plus partie
    des créatures au sol d'aucun joueur. Attribut `Porte` de la cible effacé,
    vitesse normale réappliquée.
  - Une créature `Libre` peut être récoltée par **n'importe quel** joueur
    (mêmes vérifications de distance que d'habitude) ; à la récolte, `Libre`
    est effacé et `Proprietaire` devient le récolteur. Une créature non libre
    reste réservée à son propriétaire.
  - Une créature libre non récoltée est détruite après `DureeVieLachee`.
  - Cible : `Humanoid.PlatformStand = true` et attribut `AuSol = true` pendant
    `DureeAuSol`, puis remis à `false` / nil (si le personnage existe encore).
  - Cible protégée jusqu'à `maintenant + DureeProtection` ; attribut
    `ProtegeJusqua` (temps serveur) pour l'affichage.
  - Plaqueur : prochain plaquage possible à `maintenant + DelaiRecuperation` ;
    attribut `PlaquagePretA` (temps serveur) pour le bouton.
  - Effet : un `BillboardGui` nommé `EffetPlaquage` sur la tête (ou la racine)
    de la cible, texte « BOUM ! » gros, épais, avec contour, et au moins trois
    étoiles « ★ » qui tournent ; détruit après `DureeAuSol`. Message
    « BOUM ! » au plaqueur et « Tu t'es fait plaquer ! » à la cible.
- Départ d'un joueur : `Plaquages.nettoyer` efface ses délais / protections.

### Client (`InterfacePlaquage`)
- Gros bouton rond coloré « PLAQUER ! » (`ScreenGui` `InterfacePlaquage`,
  bouton `BoutonPlaquer`) en bas à droite, assez grand pour le tactile.
- `ContextActionService` : touche `Config.Plaquage.Touches.Clavier` (F) et
  `Config.Plaquage.Touches.Manette` (ButtonY) ; clic / toucher du bouton.
  Chaque déclenchement envoie `Plaquer:FireServer()` sans argument.
- Pendant le délai : bouton grisé, texte = `Plaquage.texteBouton(Workspace:GetServerTimeNow(), PlaquagePretA)`.
- Petit rebond du bouton à l'appui (animation cartoon).

## Critères d'acceptation

### Tests unitaires (Lune)
- **C1** `Config.Plaquage` contient toutes les clés du tableau avec des nombres
  > 0, et `DureeProtection >= DureeAuSol`.
- **C2** `Config.Plaquage.Touches.Clavier` vaut « F » et `Manette` vaut
  « ButtonY » (ni « E » ni « ButtonX », réservés à la récolte).
- **C3** `Plaquage.verifier` accepte un contexte valide et refuse avec
  « cible » quand la cible ne porte rien ou est morte.
- **C4** `Plaquage.verifier` refuse avec « portee » au-delà de `Portee` (et pour
  une distance NaN ou infinie) et accepte à exactement `Portee`.
- **C5** `Plaquage.verifier` refuse avec « recuperation » quand
  `maintenant < pretA` et accepte quand `maintenant >= pretA`.
- **C6** `Plaquage.verifier` refuse avec « protegee » quand
  `maintenant < protegeeJusqua`, et accepte après.
- **C7** `Plaquage.verifier` refuse avec « base » si le plaqueur est dans sa
  base, et aussi si la cible est dans sa base.
- **C8** `Plaquage.verifier` refuse avec « soi-même » (`memeJoueur`) et
  « indisponible » (plaqueur mort ou au sol).
- **C9** `Plaquage.choisirCible` renvoie l'indice du candidat valide le plus
  proche, ignore les invalides, renvoie nil pour une liste vide ou sans valide.
- **C10** `Plaquage.texteBouton` renvoie « PLAQUER ! » si `pretA` est nil ou
  dépassé, et « 3 » pour 2,1 s restantes.

### Tests en jeu (vrai serveur, faux joueurs comme dans C7_portage)
- **C11** Le RemoteEvent `Plaquer` existe dans ReplicatedStorage et le module
  serveur `Plaquages` expose `plaquer`, `traiterRequete` et `nettoyer`.
- **C12** Plaquage réussi : A à 5 studs de B qui porte une créature ;
  `Plaquages.plaquer(A, {B}, t)` renvoie B ; l'attribut `Porte` de B est nil ;
  la créature est dans le dossier des créatures, `Libre = true`, prompt activé,
  à environ `DistanceChute` studs de B (± 1,5).
- **C13** La créature lâchée est récoltable par le plaqueur
  (`Portage.recolter(A, creature)` renvoie true, `Proprietaire` = A) ; dans un
  second essai, elle l'est aussi par un troisième joueur C. Une créature non
  libre appartenant à B reste refusée à A.
- **C14** Après le plaquage, B a `AuSol = true` et `PlatformStand = true` ;
  après `DureeAuSol` (+ marge), les deux sont revenus à l'état normal.
- **C15** Protection : B recharge une créature et un autre plaqueur C
  (sans délai) essaie à `t + 1` -> nil ; à `t + DureeProtection + 0,1` -> B.
- **C16** Délai : A ne peut pas plaquer une autre cible valide à
  `t + DelaiRecuperation - 0,1` (nil) mais le peut à `t + DelaiRecuperation`.
  `PlaquagePretA` de A vaut `t + DelaiRecuperation`.
- **C17** Portée et cible : B porteur à `Portee + 1` studs -> nil et rien ne
  change ; B ne portant rien à 3 studs -> nil ; un échec ne pose pas de délai
  (`PlaquagePretA` inchangé).
- **C18** Bases : A dans sa propre base ne peut pas plaquer B porteur à portée
  (nil) ; B porteur dans sa propre base ne peut pas être plaqué (nil).
- **C19** Effet : juste après le plaquage, un `BillboardGui` `EffetPlaquage`
  existe sur le personnage de B, contient un texte « BOUM ! » et au moins trois
  « ★ » ; il a disparu après `DureeAuSol` (+ marge).
- **C20** Le serveur ignore les arguments du client :
  `Plaquages.traiterRequete(A, B)` avec B porteur hors de portée ne plaque
  personne (B porte toujours sa créature).
- **C21** Une créature libre non récoltée est détruite après `DureeVieLachee`
  (test avec une durée réduite injectée, ou vérification que la destruction
  est programmée via un attribut `DisparaitA`).
- **C22** Non-régression : la mort d'un porteur fait toujours retomber la
  créature non libre (réservée à son propriétaire), et `stylua`, `selene`,
  `lune run tests/lanceur` et `rojo build` réussissent.
