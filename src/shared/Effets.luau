--!strict
-- Effets visuels des espèces (données pures, testables avec Lune) :
--  * Familles : petites particules en blocs (style du jeu) émises par le client ;
--  * ParBiome : la famille d'ambiance de chaque biome (toutes ses espèces) ;
--  * Especes  : effets signature de certaines espèces (source = début du nom
--    de la pièce d'où ils partent, rythme = multiplicateur de fréquence) ;
--  * Roles    : animations signature (rôles d'Anime) posées sur des pièces.
local Effets = {}

export type Famille = {
	Forme: string, -- "Cube", "Boule", "Plat" ou "Texte"
	Couleurs: { { number } },
	Taille: { number }, -- min, max (unités du modèle)
	Vitesse: { number }, -- déplacement {x, y, z} par seconde (unités du modèle)
	Derive: number, -- dérive horizontale aléatoire (unités par seconde)
	Duree: number, -- secondes de vie
	Intervalle: number, -- secondes entre deux particules (taille Normale)
	Neon: boolean?,
	Transparence: number?,
	Grossit: number?, -- multiplicateur de taille en fin de vie
	Tourne: boolean?,
	Texte: string?,
	AuSol: boolean?, -- part des pieds au lieu du haut du modèle
	AuDessus: number?, -- part de plus haut (flocons)
}

local function famille(f: Famille): Famille
	return f
end

Effets.Familles = {
	Pollen = famille({
		Forme = "Boule",
		Couleurs = { { 255, 240, 120 }, { 255, 255, 210 } },
		Taille = { 0.05, 0.08 },
		Vitesse = { 0, 0.25, 0 },
		Derive = 0.35,
		Duree = 2.6,
		Intervalle = 0.9,
		Neon = true,
	}),
	Lucioles = famille({
		Forme = "Boule",
		Couleurs = { { 200, 255, 120 }, { 255, 240, 120 } },
		Taille = { 0.05, 0.08 },
		Vitesse = { 0, 0.15, 0 },
		Derive = 0.6,
		Duree = 3,
		Intervalle = 0.8,
		Neon = true,
	}),
	Poussiere = famille({
		Forme = "Cube",
		Couleurs = { { 230, 200, 140 }, { 210, 175, 110 } },
		Taille = { 0.06, 0.12 },
		Vitesse = { 0, 0.2, 0 },
		Derive = 0.7,
		Duree = 1.2,
		Intervalle = 0.7,
		Transparence = 0.2,
		AuSol = true,
		Tourne = true,
	}),
	Flocons = famille({
		Forme = "Cube",
		Couleurs = { { 255, 255, 255 }, { 210, 235, 255 } },
		Taille = { 0.05, 0.09 },
		Vitesse = { 0, -0.35, 0 },
		Derive = 0.25,
		Duree = 3,
		Intervalle = 0.6,
		Tourne = true,
		AuDessus = 0.5,
	}),
	Braises = famille({
		Forme = "Cube",
		Couleurs = { { 255, 140, 40 }, { 255, 220, 80 }, { 255, 90, 30 } },
		Taille = { 0.04, 0.08 },
		Vitesse = { 0, 0.8, 0 },
		Derive = 0.3,
		Duree = 1.4,
		Intervalle = 0.45,
		Neon = true,
		Tourne = true,
	}),
	Flammes = famille({
		Forme = "Cube",
		Couleurs = { { 255, 120, 30 }, { 255, 200, 60 }, { 255, 240, 140 } },
		Taille = { 0.09, 0.15 },
		Vitesse = { 0, 0.9, 0 },
		Derive = 0.1,
		Duree = 0.6,
		Intervalle = 0.18,
		Neon = true,
		Grossit = 0.1,
		Tourne = true,
	}),
	Etoiles = famille({
		Forme = "Cube",
		Couleurs = { { 255, 240, 150 }, { 200, 160, 255 }, { 150, 220, 255 } },
		Taille = { 0.05, 0.09 },
		Vitesse = { 0, 0.15, 0 },
		Derive = 0.5,
		Duree = 1.6,
		Intervalle = 0.5,
		Neon = true,
		Tourne = true,
	}),
	Bulles = famille({
		Forme = "Boule",
		Couleurs = { { 170, 225, 255 }, { 210, 240, 255 } },
		Taille = { 0.06, 0.12 },
		Vitesse = { 0, 0.6, 0 },
		Derive = 0.2,
		Duree = 2,
		Intervalle = 0.6,
		Transparence = 0.45,
	}),
	Confettis = famille({
		Forme = "Plat",
		Couleurs = {
			{ 255, 90, 120 },
			{ 255, 220, 60 },
			{ 90, 200, 255 },
			{ 140, 230, 120 },
			{ 200, 130, 255 },
		},
		Taille = { 0.06, 0.1 },
		Vitesse = { 0, 0.5, 0 },
		Derive = 0.6,
		Duree = 1.6,
		Intervalle = 0.5,
		Tourne = true,
	}),
	Feuilles = famille({
		Forme = "Plat",
		Couleurs = { { 80, 170, 70 }, { 120, 200, 80 }, { 60, 140, 60 } },
		Taille = { 0.08, 0.13 },
		Vitesse = { 0, -0.3, 0 },
		Derive = 0.45,
		Duree = 2.8,
		Intervalle = 0.9,
		Tourne = true,
		AuDessus = 0.3,
	}),
	FeuillesRousses = famille({
		Forme = "Plat",
		Couleurs = { { 230, 90, 40 }, { 245, 170, 50 }, { 200, 60, 40 } },
		Taille = { 0.08, 0.13 },
		Vitesse = { 0, -0.3, 0 },
		Derive = 0.5,
		Duree = 2.8,
		Intervalle = 0.8,
		Tourne = true,
		AuDessus = 0.3,
	}),
	Petales = famille({
		Forme = "Plat",
		Couleurs = { { 255, 190, 210 }, { 255, 220, 235 } },
		Taille = { 0.07, 0.1 },
		Vitesse = { 0, -0.25, 0 },
		Derive = 0.5,
		Duree = 3,
		Intervalle = 0.7,
		Tourne = true,
		AuDessus = 0.4,
	}),
	Vapeur = famille({
		Forme = "Boule",
		Couleurs = { { 245, 245, 250 }, { 220, 220, 230 } },
		Taille = { 0.1, 0.16 },
		Vitesse = { 0, 0.7, 0 },
		Derive = 0.15,
		Duree = 1.6,
		Intervalle = 0.35,
		Transparence = 0.35,
		Grossit = 3,
	}),
	Brume = famille({
		Forme = "Boule",
		Couleurs = { { 150, 120, 200 }, { 120, 100, 170 } },
		Taille = { 0.2, 0.3 },
		Vitesse = { 0, 0.1, 0 },
		Derive = 0.3,
		Duree = 2,
		Intervalle = 0.8,
		Transparence = 0.55,
		Grossit = 2,
		AuSol = true,
	}),
	Cristaux = famille({
		Forme = "Cube",
		Couleurs = { { 120, 220, 255 }, { 190, 110, 255 }, { 140, 255, 200 } },
		Taille = { 0.04, 0.07 },
		Vitesse = { 0, 0.2, 0 },
		Derive = 0.5,
		Duree = 1,
		Intervalle = 0.45,
		Neon = true,
		Tourne = true,
	}),
	Paille = famille({
		Forme = "Plat",
		Couleurs = { { 240, 205, 100 }, { 220, 180, 80 } },
		Taille = { 0.1, 0.16 },
		Vitesse = { 0, -0.3, 0 },
		Derive = 0.4,
		Duree = 2.4,
		Intervalle = 1,
		Tourne = true,
		AuDessus = 0.2,
	}),
	Gouttes = famille({
		Forme = "Boule",
		Couleurs = { { 90, 190, 240 }, { 150, 220, 255 } },
		Taille = { 0.04, 0.07 },
		Vitesse = { 0, -0.6, 0 },
		Derive = 0.3,
		Duree = 1.2,
		Intervalle = 0.55,
		Transparence = 0.2,
	}),
	Plumes = famille({
		Forme = "Plat",
		Couleurs = { { 255, 255, 255 }, { 230, 240, 255 } },
		Taille = { 0.08, 0.12 },
		Vitesse = { 0, -0.2, 0 },
		Derive = 0.5,
		Duree = 3,
		Intervalle = 0.9,
		Tourne = true,
		AuDessus = 0.4,
	}),
	Zzz = famille({
		Forme = "Texte",
		Texte = "Z",
		Couleurs = { { 210, 190, 255 }, { 255, 255, 255 } },
		Taille = { 0.18, 0.28 },
		Vitesse = { 0.15, 0.4, 0 },
		Derive = 0.05,
		Duree = 2,
		Intervalle = 0.9,
	}),
	Notes = famille({
		Forme = "Texte",
		Texte = "♪",
		Couleurs = { { 255, 220, 60 }, { 120, 220, 255 }, { 255, 120, 180 } },
		Taille = { 0.2, 0.3 },
		Vitesse = { 0, 0.5, 0 },
		Derive = 0.3,
		Duree = 1.6,
		Intervalle = 0.6,
	}),
	Coeurs = famille({
		Forme = "Texte",
		Texte = "♥",
		Couleurs = { { 255, 110, 160 }, { 255, 170, 200 } },
		Taille = { 0.16, 0.24 },
		Vitesse = { 0, 0.45, 0 },
		Derive = 0.2,
		Duree = 1.6,
		Intervalle = 1.1,
	}),
}

-- Famille d'ambiance de chaque biome (par Id).
Effets.ParBiome = {
	Prairie = "Pollen",
	BoisMoussu = "Lucioles",
	Dunes = "Poussiere",
	Glacier = "Flocons",
	Volcan = "Braises",
	Galaxie = "Etoiles",
	Marais = "Lucioles",
	Recif = "Bulles",
	Bonbon = "Confettis",
	Jungle = "Feuilles",
	Ciel = "Plumes",
	Manoir = "Brume",
	Savane = "Poussiere",
	Mecanique = "Vapeur",
	Zen = "Petales",
	Cavernes = "Cristaux",
	Jouets = "Confettis",
	Automne = "FeuillesRousses",
	Ferme = "Paille",
	Reves = "Zzz",
	Plage = "Gouttes",
	-- Biomes chimériques (Shared.Chimeres).
	Toundra = "Flocons",
	Canyon = "Poussiere",
	Champignons = "Lucioles",
	Lagon = "Gouttes",
	Cendres = "Braises",
	Nebuleuse = "Etoiles",
	Mangrove = "Lucioles",
	Abysses = "Bulles",
	Chocolat = "Confettis",
	Bambouseraie = "Feuilles",
	Archipel = "Plumes",
	Clairiere = "Brume",
	Steppe = "Poussiere",
	Horlogerie = "Vapeur",
	Cerisiers = "Petales",
	Geodes = "Cristaux",
	Ludotheque = "Confettis",
	Vergers = "FeuillesRousses",
	Ranch = "Paille",
	Songes = "Zzz",
	Oasis = "Pollen",
	Banquise = "Flocons",
	Lave = "Braises",
	Cosmos = "Etoiles",
	Tourbiere = "Brume",
	Kelp = "Bulles",
	Guimauve = "Confettis",
	Temple = "Feuilles",
	Orage = "Gouttes",
	Citrouilles = "Brume",
	Cristaux = "Cristaux",
	Arcade = "Etoiles",
	Lunaire = "Zzz",
	Sommet = "Flocons",
}

export type Signature = { Famille: string, Source: string?, Rythme: number? }

local function sig(famille_: string, source: string?, rythme: number?): Signature
	return { Famille = famille_, Source = source, Rythme = rythme }
end

-- Effets signature (en plus de l'ambiance du biome).
Effets.Especes = {
	-- Feu
	Phenigraine = { sig("Flammes", "Flamme") },
	Braisillon = { sig("Flammes", "Flamme") },
	Ifritou = { sig("Flammes", "Flamme") },
	Cerberou = { sig("Flammes", "Flamme") },
	Cendrecroc = { sig("Flammes", "Flamme") },
	Titanflamme = { sig("Flammes", "Flammes", 1.5) },
	Gateaurex = { sig("Flammes", "Flamme", 0.6) },
	Gateaugeant = { sig("Flammes", "Flamme", 0.6) },
	Chandelou = { sig("Flammes", "Flamme") },
	Kitsunou = { sig("Flammes", "Flamme", 0.7) },
	Soleillon = { sig("Braises", "Rayon", 1.5) },
	Quetzaflamme = { sig("Braises", "Plume", 1.5) },
	Magmouille = { sig("Braises", "Lave", 1.5) },
	Dragonnet = { sig("Braises", "Tete") },
	-- Vapeur et fumée
	Locomotou = { sig("Vapeur", "Cheminee", 1.3) },
	Theierobot = { sig("Vapeur", "Bec") },
	Pistonard = { sig("Vapeur", "Vapeur") },
	Broyeurex = { sig("Vapeur", "Cheminee", 1.3) },
	Gardengrenage = { sig("Vapeur", "Cheminee", 0.6) },
	Tracteurou = { sig("Vapeur", "Pot") },
	Djinnoule = { sig("Vapeur", "Fumee") },
	Bufflegrogne = { sig("Vapeur", "Fumee", 0.7) },
	Biqueboum = { sig("Vapeur", "Fumee", 0.7) },
	-- Eau
	Gloupinou = { sig("Bulles", "Bulle") },
	Vasepouf = { sig("Bulles", "Bulle") },
	Canardbain = { sig("Bulles", "Bulle") },
	Narvalune = { sig("Bulles", "Bulle") },
	Axolumi = { sig("Bulles", "Tete") },
	Koinou = { sig("Bulles", "Corps") },
	Elephanteau = { sig("Gouttes", "Jet", 1.4) },
	Baleinuage = { sig("Gouttes", "Jet") },
	Kappanou = { sig("Gouttes", "Eau") },
	Vaguelette = { sig("Gouttes", "Ecume", 1.4) },
	-- Lumière
	Lucioline = { sig("Lucioles") },
	Feufollet = { sig("Lucioles", "Coeur", 1.5) },
	Luciolette = { sig("Lucioles", "Lanterne", 1.5) },
	Lanternil = { sig("Lucioles", "Lanterne") },
	Spectrelle = { sig("Lucioles", "Lanterne") },
	Lanternou = { sig("Lucioles", "Lueur") },
	Gueulabysse = { sig("Lucioles", "Lanterne") },
	-- Étoiles et magie
	Filetoile = { sig("Etoiles", "Traine", 2) },
	Dragefee = { sig("Etoiles", "EtoileBaguette", 1.5) },
	Gemmelune = { sig("Cristaux", "Aile", 1.3) },
	Sylphelune = { sig("Etoiles", "Etoile") },
	Veilleusou = { sig("Etoiles", "Etoile") },
	Licorneve = { sig("Etoiles", "Corne") },
	Licornougat = { sig("Confettis", "Corne") },
	Aurorine = { sig("Etoiles", "Voile", 1.3) },
	Revelune = { sig("Etoiles", "Croissant") },
	Sablinou = { sig("Etoiles", "Sable", 1.3), sig("Zzz") },
	Chapodou = { sig("Etoiles", "Etincelle") },
	Arcencielle = { sig("Confettis", "Goutte") },
	-- Cristaux
	Cristalynx = { sig("Cristaux", "Cristal") },
	Escargolem = { sig("Cristaux", "Cristal") },
	Cristaloup = { sig("Cristaux", "Cristal") },
	Rocgrondeur = { sig("Cristaux", "Cristal") },
	Golemite = { sig("Cristaux", "Gemme") },
	Dracoquartz = { sig("Cristaux", "Coeur") },
	-- Sommeil, musique, tendresse
	Oreillou = { sig("Zzz", "Zz") },
	Ronfleur = { sig("Zzz", "Zz", 1.3) },
	Moutonuit = { sig("Zzz", "Bonnet") },
	Hiboureve = { sig("Zzz", "Bonnet") },
	Lunarelle = { sig("Zzz", "Tete") },
	Pianogre = { sig("Notes", "Note", 1.5) },
	Tamboum = { sig("Notes", "Baguette") },
	Soldaplomb = { sig("Notes", "Tambour", 0.7) },
	Doudouce = { sig("Coeurs", "Tete") },
	Ourspeluche = { sig("Coeurs", "Tete") },
	Cupcaket = { sig("Coeurs", "Cerise", 0.7) },
	-- Fêtes et tourbillons
	Pinatou = { sig("Confettis", "Pompon", 1.3) },
	Diablotboite = { sig("Confettis", "Chapeau") },
	Tourbillonne = { sig("FeuillesRousses", "Coeur", 2.5) },
	Baobabou = { sig("Feuilles", "Feuillage") },
	Sakurelle = { sig("Petales", "Petale", 1.8) },
	Mouliventou = { sig("Paille", "Moyeu", 1.3) },
	Tornadogre = { sig("Poussiere", nil, 2.5) },
	Orageon = { sig("Gouttes", "Eclair", 1.5) },
	-- Mascotte
	Pepin = { sig("Coeurs", "Bouton", 0.6), sig("Pollen", "Feuille", 1.5) },
}

-- Animations signature : { [début du nom de pièce] = rôle } par espèce.
-- Rôles continus (Toupie, Helice, Roue, Moulin) et oscillants (Pendule,
-- Bascule, Flamme) : voir Shared.Anime.
Effets.Roles = {
	Toupinette = {
		Bas = "Toupie",
		Ventre = "Toupie",
		Bande = "Toupie",
		Haut = "Toupie",
		Manche = "Toupie",
	},
	Tornadogre = { Spire = "Toupie", Debris = "Toupie" },
	Tourbillonne = { Feuille = "Toupie" },
	Helicopou = { Pale = "Helice", Helicette = "Roue" },
	Locomotou = { Roue = "Roue" },
	Tracteurou = { GrandeRoue = "Roue", PetiteRoue = "Roue" },
	Moissogre = { Pale = "Roue", Roue = "Roue" },
	Billerage = { Bille = "Roue", Spirale = "Roue" },
	Mouliventou = { Aile = "Moulin", Moyeu = "Moulin" },
	Horlogeon = { Aiguille = "Moulin", Balancier = "Pendule", Tige = "Pendule" },
	Chevalbascule = {
		Bascule = "Bascule",
		Montant = "Bascule",
		Corps = "Bascule",
		Selle = "Bascule",
		Cou = "Bascule",
		Tete = "Bascule",
		Oeil = "Bascule",
		Criniere = "Bascule",
		Rene = "Bascule",
	},
	Phenigraine = { Flamme = "Flamme" },
	Braisillon = { Flamme = "Flamme" },
	Ifritou = { Flamme = "Flamme" },
	Chandelou = { Flamme = "Flamme", Pointe = "Flamme" },
	Gateaurex = { Flamme = "Flamme" },
	Gateaugeant = { Flamme = "Flamme" },
	Cerberou = { Flamme = "Flamme" },
	Cendrecroc = { Flamme = "Flamme" },
	Feufollet = { Pointe = "Flamme" },
}

-- Multiplicateur de fréquence et de taille des effets selon la taille.
Effets.ParTaille = {
	Normale = 1,
	Grande = 1.2,
	Geante = 1.5,
	Colossale = 2,
	Titan = 3,
}

-- Effets d'une espèce : { {famille, source, rythme} } (ambiance + signature).
function Effets.de(nom: string, biomeId: string?): { Signature }
	local liste: { Signature } = {}
	local ambiance = if biomeId then (Effets.ParBiome :: any)[biomeId] else nil
	if ambiance then
		table.insert(liste, sig(ambiance))
	end
	for _, s in (Effets.Especes :: any)[nom] or {} do
		table.insert(liste, s)
	end
	return liste
end

-- Intervalle (s) entre deux particules d'un effet, selon la taille.
function Effets.intervalle(s: Signature, taille: string?): number
	local f = (Effets.Familles :: any)[s.Famille]
	if f == nil then
		return math.huge
	end
	local parTaille = (Effets.ParTaille :: any)[taille or "Normale"] or 1
	return f.Intervalle / ((s.Rythme or 1) * parTaille)
end

return Effets
