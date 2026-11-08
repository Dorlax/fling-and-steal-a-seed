# Maquette : issue #5 « Porter et revenus »

Demande : [[03 Porter et revenus]]
Plan : [[Vision]] (boucle de jeu, étapes 3 et 4), [[Règles du jeu]]

## Objectif
Fermer la boucle de jeu : après un lancer, le joueur **récolte** sa créature
dans les Terres Sauvages, la **porte** jusqu'à sa base en marchant un peu plus
lentement, puis la **dépose** dans sa base où elle rapporte des **pièces en
continu** selon sa rareté. Les pièces sont affichées en grand et sauvegardées,
ainsi que les créatures de la base.

Hors périmètre (mises à jour suivantes du Plan) : plaquage, raids, pièges,
monstres, dépenses de pièces, passes Robux.

## Règles appliquées
- Tout est décidé par le serveur : récolte, portage, dépôt, revenus, pièces.
  Le client n'envoie aucune valeur (ni rareté, ni position, ni montant).
- Chaque action a un bouton à l'écran : la récolte passe par un
  `ProximityPrompt` (bouton tactile sur mobile, touche sur PC, bouton sur
  manette). Le dépôt est automatique en entrant dans sa base.
- Pièces et créatures de la base sont sauvegardées (DataStore).

## Réglages (src/shared/Config.luau, nouvelle section `Creatures`)
| Réglage | Valeur |
|---|---|
| `DistanceRecolte` | 10 studs (vérifiée par le serveur) |
| `DureeRecolte` | 0,5 s (maintien du ProximityPrompt) |
| `MultiplicateurPortage` | 0,8 (WalkSpeed × 0,8 pendant le portage) |
| `MaxCreaturesBase` | 10 emplacements par base |
| `IntervalleRevenus` | 1 s |
| `RevenuParSeconde` | Commune 1, Rare 3, Epique 10, Legendaire 30, Mythique 100 |
| `PiecesMax` | 1e15 (plafond de sécurité) |

## Fichiers à modifier / créer
- `src/shared/Config.luau` : section `Creatures` ci-dessus.
- `src/shared/Revenus.luau` (nouveau, module pur Lune) :
  - `Revenus.parSeconde(rarete): number` → 0 si rareté inconnue ;
  - `Revenus.total(listeRaretes): number` → somme des revenus ;
  - `Revenus.ajouter(pieces, gain): number` → pièces + gain, entier,
    jamais négatif, plafonné à `PiecesMax`, ignore les valeurs non finies ;
  - `Revenus.walkSpeedPortage(walkSpeed): number` → walkSpeed × multiplicateur.
- `src/shared/Donnees.luau` : `DonneesJoueur` gagne `Pieces: number` (défaut 0)
  et `CreaturesBase: { string }` (défaut `{}`). `nettoyer` : pièces entières,
  finies, ≥ 0, plafonnées ; liste filtrée aux raretés valides de
  `Config.Raretes.Ordre`, tronquée à `MaxCreaturesBase`.
