--!strict
-- Configuration partagée du jeu (module pur : testable avec Lune).
local Config = {
	NomDuJeu = "Fling & Steal a Seed",
	Version = "0.1.0",

	-- Réglages de la Forge (niveau 1).
	Forge = {
		Modes = { "Force", "Vitesse" },
		ModeParDefaut = "Force",
		IntervalleSecondes = 0.25, -- 4 gains par seconde passée sur la Forge
		GainParTick = 1,
		PlafondStat = 1e300, -- aucune limite réelle (seulement les nombres valides)
		WalkSpeedBase = 16,
		WalkSpeedParPointVitesse = 0.02,
		-- Au-delà de StatLineaire, chaque doublement de la stat ajoute un palier
		-- (distance : un biome ; vitesse : WalkSpeedParDoublement).
		StatLineaire = 1000,
		WalkSpeedParDoublement = 20,
		WalkSpeedMax = 1e9, -- aucune limite réelle : le joueur va aussi vite qu'il veut
		-- Niveaux de Forge achetés en pièces. Gain par seconde : suite 1, 2, 5,
		-- 10, 20, 50, 100… (× GainParTick) ; coût du niveau n -> n + 1 =
		-- CoutBase × CroissanceCout^(n - 1).
		Niveaux = { CoutBase = 100, CroissanceCout = 1.9 },
		-- Paliers : l'agrès se modernise avec le niveau de la Forge.
		Paliers = {
			{
				Niveau = 1,
				Nom = "Rustique",
				Vitesse = "Roue en bois",
				Force = "Gros rocher",
				Double = "Corde lumineuse",
			},
			{
				Niveau = 4,
				Nom = "Club",
				Vitesse = "Tapis de course",
				Force = "Haltères",
				Double = "Corde lumineuse",
			},
			{
				Niveau = 8,
				Nom = "Pro",
				Vitesse = "Tapis pro",
				Force = "Barre olympique",
				Double = "Corde lumineuse",
			},
			{
				Niveau = 12,
				Nom = "Futur",
				Vitesse = "Piste néon",
				Force = "Barre plasma",
				Double = "Corde laser",
			},
			{
				Niveau = 18,
				Nom = "Cosmique",
				Vitesse = "Piste cosmique",
				Force = "Météorite",
				Double = "Anneau cosmique",
			},
		},
		-- Zone « sur la Forge » : au-dessus de la plateforme (studs).
		DistanceForge = {
			Largeur = 8,
			Hauteur = 6,
		},
		-- Mode « Double » : Force et Vitesse à la fois, chacune à Part du gain,
		-- débloqué à partir du niveau de Forge NiveauMin.
		Double = { NiveauMin = 12, Part = 0.6 },
	},

	-- Passes Robux autorisés par le propriétaire (Plan/Règles du jeu.md).
	-- Id = 0 : passe pas encore créé sur Roblox (bouton « Bientôt »).
	Passes = {
		Ordre = { "X2Force", "X2Vitesse", "X2Pieces", "RamassageAuto" },
		Liste = {
			X2Force = {
				Nom = "× 2 Force",
				Detail = "La Forge donne deux fois plus de Force.",
				Id = 0,
				Couleur = { 255, 110, 80 },
			},
			X2Vitesse = {
				Nom = "× 2 Vitesse",
				Detail = "La Forge donne deux fois plus de Vitesse.",
				Id = 0,
				Couleur = { 80, 170, 255 },
			},
			X2Pieces = {
				Nom = "× 2 Pièces",
				Detail = "Ta base rapporte deux fois plus de pièces.",
				Id = 0,
				Couleur = { 255, 200, 60 },
			},
			RamassageAuto = {
				Nom = "Ramassage auto",
				Detail = "Passe sur tes créatures : elles sont récoltées toutes seules.",
				Id = 0,
				Couleur = { 120, 220, 120 },
			},
		},
		IntervalleRamassage = 0.3, -- secondes entre deux vérifications
	},

	-- Lancer de graine vers les Terres Sauvages.
	Lancer = {
		DistanceMin = 30, -- studs, Force 0 et jauge verte
		DistanceParForce = 0.4, -- studs par point de Force (Force 1000 -> +400)
		DistanceMax = 1e6, -- plafond de sécurité (la vraie limite : la fin du dernier biome)
		DelaiEntreLancers = 3, -- secondes, contrôlé par le serveur
		MaxCreaturesAuSol = 10, -- par joueur ; au-delà, la plus ancienne disparaît
		CompensationPingMax = 0.25, -- secondes de latence retirées au maximum
		DureeMaxJauge = 10, -- au-delà, la jauge est annulée côté serveur
		Jauge = {
			Periode = 1.6, -- secondes pour monter (0 -> 1) puis redescendre (1 -> 0)
			-- seuils sur la position p (0 = bas, 1 = haut), du bas vers le haut
			Paliers = {
				{ Couleur = "Vert", Min = 0, Bonus = 0, Message = "Pas mal !" },
				{ Couleur = "Jaune", Min = 0.5, Bonus = 15, Message = "Bien joué !" },
				{ Couleur = "Orange", Min = 0.75, Bonus = 35, Message = "Super !" },
				{ Couleur = "Rouge", Min = 0.92, Bonus = 60, Message = "PERFECT !" },
			},
		},
		Zones = { -- distance depuis le bord de la base
			{ Nom = "Proche", Min = 0 },
			{ Nom = "Moyenne", Min = 150 },
			{ Nom = "Lointaine", Min = 300 },
		},
	},

	-- Raretés des créatures : taux en %, exactement ceux du Plan.
	Raretes = {
		Ordre = { "Commune", "Rare", "Epique", "Legendaire", "Mythique" },
		Noms = {
			Commune = "Commune",
			Rare = "Rare",
			Epique = "Épique",
			Legendaire = "Légendaire",
			Mythique = "Mythique",
		},
		Taux = {
			Proche = { Commune = 70, Rare = 22, Epique = 6, Legendaire = 1.8, Mythique = 0.2 },
			Moyenne = { Commune = 55, Rare = 28, Epique = 12, Legendaire = 4, Mythique = 1 },
			Lointaine = { Commune = 40, Rare = 30, Epique = 18, Legendaire = 9, Mythique = 3 },
		},
		Couleurs = { -- pour la créature et l'affichage (RGB 0-255)
			Commune = { 200, 200, 200 },
			Rare = { 80, 160, 255 },
			Epique = { 180, 90, 255 },
			Legendaire = { 255, 190, 40 },
			Mythique = { 255, 70, 120 },
		},
	},

	-- Récolte, portage, dépôt en base et revenus des créatures.
	Creatures = {
		DistanceRecolte = 10, -- studs, vérifiée par le serveur
		DureeRecolte = 0.5, -- secondes de maintien du ProximityPrompt
		MultiplicateurPortage = 0.8, -- WalkSpeed × 0,8 pendant le portage
		MaxCreaturesBase = 10, -- emplacements par base
		IntervalleRevenus = 1, -- secondes entre deux versements
		RevenuParSeconde = { Commune = 1, Rare = 3, Epique = 10, Legendaire = 30, Mythique = 100 },
		PiecesMax = 1e300, -- plafond de sécurité (progression quasi infinie)
	},

	-- Étages de base (façon vitrine) : chaque étage ajoute MaxCreaturesBase
	-- socles. Le premier est gratuit ; les suivants s'achètent en pièces.
	Bases = {
		EtagesMax = 3,
		HauteurEtage = 14, -- studs entre deux étages
		PrixEtages = { 2500, 150000 }, -- prix des étages 2 et 3
		-- Agrandissements : côté du sol de la base (studs), prix des niveaux 2
		-- et 3, et taille max des créatures exposées (× leur taille de base),
		-- pour que les plus grosses tiennent sur leur socle.
		Tailles = { 40, 56, 72 },
		PrixAgrandissement = { 6000, 250000 },
		EchelleMax = { 1.3, 2.1, 2.8 },
		Ecart = 90, -- distance entre deux bases (assez pour la plus grande)
	},

	-- Tailles des créatures (tirées par le serveur à la pousse, indépendantes
	-- de la rareté et de la jauge). Plus elle est grosse, plus elle rapporte :
	-- revenu = revenu de la rareté × Multiplicateur. Taux affichés au joueur.
	Tailles = {
		Ordre = { "Normale", "Grande", "Geante", "Colossale", "Titan" },
		Noms = {
			Normale = "Normale",
			Grande = "Grande",
			Geante = "Géante",
			Colossale = "Colossale",
			Titan = "Titan",
		},
		Taux = { Normale = 60, Grande = 25, Geante = 10, Colossale = 4, Titan = 1 }, -- %
		Echelle = { Normale = 1, Grande = 1.3, Geante = 1.65, Colossale = 2.1, Titan = 2.8 },
		Multiplicateur = { Normale = 1, Grande = 2, Geante = 4, Colossale = 8, Titan = 20 },
		-- Plus le biome est loin, plus les grosses tailles sortent souvent :
		-- le poids de la taille n (1 = Normale) est × (1 + BonusParBiome × (biome - 1))^(n - 1).
		BonusParBiome = 0.2,
	},

	-- Plaquage d'un joueur qui porte une créature (vérifié par le serveur).
	Plaquage = {
		Portee = 8, -- studs max entre les deux HumanoidRootPart
		DelaiRecuperation = 6, -- secondes entre deux plaquages réussis du même joueur
		DureeAuSol = 1.5, -- secondes au sol pour la cible
		DureeProtection = 4, -- secondes sans pouvoir être replaqué (>= DureeAuSol)
		DistanceChute = 4, -- studs entre la cible et la créature lâchée
		DureeVieLachee = 60, -- secondes avant disparition d'une créature lâchée
		IntervalleMinRequetes = 0.2, -- anti-spam : requêtes plus rapprochées ignorées
		-- Noms d'Enum.KeyCode (E et ButtonX servent déjà à « Récolter »).
		Touches = { Clavier = "F", Manette = "ButtonY" },
	},

	-- Monstres des Terres Sauvages (tout est décidé par le serveur).
	Monstres = {
		BordBases = 20, -- Z du bord des bases (= début des Terres Sauvages)
		MargeBases = 6, -- un monstre reste toujours à Z >= BordBases + MargeBases
		IntervalleIA = 0.1, -- secondes entre deux pas de la boucle serveur
		DureeProtection = 3, -- secondes sans pouvoir être refrappé par un monstre
		DistanceDisparition = 120, -- au-delà, le monstre revient à son point d'apparition
		-- Par zone (mêmes noms que Lancer.Zones), valeurs croissantes.
		Zones = {
			Proche = {
				Nom = "Gloupinou",
				Couleur = { 120, 230, 255 },
				Taille = 4,
				Vitesse = 10,
				-- Pas de dégâts : le coup propulse et étourdit (recul = vitesse du monstre × Recul).
				Recul = 2.5,
				Hauteur = 25, -- studs/s vers le haut
				Etourdi = 1.0, -- secondes au sol
				PorteeDetection = 30,
				PorteeCoup = 5,
				Recharge = 2.0,
				NombreJour = 2,
				NombreNuit = 3, -- au plus 12 monstres par biome la nuit (anti-lag)
			},
			Moyenne = {
				Nom = "Ronchonbulle",
				Couleur = { 255, 170, 60 },
				Taille = 5,
				Vitesse = 13,
				Recul = 3,
				Hauteur = 35,
				Etourdi = 1.4,
				PorteeDetection = 40,
				PorteeCoup = 6,
				Recharge = 1.6,
				NombreJour = 3,
				NombreNuit = 4,
			},
			Lointaine = {
				Nom = "Grobidou",
				Couleur = { 200, 90, 255 },
				Taille = 6,
				Vitesse = 16,
				Recul = 3.5,
				Hauteur = 45,
				Etourdi = 1.8,
				PorteeDetection = 50,
				PorteeCoup = 7,
				Recharge = 1.2,
				NombreJour = 4,
				NombreNuit = 5,
			},
		},
		IntervalleVague = 30, -- la nuit, une vague complète les zones toutes les 30 s
		ReculMax = 500, -- studs/s : plafond de la propulsion horizontale
		DureePoussee = 0.2, -- secondes de poussée
	},

	-- Raids de bases : vol d'une créature exposée et verrou de la base.
	Raid = {
		DistanceVol = 10, -- studs max entre le voleur et la créature exposée
		DureeVol = 1, -- secondes de maintien du ProximityPrompt « Voler »
		DureeVerrou = 60, -- secondes de verrouillage (valeur du Plan)
		Recharge = 60, -- secondes après la FIN du verrou avant de pouvoir le racheter
		PrixVerrou = 100, -- pièces
		DistanceVerrou = 10, -- studs max entre le propriétaire et le bouton « Verrouiller »
		DistanceExpulsion = 8, -- studs devant la porte, hors de la base, où l'intrus est replacé
		DureeAlerte = 3, -- secondes d'affichage de « VOLÉ ! »
	},

	-- Pièges posés dans les Terres Sauvages (tout est vérifié par le serveur).
	Pieges = {
		Ordre = { "Filet", "Glu", "FausseGraine" },
		Types = {
			Filet = { Nom = "Filet", Prix = 50, Couleur = { 255, 140, 30 }, Duree = 3 },
			Glu = {
				Nom = "Glu",
				Prix = 40,
				Couleur = { 120, 255, 60 },
				Multiplicateur = 0.3,
				Rayon = 6,
			},
			FausseGraine = {
				Nom = "Fausse graine",
				Prix = 60,
				Couleur = { 255, 215, 60 },
				Duree = 2,
			},
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

	-- Cycle jour/nuit (horloge serveur).
	Cycle = {
		DureeJour = 240, -- secondes
		DureeNuit = 120, -- secondes
		HeureJour = 14, -- Lighting.ClockTime
		HeureNuit = 0,
	},

	-- Événements de serveur : un à la fois, annoncé à tous, pour tout le monde.
	-- Les taux de rareté ne changent jamais (règle du Plan).
	Evenements = {
		PremierApres = 120, -- secondes après le démarrage du serveur
		Intervalle = 480, -- secondes entre deux débuts d'événement
		Duree = 150, -- secondes
		Ordre = { "PluieDoree", "VentPorteur", "GrainesGeantes" },
		Liste = {
			PluieDoree = {
				Nom = "Pluie dorée",
				Texte = "Revenus × 2",
				Couleur = { 255, 200, 50 },
				Revenus = 2,
			},
			VentPorteur = {
				Nom = "Vent porteur",
				Texte = "Lancers + 300 studs",
				Couleur = { 90, 200, 255 },
				Distance = 300,
			},
			GrainesGeantes = {
				Nom = "Graines géantes",
				Texte = "Grosses tailles comme 3 biomes plus loin",
				Couleur = { 190, 120, 255 },
				BonusTailles = 3,
			},
		},
	},

	-- Classements : liste des joueurs (leaderstats), panneau « Classement »
	-- (ce serveur et monde entier, via OrderedDataStore).
	Classement = {
		IntervalleMonde = 120, -- secondes entre deux mises à jour mondiales
		Taille = 10, -- lignes affichées
		NomRevenus = "ClassementRevenusV1",
		NomBiomes = "ClassementBiomesV1",
	},

	-- Renaissance : repartir à 0 pièce contre des bonus permanents. Le Bestiaire
	-- donne aussi un bonus par page de biome complète.
	Renaissance = {
		PrixBase = 1e6, -- pièces pour la 1re renaissance
		CroissancePrix = 10, -- chaque renaissance coûte × 10
		MultRevenus = 2, -- revenus × 2 par renaissance
		BonusForge = 0.5, -- gain de la Forge + 50 % par renaissance
		BonusPage = 0.1, -- revenus + 10 % par page de biome complète
	},

	-- Graines : achetées une fois pour toutes, la graine équipée rend les
	-- raretés hautes plus fréquentes (Chance, taux affichés au lancer), les
	-- grosses tailles aussi (Tailles = biomes de plus) et les mutations
	-- (Mutation = multiplicateur de chance). Toutes les raretés restent possibles.
	Graines = {
		Ordre = {
			"Simple",
			"Doree",
			"Emeraude",
			"Cristal",
			"Rubis",
			"Etoilee",
			"Solaire",
			"Cosmique",
			"Arcenciel",
			"Nebuleuse",
			"Eternelle",
		},
		Liste = {
			Simple = {
				Nom = "Graine simple",
				Prix = 0,
				Chance = 0,
				Tailles = 0,
				Mutation = 1,
				Couleur = { 170, 120, 70 },
			},
			Doree = {
				Nom = "Graine dorée",
				Prix = 25000,
				Chance = 0.4,
				Tailles = 1,
				Mutation = 1.2,
				Couleur = { 255, 200, 60 },
			},
			Emeraude = {
				Nom = "Graine émeraude",
				Prix = 2.5e5,
				Chance = 0.7,
				Tailles = 1,
				Mutation = 1.3,
				Couleur = { 70, 210, 120 },
			},
			Cristal = {
				Nom = "Graine cristal",
				Prix = 2.5e6,
				Chance = 1,
				Tailles = 2,
				Mutation = 1.5,
				Couleur = { 120, 220, 255 },
			},
			Rubis = {
				Nom = "Graine rubis",
				Prix = 3e7,
				Chance = 1.5,
				Tailles = 2,
				Mutation = 1.7,
				Couleur = { 230, 60, 90 },
			},
			Etoilee = {
				Nom = "Graine étoilée",
				Prix = 4e8,
				Chance = 2,
				Tailles = 3,
				Mutation = 2,
				Couleur = { 200, 150, 255 },
			},
			Solaire = {
				Nom = "Graine solaire",
				Prix = 6e9,
				Chance = 2.7,
				Tailles = 3,
				Mutation = 2.5,
				Couleur = { 255, 160, 40 },
			},
			Cosmique = {
				Nom = "Graine cosmique",
				Prix = 1e11,
				Chance = 3.5,
				Tailles = 4,
				Mutation = 3,
				Couleur = { 110, 90, 255 },
			},
			Arcenciel = {
				Nom = "Graine arc-en-ciel",
				Prix = 5e13,
				Chance = 6,
				Tailles = 6,
				Mutation = 5,
				Couleur = { 255, 120, 200 },
			},
			Nebuleuse = {
				Nom = "Graine nébuleuse",
				Prix = 3e16,
				Chance = 9,
				Tailles = 8,
				Mutation = 7,
				Couleur = { 150, 70, 220 },
			},
			Eternelle = {
				Nom = "Graine éternelle",
				Prix = 2e20,
				Chance = 13,
				Tailles = 10,
				Mutation = 9,
				Couleur = { 255, 245, 210 },
			},
		},
	},

	-- Mutations : tirées à la pousse, indépendamment du reste ; revenus × Mult.
	-- Chances doublées pendant un événement de serveur.
	Mutations = {
		-- Du plus courant au plus rare. Matiere : Enum.Material appliqué ;
		-- Melange : part de la couleur de la mutation ; Effet : particules.
		Ordre = {
			"Givree",
			"Doree",
			"Enflammee",
			"Cristal",
			"Electrique",
			"Arcenciel",
			"Galactique",
		},
		Liste = {
			Givree = {
				Nom = "Givrée",
				Chance = 0.03,
				Mult = 2,
				Couleur = { 190, 235, 255 },
				Matiere = "Ice",
				Melange = 0.5,
				Effet = "Givre",
			},
			Doree = {
				Nom = "Dorée",
				Chance = 0.025,
				Mult = 3,
				Couleur = { 255, 210, 60 },
				Matiere = "Foil",
				Melange = 0.6,
				Effet = "Etincelles",
			},
			Enflammee = {
				Nom = "Enflammée",
				Chance = 0.015,
				Mult = 4,
				Couleur = { 255, 110, 40 },
				Matiere = "CrackedLava",
				Melange = 0.45,
				Effet = "Flammes",
			},
			Cristal = {
				Nom = "Cristal",
				Chance = 0.01,
				Mult = 6,
				Couleur = { 140, 230, 255 },
				Matiere = "Glass",
				Melange = 0.55,
				Transparence = 0.15,
				Effet = "Etincelles",
			},
			Electrique = {
				Nom = "Électrique",
				Chance = 0.005,
				Mult = 9,
				Couleur = { 90, 200, 255 },
				Matiere = "Neon",
				Melange = 0.4,
				Effet = "Eclairs",
			},
			Arcenciel = {
				Nom = "Arc-en-ciel",
				Chance = 0.0025,
				Mult = 15,
				Couleur = { 255, 140, 220 },
				Arc = true,
				Melange = 0.65,
				Effet = "Etincelles",
			},
			Galactique = {
				Nom = "Galactique",
				Chance = 0.0008,
				Mult = 30,
				Couleur = { 70, 40, 140 },
				Matiere = "SmoothPlastic",
				Melange = 0.75,
				Effet = "Etoiles",
			},
		},
		BonusEvenement = 2,
	},

	-- Roue gratuite : un tour toutes les Intervalle secondes.
	Roue = {
		Intervalle = 4 * 3600,
		Boost = 2, -- revenus × 2…
		DureeBoost = 600, -- … pendant 10 min
		Lots = {
			{ Id = "Pieces5", Nom = "5 min de revenus", Poids = 30, Type = "Pieces", Valeur = 300 },
			{
				Id = "Pieces15",
				Nom = "15 min de revenus",
				Poids = 22,
				Type = "Pieces",
				Valeur = 900,
			},
			{ Id = "Pieces60", Nom = "1 h de revenus", Poids = 8, Type = "Pieces", Valeur = 3600 },
			{ Id = "Boost", Nom = "Revenus × 2 (10 min)", Poids = 20, Type = "Boost" },
			{
				Id = "Lancer",
				Nom = "Prochain lancer : graine cristal",
				Poids = 12,
				Type = "Lancer",
				Valeur = "Cristal",
			},
			{ Id = "Trainee", Nom = "Traînée surprise", Poids = 8, Type = "Trainee" },
		} :: { any },
	},

	-- Traînées cosmétiques (aucun avantage) : débloquées par les renaissances,
	-- les pages complètes du Bestiaire ou la roue.
	Trainees = {
		Ordre = {
			"Arcenciel",
			"Flammes",
			"Galaxie",
			"Feuilles",
			"Etoiles",
			"Bulles",
			"Neige",
			"Bonbon",
		},
		Liste = {
			Arcenciel = {
				Nom = "Arc-en-ciel",
				Couleurs = {
					{ 255, 90, 90 },
					{ 255, 230, 80 },
					{ 90, 220, 140 },
					{ 110, 150, 255 },
				},
				Renaissances = 1,
			},
			Flammes = {
				Nom = "Flammes",
				Couleurs = { { 255, 220, 80 }, { 255, 120, 30 }, { 200, 40, 30 } },
				Renaissances = 2,
			},
			Galaxie = {
				Nom = "Galaxie",
				Couleurs = { { 200, 150, 255 }, { 80, 60, 200 }, { 20, 20, 60 } },
				Renaissances = 3,
			},
			Feuilles = {
				Nom = "Feuilles",
				Couleurs = { { 140, 220, 90 }, { 60, 150, 70 } },
				Pages = 3,
			},
			Etoiles = {
				Nom = "Étoiles",
				Couleurs = { { 255, 250, 200 }, { 255, 210, 80 } },
				Pages = 10,
			},
			Bulles = {
				Nom = "Bulles",
				Couleurs = { { 200, 240, 255 }, { 90, 190, 240 } },
				Roue = true,
			},
			Neige = {
				Nom = "Neige",
				Couleurs = { { 255, 255, 255 }, { 170, 220, 255 } },
				Roue = true,
			},
			Bonbon = {
				Nom = "Bonbon",
				Couleurs = { { 255, 150, 200 }, { 255, 255, 255 }, { 140, 230, 200 } },
				Roue = true,
			},
		},
	},

	-- Skins de la graine lancée (cosmétiques, aucun avantage). Débloqués par
	-- renaissances ou pages du Bestiaire, comme les traînées. Forme : Ball,
	-- Block ou Cylinder ; Matiere : Enum.Material ; Effet : particules.
	Skins = {
		Ordre = { "Gland", "Pomme", "Pepite", "Cristal", "Comete", "Planete", "Coeur", "Etoile" },
		Liste = {
			Gland = {
				Nom = "Gland",
				Couleur = { 170, 110, 60 },
				Matiere = "Wood",
				Forme = "Ball",
				Effet = "Feuilles",
				Pages = 1,
			},
			Pomme = {
				Nom = "Pomme",
				Couleur = { 240, 60, 60 },
				Matiere = "SmoothPlastic",
				Forme = "Ball",
				Effet = "Feuilles",
				Pages = 5,
			},
			Pepite = {
				Nom = "Pépite d'or",
				Couleur = { 255, 200, 40 },
				Matiere = "Foil",
				Forme = "Block",
				Effet = "Etincelles",
				Renaissances = 1,
			},
			Cristal = {
				Nom = "Cristal",
				Couleur = { 140, 230, 255 },
				Matiere = "Glass",
				Forme = "Block",
				Effet = "Etincelles",
				Pages = 8,
			},
			Comete = {
				Nom = "Comète",
				Couleur = { 120, 200, 255 },
				Matiere = "Neon",
				Forme = "Ball",
				Effet = "Feu",
				Renaissances = 2,
			},
			Planete = {
				Nom = "Planète",
				Couleur = { 160, 110, 255 },
				Matiere = "SmoothPlastic",
				Forme = "Ball",
				Effet = "Etoiles",
				Renaissances = 3,
			},
			Coeur = {
				Nom = "Cœur",
				Couleur = { 255, 110, 170 },
				Matiere = "Neon",
				Forme = "Ball",
				Effet = "Coeurs",
				Pages = 12,
			},
			Etoile = {
				Nom = "Étoile filante",
				Couleur = { 255, 240, 120 },
				Matiere = "Neon",
				Forme = "Block",
				Effet = "Etoiles",
				Renaissances = 5,
			},
		},
	},

	-- Vente d'une créature de la base : son revenu pendant Secondes.
	Vente = {
		Secondes = 120,
	},

	-- Gains hors ligne : au retour, Taux du revenu par seconde pendant
	-- l'absence (au plus MaxSecondes, rien sous MinSecondes).
	HorsLigne = {
		Taux = 0.5,
		MaxSecondes = 12 * 3600,
		MinSecondes = 60,
	},

	-- Bords de la carte : remparts décorés + murs invisibles (Decor) ;
	-- sous cette hauteur, un joueur est ramené dans sa base.
	Limites = {
		HauteurChute = -30,
	},

	-- Sauvegarde des joueurs (DataStore).
	Sauvegarde = {
		NomDataStore = "JoueursV1",
		PrefixeCle = "joueur_",
		IntervalleAutoSecondes = 60,
		Tentatives = 3,
	},
}

return Config
