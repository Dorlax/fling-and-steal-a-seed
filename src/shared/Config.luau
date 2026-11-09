--!strict
-- Configuration partagée du jeu (module pur : testable avec Lune).
local Config = {
	NomDuJeu = "Fling & Steal a Seed",
	Version = "0.1.0",

	-- Réglages de la Forge (niveau 1).
	Forge = {
		Modes = { "Force", "Vitesse" },
		ModeParDefaut = "Force",
		IntervalleSecondes = 1, -- un gain par seconde passée sur la Forge
		GainParTick = 1,
		PlafondStat = 1e300, -- aucune limite réelle (seulement les nombres valides)
		WalkSpeedBase = 16,
		WalkSpeedParPointVitesse = 0.02,
		-- Au-delà de StatLineaire, chaque doublement de la stat ajoute un palier
		-- (distance : un biome ; vitesse : WalkSpeedParDoublement).
		StatLineaire = 1000,
		WalkSpeedParDoublement = 20,
		WalkSpeedMax = 1e9, -- aucune limite réelle : le joueur va aussi vite qu'il veut
		-- Niveaux de Forge achetés en pièces : gain × CroissanceGain par niveau,
		-- coût du niveau n -> n + 1 = CoutBase × CroissanceCout^(n - 1).
		Niveaux = { CoutBase = 100, CroissanceCout = 1.9, CroissanceGain = 1.6 },
		-- Zone « sur la Forge » : au-dessus de la plateforme (studs).
		DistanceForge = {
			Largeur = 8,
			Hauteur = 6,
		},
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
