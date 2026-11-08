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
		PlafondStat = 1000,
		WalkSpeedBase = 16,
		WalkSpeedParPointVitesse = 0.02,
		WalkSpeedMax = 50,
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
		DistanceMax = 520, -- plafond absolu
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
		PiecesMax = 1e15, -- plafond de sécurité
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

	-- Sauvegarde des joueurs (DataStore).
	Sauvegarde = {
		NomDataStore = "JoueursV1",
		PrefixeCle = "joueur_",
		IntervalleAutoSecondes = 60,
		Tentatives = 3,
	},
}

return Config
