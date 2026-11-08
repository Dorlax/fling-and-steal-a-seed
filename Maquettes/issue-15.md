# Maquette — issue #15 : Peaufinage interface et effets

Demande : [[08 Peaufinage interface et effets]]
Plan : [[Vision]] (section Ambiance), [[Règles du jeu]]
État actuel : [[État du jeu]]

## Objectif
Donner à toute l'interface le style de [[Vision]] : cartoon très coloré, gros textes
épais avec contour, gros boutons rebondissants, jauges en dégradé vert → jaune →
orange → rouge, nombres flottants, bandeaux de messages, panneaux lisibles de loin.
Lisible par un joueur de 9 ans sur PC, mobile et console.

**Aucune règle ne change** : aucune valeur de `Config` n'est modifiée, aucun fichier
de `src/server/` n'est modifié, aucun RemoteEvent n'est ajouté ni changé.
Tout se fait côté client (affichage), plus un module pur partagé pour les calculs
d'affichage (testable avec Lune).

## Fichiers

### À créer
- `src/shared/Style.luau` — module **pur** (aucune instance Roblox, aucun `Color3` :
  couleurs en tables RGB `{ r, g, b }` 0-255). Contient toutes les constantes et les
  calculs d'affichage (voir « Module Style »).
- `src/client/Habillage.luau` — fabrique d'éléments d'interface réutilisée par toutes
  les interfaces : `texte(...)`, `bouton(...)`, `jauge(...)`, `rebondir(...)`,
  `flotter(...)`, `apparaitre(...)` (animation d'apparition). Convertit les RGB de
  `Style` en `Color3`. Utilise `TweenService` pour toutes les animations.
- `src/client/Bandeaux.luau` — bandeau de messages unique (voir « Messages »).
- `src/client/Panneaux.luau` — restylage local des BillboardGui créés par le serveur
  (créatures, monstres, « BOUM ! » du plaquage).
- `tests/unitaires/C*_style_*.luau` — tests Lune (écrits par le Testeur).

### À modifier (client uniquement)
- `src/client/InterfaceLancer.luau` — bouton LANCER, jauge, polices.
- `src/client/InterfacePlaquage.luau` — bouton PLAQUER + jauge de recharge.
- `src/client/InterfaceStats.luau` — boutons Forge Force / Vitesse, textes.
- `src/client/InterfacePieces.luau` — compteur, « +N » flottant ; les messages
  `MessageJeu` passent par `Bandeaux` (sauf « BOUM ! »).
- `src/client/InterfaceRaid.luau` — « VOLÉ ! » passe par `Bandeaux` ; compteur du
  verrou avec jauge.
- `src/client/InterfacePieges.luau` — boutons de pièges + jauge de recharge.
- `src/client/Principal.client.luau` — démarre `Bandeaux` et `Panneaux`.

### À ne pas toucher
`src/server/**`, `src/shared/Config.luau` (valeurs), `Plan/`, les autres modules
partagés existants.

## Module Style (pur, `src/shared/Style.luau`)
Fonctions et constantes attendues (noms imposés, utilisés par les tests) :

- `Style.Police = "FredokaOne"` — police ronde unique pour tout le texte client.
  `Style.PoliceSecondaire = "FredokaOne"` (même police ; pas de Gotham).
- `Style.Contour = { Gros = 5, Moyen = 4, Petit = 3 }` — épaisseurs de `UIStroke`
  (noir). Aucun texte client n'a un contour < 3.
- `Style.TailleTexteMin = 18` — pixels ; `TextScaled` avec `UITextSizeConstraint`
  `MinTextSize >= 18` pour les textes d'information.
- `Style.TailleBoutonMin = 90` — pixels (côté le plus petit des boutons d'action
  tactiles : LANCER, PLAQUER, pièges, Forge).
- `Style.ArrondiBouton = 0.25` — `UICorner` en échelle (PLAQUER reste rond : 0.5).
- `Style.Degrade = { {0, Vert}, {1/3, Jaune}, {2/3, Orange}, {1, Rouge} }` avec
  Vert `{ 70, 220, 90 }`, Jaune `{ 255, 220, 40 }`, Orange `{ 255, 140, 30 }`,
  Rouge `{ 240, 50, 50 }`.
- `Style.couleurJauge(ratio: number) -> { r, g, b }` — interpolation linéaire dans
  `Style.Degrade` ; `ratio` borné à [0, 1] ; NaN / non-nombre → Vert.
- `Style.ratioRecharge(maintenant, pretA, duree) -> number` — part restante de la
  recharge dans [0, 1] : 0 si `pretA` absent/non-nombre/passé ou `duree <= 0`,
  sinon `(pretA - maintenant) / duree` borné à [0, 1].
- `Style.couleurRarete(rarete: string) -> { r, g, b }` — lit
  `Config.Raretes.Couleurs` ; rareté inconnue → blanc `{ 255, 255, 255 }`.
- `Style.couleurZone(zone: string) -> { r, g, b }` — danger des monstres :
  Proche = Vert, Moyenne = Orange, Lointaine = Rouge (du `Degrade`) ; inconnue → blanc.
- `Style.texteRarete(rarete: string) -> string` — nom affiché depuis
  `Config.Raretes.Noms` (inconnue → la chaîne reçue).
- `Style.Flottant = { Duree = 0.9, Montee = 40 }` — secondes, pixels.
- `Style.Rebond = { Echelle = 0.85, Duree = 0.3 }` — appui ; apparition : de 0 à 1
  en `Duree` avec `EasingStyle.Back`.
- `Style.Bandeau = { Duree = 2, Glisse = 0.3 }` — secondes d'affichage et de
  glissement (entrée et sortie).
- `Style.couleurBandeau(texte: string) -> { r, g, b }` — couleur de fond du bandeau :
  « VOLÉ » → Rouge ; « Base pleine » → Orange ; « Créature déposée » → Vert ;
  texte contenant « nuit » (sans tenir compte de la casse) → violet `{ 110, 70, 200 }` ;
  « jour » → Jaune ; autre → bleu `{ 60, 150, 255 }`.
- `Style.estBoum(texte) -> boolean` — vrai seulement pour exactement `"BOUM !"`.
- File de bandeaux pure :
  - `Style.nouvelleFile() -> File`
  - `Style.ajouter(file, texte, maintenant)` — ignore les non-chaînes et les
    chaînes vides ; tronque à 80 caractères ; si le même texte est déjà le dernier
    en attente, ne le rajoute pas ; au plus 3 messages en attente (le plus ancien
    en attente est retiré).
  - `Style.courant(file, maintenant) -> string?` — le message affiché à cet
    instant. Un message reste `Bandeau.Duree + 2 × Bandeau.Glisse` secondes, puis
    le suivant commence. **Jamais deux messages à la fois.**

## Comportement attendu

### 1. Plaquage : un seul « BOUM ! »
- Aujourd'hui : le serveur met un « BOUM ! » jaune (TextLabel `Boum` dans le
  BillboardGui `EffetPlaquage`) et le client du plaqueur affiche le « BOUM ! »
  blanc de `MessageJeu`.
