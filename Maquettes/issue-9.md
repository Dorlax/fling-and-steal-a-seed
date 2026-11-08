# Maquette — issue #9 : Monstres

Demande : [[05 Monstres]]
Plan : [[Vision]] (Interactions entre joueurs, Ambiance), [[Règles du jeu]]

## Objectif
Des monstres comiques rôdent dans les Terres Sauvages. Plus on s'éloigne de la
base (zones Proche, Moyenne, Lointaine), plus ils sont nombreux, rapides et
forts. Leur coup fait lâcher la créature portée (elle tombe à côté du joueur,
récoltable par tous) et le joueur est ensuite protégé quelques secondes.
Un monstre n'entre jamais dans une base. Un cycle jour/nuit simple amène
régulièrement une nuit plus sombre (mais cartoon) avec des vagues de monstres
plus nombreuses. Tout (apparition, déplacement, coups, dégâts, cycle) est
décidé par le serveur ; le client n'envoie rien pour les monstres.

## Fichiers à modifier / créer
| Fichier | Rôle |
|---|---|
| `src/shared/Config.luau` | Nouvelle section `Config.Monstres` et `Config.Cycle` (voir plus bas). |
| `src/shared/Monstre.luau` (nouveau) | Logique pure testable avec Lune : zone d'une position, réglages d'une zone, limite « jamais dans une base », validation d'un coup, choix de cible, nombre de monstres voulu, cycle jour/nuit. Même style de `require` que `Plaquage.luau`. |
| `src/server/Monstres.luau` (nouveau) | Création des modèles, boucle de déplacement (modèles ancrés déplacés par CFrame), coups, vagues de nuit, nettoyage. Dossier `Workspace.Monstres`. |
| `src/server/CycleJourNuit.luau` (nouveau) | Applique la phase (jour/nuit) à `Lighting`, met l'attribut `Nuit` sur `Workspace`, prévient les joueurs (`MessageJeu`). |
| `src/server/Portage.luau` | Ajouter `Portage.lacher(joueur, depuis, maintenant)` = comportement actuel de `lacherParPlaquage` (créature « Libre », à `DistanceChute` studs, disparaît après `DureeVieLachee`). `lacherParPlaquage` devient un simple appel à `lacher` (aucun changement pour le plaquage). |
| `src/server/Principal.server.luau` | Démarrer `CycleJourNuit` et `Monstres` ; appeler `Monstres.nettoyer(joueur)` au départ d'un joueur. |

Aucun changement côté client n'est nécessaire (le joueur n'a aucune nouvelle
action : rien à ajouter en boutons). Les messages passent par `MessageJeu`
déjà existant ; l'éclairage est répliqué par Roblox.

## Réglages (Config)
```lua
Monstres = {
	BordBases = 20,         -- Z du bord des bases (= début des Terres Sauvages)
	MargeBases = 6,         -- un monstre reste toujours à Z >= BordBases + MargeBases
	IntervalleIA = 0.1,     -- secondes entre deux pas de la boucle serveur
	DureeProtection = 3,    -- secondes sans pouvoir être refrappé par un monstre
	DistanceDisparition = 120, -- un monstre qui poursuit au-delà revient à son point d'apparition
	-- Par zone (mêmes noms que Config.Lancer.Zones), valeurs croissantes :
	Zones = {
		Proche    = { Nom = "Gloupinou",  Couleur = {120, 230, 255}, Taille = 4, Vitesse = 10, Degats = 10, PorteeDetection = 30, PorteeCoup = 5, Recharge = 2.0, NombreJour = 2, NombreNuit = 4 },
		Moyenne   = { Nom = "Ronchonbulle", Couleur = {255, 170, 60}, Taille = 5, Vitesse = 13, Degats = 20, PorteeDetection = 40, PorteeCoup = 6, Recharge = 1.6, NombreJour = 3, NombreNuit = 6 },
		Lointaine = { Nom = "Grobidou",   Couleur = {200, 90, 255}, Taille = 6, Vitesse = 16, Degats = 30, PorteeDetection = 50, PorteeCoup = 7, Recharge = 1.2, NombreJour = 4, NombreNuit = 9 },
	},
	IntervalleVague = 30,   -- la nuit, une vague complète les zones toutes les 30 s
},
Cycle = {
	DureeJour = 240,        -- secondes
	DureeNuit = 120,        -- secondes
	HeureJour = 14,         -- Lighting.ClockTime
	HeureNuit = 0,
},
```
Les noms des monstres sont originaux. La vitesse des monstres reste inférieure
à `Forge.WalkSpeedMax` (50) : un joueur entraîné en Vitesse peut fuir.

