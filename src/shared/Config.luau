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

	-- Sauvegarde des joueurs (DataStore).
	Sauvegarde = {
		NomDataStore = "JoueursV1",
		PrefixeCle = "joueur_",
		IntervalleAutoSecondes = 60,
		Tentatives = 3,
	},
}

return Config