- Après : `Panneaux` cache localement (`Visible = false`) tout TextLabel `Boum`
  d'un `EffetPlaquage` dès qu'il apparaît dans le Workspace. Les étoiles restent.
- Le « BOUM ! » de `MessageJeu` (`Style.estBoum`) n'entre **pas** dans la file des
  bandeaux : il s'affiche en gros texte blanc au centre, contour `Gros`, avec
  apparition rebondissante (échelle 0,3 → 1,2 → 1, `Back`), puis fondu après ~1 s.
- Résultat : un seul « BOUM ! » visible à l'écran du plaqueur.

### 2. Textes
- Tout texte créé côté client utilise `Enum.Font.FredokaOne` (aucun `Gotham*`).
- Tout texte client a un `UIStroke` noir d'épaisseur ≥ 3 (`Style.Contour`).
- Les textes d'information ont une taille minimale lisible sur mobile
  (`UITextSizeConstraint.MinTextSize >= Style.TailleTexteMin`).

### 3. Boutons
Boutons concernés : LANCER, PLAQUER, Forge Force / Vitesse, pièges (Filet, Glu,
Fausse graine). Pour « Récolter » et « Verrouiller » (ProximityPrompt créés par le
serveur) : `Panneaux` intercepte `ProximityPromptService.PromptShown` et, pour les
prompts `Recolter`, `Voler`, `Verrouiller`, passe localement `Style` à `Custom` et
affiche un gros bouton arrondi coloré (même fabrique `Habillage.bouton`) avec la
touche/le bouton manette et une jauge de maintien (`HoldDuration`) en dégradé.
Le serveur garde toute la validation (aucun changement de déclenchement).
- Couleurs franches : LANCER vert, PLAQUER orange, Force rouge, Vitesse bleu,
  pièges couleur de `Config.Pieges.Types`, Récolter jaune, Voler rouge,
  Verrouiller violet. Gris quand indisponible (comme aujourd'hui).
- `UICorner` (`Style.ArrondiBouton`, PLAQUER rond), `UIStroke` noir `Moyen`.
- Taille ≥ `Style.TailleBoutonMin` pour les boutons d'action.
- Animation à l'appui : `UIScale` à `Rebond.Echelle` puis retour à 1 (`Back`).
- Animation d'apparition : `UIScale` de 0 à 1 en `Rebond.Duree` à la création
  (et pour les prompts custom, à chaque `PromptShown`).
- Les touches clavier / manette existantes ne changent pas.

### 4. Jauges
- Jauge de lancer : `UIGradient` construit à partir de `Style.Degrade` (dégradé
  continu, vert en bas → rouge en haut). Les paliers de bonus de `Config` restent
  ceux du serveur ; seule la couleur affichée change.
- Nouvelles barres de recharge (sous ou dans le bouton) :
  - PLAQUER : `Style.ratioRecharge(now, PlaquagePretA, Config.Plaquage.DelaiRecuperation)`.
  - Pièges : `Style.ratioRecharge(now, PiegePretA, Config.Pieges.DelaiPose)`.
  - Verrou : pendant le verrou, `ratioRecharge(now, VerrouJusqua, Config.Raid.DureeVerrou)` ;
    pendant l'attente de rachat, `ratioRecharge(now, VerrouPretA, Config.Raid.Recharge)`.
  - Couleur de remplissage : `Style.couleurJauge(ratio)` ; barre cachée à 0.
- Les textes existants (« Prêt dans N s », « 🔒 N s ») restent, avec le nouveau style.

### 5. Nombres flottants
- « +N » des pièces (`InterfacePieces`) et tout nombre flottant client : police
  ronde, contour `Petit` minimum, montée de `Flottant.Montee` px et fondu (texte et
  contour) en `Flottant.Duree`, puis `Destroy`.
- Le « PAF ! » / dégâts reste l'effet serveur existant (non modifié).

### 6. Messages à l'écran (bandeaux)
- `Bandeaux` crée un seul bandeau en haut de l'écran (sous le compteur de pièces,
  au-dessus du message de lancer, sans le recouvrir) : `Frame` arrondie, fond
  `Style.couleurBandeau(texte)`, texte blanc contour `Moyen`.