## Comportement attendu

### Zones et limite des bases
- Zone d'une position = `Lancer.zone(position.Z - BordBases)` (mêmes seuils que
  les lancers : Proche < 150, Moyenne < 300, Lointaine au-delà).
- `Monstre.limiter(position)` renvoie la position avec `Z` ramené à au moins
  `BordBases + MargeBases` et `X`/`Z` gardés dans le sol des Terres Sauvages.
  Chaque pas de déplacement passe par cette fonction : un monstre ne pénètre
  jamais dans une base, même en poursuivant un joueur qui s'y réfugie.
- Chaque monstre appartient à la zone où il est apparu et n'en sort pas
  (`Z` borné à sa zone) : les monstres forts restent loin.

### Apparition (serveur)
- Points d'apparition tirés au hasard par le serveur dans la bande de la zone.
- `Monstre.nombreVoulu(zone, nuit)` = `NombreJour` le jour, `NombreNuit` la nuit.
- Au démarrage puis régulièrement, le serveur complète chaque zone jusqu'au
  nombre voulu. La nuit, une vague est lancée à la tombée de la nuit puis toutes
  les `IntervalleVague` secondes. Au lever du jour, les monstres en trop
  disparaissent (petit effet « pouf ») jusqu'au nombre de jour.

### Apparence (cartoon, 9 ans et plus)
- Modèle `Monstre` : corps en boule (`Ball`, couleur vive de la zone,
  `SmoothPlastic`), deux gros yeux blancs avec pupilles noires, petite bouche
  souriante ou langue tirée, pas de dents pointues ni de sang.
- Panneau au-dessus : nom du monstre (police `FredokaOne`, contour noir).
- Attributs : `Zone`, `Monstre = true`. Tous les parts sont `Anchored`,
  `CanCollide = false` (les monstres ne poussent pas les joueurs physiquement).
- Petit rebond vertical quand il avance (effet visuel seulement).

### Déplacement et cible (serveur)
- Toutes les `IntervalleIA` secondes, chaque monstre :
  - cherche avec `Monstre.choisirCible` le joueur valide le plus proche à moins de
    `PorteeDetection` : vivant, hors de sa base, non protégé, dans les Terres
    Sauvages ;
  - s'il en a un, avance vers lui de `Vitesse × IntervalleIA` studs ; sinon il
    erre vers un point aléatoire de sa zone ;
  - s'il poursuit à plus de `DistanceDisparition` de son point d'apparition,
    il abandonne et y retourne.

### Coup
- `Monstre.peutFrapper(contexte)` renvoie `true` ou `false, raison` (comme
  `Plaquage.verifier`), raisons : `"indisponible"` (cible morte / sans
  personnage), `"base"` (cible dans sa base), `"protegee"`, `"recharge"`
  (monstre en recharge), `"portee"` (distance > `PorteeCoup` ou non finie).
- Coup réussi :
  1. `Humanoid:TakeDamage(Degats de la zone)` (dégâts décidés par le serveur).
  2. Si le joueur portait une créature : `Portage.lacher(joueur, positionDuMonstre)` —
     elle tombe à `Plaquage.DistanceChute` studs, du côté opposé au monstre,
     attribut `Libre = true`, récoltable par n'importe qui, disparaît après
     `DureeVieLachee`.
  3. Protection : `protection[joueur] = maintenant + DureeProtection`, et
     attribut `ProtegeMonstreJusqua` sur le joueur.
  4. Recharge du monstre : `maintenant + Recharge`.
  5. Effet « PAF ! » jaune au-dessus du joueur et message
     « Un monstre t'a frappé ! » (ou « … tu as lâché ta créature ! »).
- Si les dégâts tuent le joueur, la règle existante de `Portage` (mort = la
  créature retombe) s'applique ; le joueur réapparaît dans sa base.

### Cycle jour/nuit
- `Monstre.phase(t)` (t = `Workspace:GetServerTimeNow()`) renvoie
  `"Jour"` ou `"Nuit"` et le temps restant : `t % (DureeJour + DureeNuit)` ;
  les `DureeJour` premières secondes sont le jour.