- `src/server/Portage.luau` (nouveau) : récolte, portage, dépôt.
  - Chaque créature au sol reçoit un `ProximityPrompt` « Récolter »
    (`HoldDuration = DureeRecolte`, `MaxActivationDistance = DistanceRecolte`).
  - `Portage.recolter(joueur, creature): boolean` — accepte seulement si :
    la créature est au sol dans `TerresSauvages.dossierCreatures()`,
    son attribut `Proprietaire` = `joueur.UserId`, le joueur est vivant,
    à ≤ `DistanceRecolte` (vérifié serveur), ne porte rien déjà, et la
    créature n'est pas déjà portée.
  - Portage : la créature est sortie de la liste « au sol » de `Lancers`
    (elle n'est plus détruite par `MaxCreaturesAuSol`), désancrée et soudée
    (`WeldConstraint`) au-dessus de la tête du personnage, `CanCollide = false`,
    `Massless = true`. Attribut joueur `Porte` = rareté portée (ou nil).
    Le ProximityPrompt est désactivé pendant le portage.
  - `Portage.verifierDepot(joueur)` (appelé à chaque tick) : si le joueur porte
    une créature et que son `HumanoidRootPart` est au-dessus du sol de SA base
    (même test de boîte que la Forge, sur la partie `Sol`), la créature est
    déposée : ajoutée à `CreaturesBase`, affichée sur un emplacement de la base,
    attribut `Porte` effacé, WalkSpeed rétabli.
    Base pleine (`MaxCreaturesBase`) : dépôt refusé, la créature reste portée,
    message « Base pleine ! » envoyé au client.
  - Mort du personnage en portant : la créature retombe au sol à la position
    du personnage, redevient récoltable par son propriétaire, et retourne dans
    la liste « au sol » de `Lancers`.
  - Départ du joueur : créature portée détruite (comme celles au sol).
- `src/server/Lancers.luau` : expose `Lancers.retirerDuSol(joueur, creature)`
  et `Lancers.remettreAuSol(joueur, creature)` ; `creerCreature` ajoute le
  ProximityPrompt (ou Portage s'en charge via une fonction appelée ici).
- `src/server/Bases.luau` : `Bases.solDe(joueur)`, `Bases.estDansSaBase(joueur)`,
  et `Bases.afficherCreatures(joueur, listeRaretes)` qui place une petite
  créature (même apparence : couleur de rareté, yeux, panneau « +N/s ») par
  emplacement, en rangée le long du bord de la base, sans recouvrir la Forge
  ni le point d'apparition.
- `src/server/Entrainement.luau` : `appliquerVitesse` applique
  `Revenus.walkSpeedPortage` si l'attribut `Porte` est défini.
- `src/server/Sauvegarde.luau` : attributs `Pieces` et `RevenuParSeconde`
  écrits au chargement ; `CreaturesBase` gardée dans la session ;
  `collecter` inclut `Pieces` et `CreaturesBase`. Fonctions
  `Sauvegarde.creaturesDe(joueur)` et `Sauvegarde.ajouterCreature(joueur, rarete): boolean`.
- `src/server/Principal.server.luau` : branche les ProximityPrompts, appelle
  `Portage.verifierDepot` et la boucle de revenus toutes les
  `IntervalleRevenus` (seulement pour les joueurs chargés), nettoie au départ,
  affiche les créatures de la base après chargement.
- `default.project.json` : RemoteEvent `MessageJeu` (serveur → client,
  messages courts : « Base pleine ! », « Créature déposée ! »).
- `src/client/InterfacePieces.luau` (nouveau) : compteur de pièces en haut
  au centre, gros texte épais avec contour, lit l'attribut `Pieces` ; à chaque
  hausse, un « +N » flotte et s'efface ; ligne « +X / s » sous le compteur
  (attribut `RevenuParSeconde`) ; affiche les messages `MessageJeu`.
  Démarré par `Principal.client.luau`.

## Comportement attendu
1. Le joueur lance une graine ; sa créature apparaît avec un bouton
   « Récolter » visible de près (lui seul peut l'activer).
2. Il maintient le bouton : la créature passe au-dessus de sa tête, il marche
   à 80 % de sa vitesse normale.
3. Il entre dans sa base : la créature y est déposée, s'affiche sur un
   emplacement, sa vitesse redevient normale, message « Créature déposée ! ».
4. Chaque seconde, ses pièces augmentent de la somme des revenus de ses
   créatures ; le compteur affiche un « +N » flottant.
5. Il quitte puis revient : pièces et créatures de base sont restaurées.

## Critères d'acceptation
- **C1** `Revenus.parSeconde` renvoie 1, 3, 10, 30, 100 pour Commune, Rare,
  Epique, Legendaire, Mythique, et 0 pour une rareté inconnue ou non-chaîne.
- **C2** `Revenus.total({"Commune","Rare","Mythique"})` = 104 ; liste vide = 0 ;
  les entrées invalides comptent 0.
- **C3** `Revenus.ajouter` : 10 + 5 = 15 ; résultat entier ; jamais négatif ;
  plafonné à `PiecesMax` ; un gain NaN, infini ou non numérique laisse les
  pièces inchangées.
- **C4** `Revenus.walkSpeedPortage(20)` = 16 (multiplicateur 0,8) et le
  résultat est toujours strictement inférieur à l'entrée pour une entrée > 0.
- **C5** `Donnees.parDefaut()` contient `Pieces = 0` et `CreaturesBase = {}`.
- **C6** `Donnees.nettoyer` : pièces négatives, NaN, infinies ou texte → 0 ;
  pièces décimales → arrondies vers le bas ; `CreaturesBase` non-table → `{}` ;
  raretés invalides retirées ; liste tronquée à `MaxCreaturesBase` ;
  les anciennes données sans ces champs restent valides (Force, Vitesse
  conservées).
- **C7** (en jeu) Récolte valide : le propriétaire, à moins de
  `DistanceRecolte`, récolte sa créature → `recolter` renvoie true, attribut
  `Porte` = rareté, la créature n'est plus dans le dossier des créatures au sol.
- **C8** (en jeu) Récoltes refusées : un autre joueur (UserId différent),
  un joueur trop loin, ou un joueur qui porte déjà une créature → `recolter`
  renvoie false et rien ne change.
- **C9** (en jeu) Pendant le portage, le WalkSpeed vaut
  `Forge.walkSpeedPour(Vitesse) × 0,8` ; après le dépôt il revient à
  `Forge.walkSpeedPour(Vitesse)`.
- **C10** (en jeu) Dépôt : un joueur qui porte une créature et se trouve dans
  sa base → `Porte` effacé, `CreaturesBase` contient la rareté,
  `RevenuParSeconde` mis à jour, un modèle de créature apparaît dans la base.
  Hors de sa base (ou dans la base d'un autre), rien n'est déposé.
- **C11** (en jeu) Base pleine : avec `MaxCreaturesBase` créatures en base,
  le dépôt est refusé et la créature reste portée.
- **C12** (en jeu) Revenus : après un tick de revenus, `Pieces` augmente
  exactement de `Revenus.total(CreaturesBase)` ; sans créature, `Pieces`
  ne change pas.
- **C13** (en jeu) Une créature portée n'est pas détruite par la limite
  `MaxCreaturesAuSol` quand le joueur relance d'autres graines.
- **C14** (en jeu) Mort en portant : la créature retombe au sol, `Porte` est
  effacé et la créature est de nouveau récoltable par son propriétaire.
- **C15** (en jeu) Sauvegarde : les données collectées pour la sauvegarde
  contiennent `Pieces` et `CreaturesBase` à jour ; un chargement de données
  contenant ces champs les restaure (attribut `Pieces`, créatures affichées).
- **C16** (en jeu) Le client ne peut rien forcer : les RemoteEvents existants
  ne modifient ni `Pieces` ni `CreaturesBase`, et aucun RemoteEvent client →
  serveur n'est ajouté pour la récolte ou le dépôt (récolte via
  `ProximityPrompt.Triggered`, validé serveur).
- **C17** Interface : `InterfacePieces` crée un compteur lisant l'attribut
  `Pieces` et un texte « +X / s » ; `Principal.client.luau` la démarre.
  (Vérifiable par test en jeu sur le module ou par lecture du code.)