- Le bandeau glisse depuis le côté (`Glisse`), reste `Duree`, glisse et disparaît.
- Les messages suivants attendent leur tour (`Style.ajouter` / `Style.courant`) :
  jamais deux bandeaux superposés.
- Passent par les bandeaux : tous les `MessageJeu` (« Créature déposée ! »,
  « Base pleine ! », « Personne à plaquer ! », nuit / jour, pièges…) sauf
  « BOUM ! », et l'alerte « VOLÉ ! » de `AlerteVol` (texte « VOLÉ ! » + la phrase
  actuelle selon le rôle, sur une ou deux lignes dans le même bandeau).
- L'ancien `Message` de `InterfacePieces` et le titre/sous-titre de
  `InterfaceRaid` ne s'affichent plus.
- Le message de résultat de lancer (« PERFECT ! », « +N m · Rareté ») garde son
  animation actuelle (célébration), avec le nouveau style de texte.

### 7. Panneaux des créatures et monstres
`Panneaux` surveille `Workspace.DescendantAdded` (et l'existant au démarrage) et
restyle localement chaque `BillboardGui` nommé `Panneau` :
- Créature (ancêtre `Model` avec attribut `Rarete`) — au sol, portée ou exposée
  en base : fond arrondi semi-opaque couleur `Style.couleurRarete`, texte blanc
  FredokaOne contour `Moyen`, panneau agrandi (au moins 1,5 × la taille actuelle),
  `MaxDistance` inchangée côté serveur mais `LightInfluence = 0`. Texte :
  - au sol / portée : `Style.texteRarete(rarete)` ;
  - exposée en base : `Style.texteRarete(rarete)` + revenu actuel (« +N/s ») sur
    une 2ᵉ ligne.
- Monstre (ancêtre `Model` avec attribut `Monstre = true`) : nom en blanc, fond
  arrondi `Style.couleurZone(zone)`, contour `Moyen`, agrandi de même.
- Le restylage ne modifie que des propriétés d'affichage locales ; il ne détruit
  rien et ne change aucun attribut.

## Critères d'acceptation
Tests Lune (`tests/unitaires`) sauf mention contraire.

- **C1** `Style.couleurJauge` : 0 → Vert, 1/3 → Jaune, 2/3 → Orange, 1 → Rouge
  (exacts) ; 1/6 est strictement entre Vert et Jaune ; -1 → Vert ; 2 → Rouge ;
  NaN et `"x"` → Vert.
- **C2** `Style.ratioRecharge` : `(10, 13, 6)` → 0,5 ; `(10, 9, 6)` → 0 ;
  `(10, nil, 6)` → 0 ; `(10, 30, 6)` → 1 ; `(10, 13, 0)` → 0 ; NaN → 0.
- **C3** `Style.couleurRarete` renvoie exactement `Config.Raretes.Couleurs[r]` pour
  les 5 raretés de `Config.Raretes.Ordre`, et blanc pour `"Inconnue"` ;
  `Style.texteRarete("Epique") == "Épique"`.
- **C4** `Style.couleurZone` : Proche = Vert, Moyenne = Orange, Lointaine = Rouge,
  inconnue = blanc.
- **C5** `Style.estBoum("BOUM !")` vrai ; faux pour `"BOUM"`, `"boum !"`,
  `"Personne à plaquer !"`, `nil`, `5`.
- **C6** File de bandeaux — un seul à la fois : après `ajouter(A, t=0)` et
  `ajouter(B, t=0.1)`, `courant(t=1) == A` ; `courant(t = Duree + 2×Glisse + 0.01) == B` ;
  à aucun instant échantillonné (pas de 0,05 s sur 10 s) `courant` ne renvoie
  autre chose qu'un seul texte ou nil ; après la fin de B, `courant == nil`.
- **C7** File de bandeaux — robustesse : `ajouter` ignore `nil`, `""`, `42` ; un
  texte de 200 caractères est tronqué à 80 ; deux `ajouter` identiques à la suite
  ne donnent qu'un seul message ; au plus 3 messages en attente (le plus ancien en
  attente est retiré).
