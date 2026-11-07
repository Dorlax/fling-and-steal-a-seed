# Maquette — issue #1 : Forge et stats

Demande : [[01 Forge et stats]]
Plan : [[Vision]] (section « La Forge »), [[Règles du jeu]]

## Objectif
Poser la première brique de la boucle de jeu : chaque joueur a une base avec
une Forge. Debout sur la Forge, la stat du mode choisi (Force ou Vitesse)
monte en continu, même sans toucher aux commandes (AFK). Les deux stats sont
affichées à l'écran, sauvegardées entre deux sessions, et la Vitesse modifie
réellement la vitesse de course du personnage.

## Hors périmètre (demandes suivantes)
- Niveaux de Forge achetés en pièces, entraînement double (60 % / 60 %),
  gain hors ligne : on prévoit seulement le champ `NiveauForge` (= 1).
- Pièces, graines, créatures, passes Robux (x2 Force / x2 Vitesse).
- Lancer de graine (usage de la Force) : demande 02.

## Fichiers à créer / modifier
| Fichier | Rôle |
|---|---|
| `src/shared/Config.luau` | Ajouter la table `Forge` (réglages ci-dessous). |
| `src/shared/Forge.luau` (nouveau) | Logique pure : modes, gain, plafond, conversion Vitesse → WalkSpeed. |
| `src/shared/Donnees.luau` (nouveau) | Logique pure : données par défaut et nettoyage des données chargées. |
| `src/server/Sauvegarde.luau` (nouveau, ModuleScript) | Chargement / sauvegarde DataStore (`PlayerAdded`, `PlayerRemoving`, `BindToClose`), avec `pcall` et nouvelles tentatives. |
| `src/server/Bases.luau` (nouveau, ModuleScript) | Crée une base par joueur (emplacement libre) avec une Forge (Part ancrée, nommée `Forge`). Libère l'emplacement au départ. |
| `src/server/Principal.server.luau` | Démarre Sauvegarde, Bases, la boucle d'entraînement, le RemoteEvent `ChoisirModeForge`, et applique le WalkSpeed. |
| `src/client/Principal.client.luau` | Affiche l'interface (stats + boutons de mode). |
| `src/client/InterfaceStats.luau` (nouveau, ModuleScript) | ScreenGui : Force, Vitesse, mode actif, indicateur « Entraînement en cours ». |

Les noms de modules peuvent être ajustés par le Bâtisseur s'il le justifie,
mais les fonctions pures citées dans les critères doivent exister.

## Réglages (`Config.Forge`)
- `Modes = { "Force", "Vitesse" }`, mode par défaut `"Force"`.
- `IntervalleSecondes = 1` : un gain par seconde passée sur la Forge.
- `GainParTick = 1` (niveau 1).
- `PlafondStat = 1000` (niveau 1).
- `WalkSpeedBase = 16`, `WalkSpeedParPointVitesse = 0.02`,
  `WalkSpeedMax = 50` (16 + 0.02 × 1000 = 36 au plafond, borné à 50).
- `DistanceForge` : le joueur est « sur la Forge » si son HumanoidRootPart est
  au-dessus de la plateforme de la Forge (zone ≈ 8 × 8 studs, hauteur ≤ 6 studs).

## Comportement attendu

### Données du joueur
`{ Force = 0, Vitesse = 0, ModeForge = "Force", NiveauForge = 1 }`.
Les données chargées sont nettoyées : valeurs non numériques, négatives, NaN
ou au‑dessus du plafond corrigées ; mode inconnu → mode par défaut ; champs
manquants complétés. Les stats sont exposées au client par des attributs du
`Player` (`Force`, `Vitesse`, `ModeForge`, `SurForge`), écrits uniquement par
le serveur.

### Forge
- Chaque joueur reçoit une base avec une Forge à son arrivée.
- Toutes les `IntervalleSecondes`, le serveur vérifie pour chaque joueur s'il
  est vivant et sur **sa propre** Forge ; si oui, la stat du mode actif gagne
  `GainParTick`, sans dépasser `PlafondStat`. Aucune action du joueur n'est
  nécessaire (AFK compris).
- Hors de la Forge, rien ne monte. `SurForge` reflète l'état.

### Choix du mode
- Le client envoie `ChoisirModeForge:FireServer(mode)` via deux boutons à
  l'écran (« Force », « Vitesse ») — utilisables au doigt, à la souris et à la
  manette.
- Le serveur n'accepte que `"Force"` ou `"Vitesse"` (type `string`) ; toute
  autre valeur est ignorée. Le client n'envoie jamais de valeur de stat.