- Jour : `Lighting.ClockTime = HeureJour`, éclairage actuel.
- Nuit : `Lighting.ClockTime = HeureNuit`, `Ambient` et `OutdoorAmbient`
  bleu-violet profond (ex. `(70, 60, 130)`), `Brightness` réduite mais
  terrain bien visible ; les yeux des monstres brillent (`Neon`).
- `Workspace:SetAttribute("Nuit", true/false)`. Au changement :
  messages « La nuit tombe… les monstres arrivent en nombre ! » et
  « Le jour se lève ! ».

### Départ d'un joueur
- `Monstres.nettoyer(joueur)` oublie sa protection ; les monstres qui le
  ciblaient en choisissent un autre.

## Critères d'acceptation
Tests unitaires (Lune, `src/shared/Monstre.luau` et `Config`) :
- **C1** `Config.Monstres.Zones` contient exactement Proche, Moyenne, Lointaine ;
  `Vitesse`, `Degats`, `PorteeDetection`, `NombreJour`, `NombreNuit` sont
  strictement croissants de Proche à Lointaine, et `Recharge` décroissante.
- **C2** Pour chaque zone, `NombreNuit > NombreJour` et
  `Vitesse < Config.Forge.WalkSpeedMax`.
- **C3** `Monstre.zoneDe(Vector-like {X, Y, Z})` : Z = BordBases + 10 → Proche,
  BordBases + 200 → Moyenne, BordBases + 400 → Lointaine.
- **C4** `Monstre.limiter` : pour toute position de départ (Z négatif, Z = 0,
  Z = BordBases, Z très grand, NaN), le Z renvoyé est fini et
  `>= BordBases + MargeBases` ; une position déjà valide est inchangée.
- **C5** `Monstre.peutFrapper` renvoie `false` avec la bonne raison pour :
  cible morte (`"indisponible"`), cible dans sa base (`"base"`), cible
  protégée (`"protegee"`), monstre en recharge (`"recharge"`), distance
  > `PorteeCoup` ou NaN (`"portee"`) ; et `true` sinon.
- **C6** `Monstre.choisirCible` renvoie l'indice du candidat valide le plus
  proche dans `PorteeDetection`, ou `nil` s'il n'y en a aucun.
- **C7** `Monstre.nombreVoulu(zone, false) == NombreJour` et
  `Monstre.nombreVoulu(zone, true) == NombreNuit` pour les trois zones.
- **C8** `Monstre.phase` : t = 0 → Jour ; t = DureeJour − 1 → Jour ;
  t = DureeJour → Nuit ; t = DureeJour + DureeNuit → Jour (cycle).

Tests en jeu (`tests/en-jeu`, vrai serveur) :
- **C9** Après démarrage (jour), `Workspace.Monstres` contient
  `NombreJour` monstres par zone, chacun avec l'attribut `Zone` et un pivot
  dans la bande de cette zone.
- **C10** Un joueur qui porte une créature, frappé par un monstre à portée :
  il ne porte plus rien (`Portage.porte` faux), la créature est dans
  `Workspace.Creatures` avec `Libre = true`, à environ `DistanceChute` studs du
  joueur, et sa vie a baissé de `Degats` de la zone.
- **C11** Juste après ce coup, un second coup (monstre sans recharge) est
  refusé avec `"protegee"` ; il réussit après `DureeProtection`.
- **C12** Un monstre qui poursuit un joueur placé dans sa base, après de
  nombreux pas de la boucle, n'a jamais `Z < BordBases + MargeBases`, et ne
  frappe pas le joueur (raison `"base"`).
- **C13** En forçant la nuit (`maintenant` fourni au module), `Workspace`
  a l'attribut `Nuit = true`, `Lighting.ClockTime == HeureNuit`, et après une
  vague chaque zone compte `NombreNuit` monstres ; en revenant au jour, chaque
  zone redescend à `NombreJour`.
- **C14** Un client qui envoie n'importe quel RemoteEvent existant ne peut ni
  créer, ni déplacer, ni faire frapper un monstre : le module ne crée aucun
  RemoteEvent (aucun nouvel objet `RemoteEvent` dans `ReplicatedStorage`).

Les fonctions serveur acceptent un `maintenant` optionnel (comme
`Plaquages.plaquer`) uniquement pour les tests ; il n'est jamais lu depuis
le client.