- **C8** `Style.couleurBandeau` : « VOLÉ ! » → Rouge, « Base pleine ! » → Orange,
  « Créature déposée ! » → Vert, un texte contenant « nuit » / « Nuit » → violet,
  un texte contenant « jour » / « Jour » → Jaune, « Personne à plaquer ! » → bleu.
  Ordre de test : VOLÉ, Base pleine, Créature déposée, nuit, jour, sinon bleu.
- **C9** Constantes : `Style.Police == "FredokaOne"` et c'est un nom valide
  d'`Enum.Font` (liste fixe vérifiée dans le test) ; toutes les épaisseurs de
  `Style.Contour` ≥ 3 ; `Style.TailleBoutonMin >= 90` ; `Style.TailleTexteMin >= 18` ;
  `Style.Flottant.Duree > 0` et `Montee > 0` ; `Style.Bandeau.Duree > 0`.
- **C10** Polices client (test Lune qui lit les fichiers avec `@lune/fs`) : aucun
  fichier de `src/client/` ne contient `Enum.Font.Gotham`.
- **C11** Un seul « BOUM ! » (lecture statique) : `src/client/Panneaux.luau`
  contient la gestion de `EffetPlaquage` / `Boum` (cache le label), et
  `src/client/InterfacePieces.luau` utilise `Style.estBoum` pour ne pas envoyer
  « BOUM ! » aux bandeaux.
- **C12** Animations (lecture statique) : `src/client/Habillage.luau` utilise
  `TweenService`, `UIScale`, `UICorner` et `UIStroke` ; chaque fichier
  `InterfaceLancer`, `InterfacePlaquage`, `InterfaceStats`, `InterfacePieges`
  utilise `Habillage` (require).
- **C13** Règles inchangées : `Config` garde ses valeurs (vérifier au moins
  `Plaquage.DelaiRecuperation == 6`, `Raid.DureeVerrou == 60`,
  `Pieges.DelaiPose == 5`, `Lancer.Jauge.Paliers` = 4 paliers aux mêmes `Min` et
  `Bonus`, taux de rareté du Plan), et tous les tests existants (unitaires et
  en jeu) passent sans modification.
- **C14** En jeu (`tests/en-jeu`) : le serveur démarre normalement et `Style` se
  charge depuis `ReplicatedStorage.Shared` sans erreur ; `Style.couleurJauge(0.5)`
  renvoie une table de 3 nombres dans [0, 255].

## Vérification manuelle (rapport Contexte)
Plaquer un porteur : un seul « BOUM ! » blanc qui rebondit ; enchaîner dépôt +
« Base pleine ! » + nuit : bandeaux l'un après l'autre ; panneaux lisibles de loin
et colorés par rareté ; boutons qui rebondissent sur mobile (émulateur) et manette.