### Vitesse de course
- À chaque changement de Vitesse et à chaque apparition du personnage, le
  serveur fixe `Humanoid.WalkSpeed = Forge.walkSpeedPour(Vitesse)`.

### Interface
- Affiche « Force : N », « Vitesse : N », le mode actif mis en évidence, et un
  indicateur quand `SurForge` est vrai. Mise à jour via
  `GetAttributeChangedSignal`.

### Sauvegarde
- DataStore `JoueursV1`, clé `"joueur_" .. UserId`.
- Chargement à l'arrivée (en cas d'échec : données par défaut et **pas de
  sauvegarde** pour ce joueur durant la session, pour ne pas écraser).
- Sauvegarde au départ, à l'arrêt du serveur (`BindToClose`) et toutes les
  60 s. Les échecs sont journalisés, jamais bloquants.

## Critères d'acceptation

Tests unitaires (Lune, `tests/unitaires/`) :

- **C1** `Forge.estModeValide("Force")` et `Forge.estModeValide("Vitesse")`
  renvoient `true` ; `"Vol"`, `""`, `nil`, `42` et `{}` renvoient `false`.
- **C2** `Forge.appliquerGain(stats, "Force", config)` augmente `Force` de
  `GainParTick` et ne change pas `Vitesse` ; idem en mode `"Vitesse"`.
- **C3** `Forge.appliquerGain` ne dépasse jamais `PlafondStat` (stat à
  `PlafondStat - 0.5` puis un tick → exactement `PlafondStat` ; au plafond →
  inchangée).
- **C4** `Forge.appliquerGain` avec un mode invalide ne modifie aucune stat.
- **C5** `Forge.walkSpeedPour(0) == WalkSpeedBase`, la fonction est croissante
  (`walkSpeedPour(500) > walkSpeedPour(100)`), et ne dépasse jamais
  `WalkSpeedMax` (même pour `math.huge`) ; une valeur négative ou NaN donne
  `WalkSpeedBase`.
- **C6** `Donnees.parDefaut()` renvoie `Force = 0`, `Vitesse = 0`,
  `ModeForge = "Force"`, `NiveauForge = 1`, et deux appels renvoient deux
  tables distinctes.
- **C7** `Donnees.nettoyer(brut)` : `nil` → données par défaut ; Force
  `"abc"`, `-5` ou NaN → `0` ; Vitesse au‑dessus du plafond → plafond ;
  `ModeForge = "Triche"` → `"Force"` ; champ manquant → valeur par défaut ;
  valeurs valides conservées.
- **C8** `Config.Forge` contient `Modes`, `IntervalleSecondes > 0`,
  `GainParTick > 0`, `PlafondStat > 0`, `WalkSpeedBase`, `WalkSpeedMax`
  ≥ `WalkSpeedBase`.

Tests en jeu (`tests/en-jeu/`, serveur réel) :

- **C9** Le serveur expose un `RemoteEvent` nommé `ChoisirModeForge` dans
  `ReplicatedStorage`.
- **C10** La création d'une base pour un joueur (ou un faux joueur de test)
  produit une Part `Forge` ancrée dans le Workspace, et la libération supprime
  la base.
- **C11** La fonction serveur de traitement du mode (`traiterChoixMode(joueur,
  valeur)` ou équivalent exposé pour les tests) accepte `"Vitesse"` et rejette
  `"Triche"`, `123` et `nil` sans erreur ni changement.
- **C12** Un tick d'entraînement serveur sur un joueur marqué « sur la Forge »
  augmente la stat du mode actif ; un tick pour un joueur hors Forge ne change
  rien.
- **C13** Après modification de la Vitesse, le `WalkSpeed` appliqué au
  personnage (ou calculé par la fonction serveur d'application) vaut
  `Forge.walkSpeedPour(Vitesse)`.

Vérification manuelle (Studio, notée dans la PR) :
- **C14** Debout sur la Forge sans toucher aux commandes, la stat du mode
  actif monte à l'écran ; en descendant, elle s'arrête ; les deux boutons de
  mode marchent à la souris et au tactile ; après déconnexion/reconnexion (API
  Services activées) les stats sont retrouvées.

## Respect des règles
- Stats calculées et sauvegardées côté serveur uniquement ; le client
  n'envoie qu'un nom de mode, validé ([[Règles du jeu]]).
- Une seule machine, deux modes ([[Règles du jeu]], [[Vision]]).
- Boutons à l'écran pour chaque action (PC, mobile, console).
- Sauvegarde DataStore entre deux sessions.
- Noms et visuels originaux.
