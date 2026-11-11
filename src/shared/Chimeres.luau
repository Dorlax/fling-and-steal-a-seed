--!strict
-- Nouveaux biomes peuplés de créatures chimériques (données pures, testables
-- avec Lune). Chaque biome a son univers (sol, ciel, murs, décor) et ses
-- espèces : une chimère prend le corps d'une espèce existante, lui greffe
-- des parties d'une autre (ailes, queue, oreilles, antennes…) et la teint
-- aux couleurs du biome. Le nom mélange les deux espèces (Lapinou +
-- Dragonnet -> « Lapinnet »).
--
-- Tout est déterministe : le même biome donne toujours les mêmes espèces
-- (les sauvegardes gardent le nom de l'espèce). Ne jamais réordonner
-- `Chimeres.Themes` : ajouter les nouveaux biomes à la fin.
local Chimeres = {}

export type Rgb = { number }
export type Ciel = {
	Horizon: Rgb, -- couleur du ciel près de l'horizon
	Voile: number, -- brume du ciel (0 à 3)
	Eclat: number, -- reflet du soleil (0 à 1)
	Exposition: number, -- exposition (négatif = plus sombre)
	Teinte: Rgb, -- teinte légère de l'image
	Elements: string, -- décor du ciel (voir client CielBiome)
	Couleur: Rgb, -- couleur principale des éléments du ciel
}
export type Theme = {
	Id: string,
	Nom: string,
	Sol: Rgb,
	Materiau: string,
	Bordure: Rgb,
	Brume: Rgb,
	Densite: number,
	Decor: string, -- thème de décor au sol (Decor.THEMES)
	Teinte: number, -- teinte des chimères (degrés, 0 = rouge, 120 = vert, 240 = bleu)
	Ciel: Ciel,
}
export type Recette = {
	Nom: string,
	Base: string, -- espèce dont on garde le corps
	Donneur: string, -- espèce qui donne ses parties (ailes, queue…)
	Teinte: number,
}

local function ciel(
	horizon: Rgb,
	voile: number,
	eclat: number,
	exposition: number,
	teinte: Rgb,
	elements: string,
	couleur: Rgb
): Ciel
	return {
		Horizon = horizon,
		Voile = voile,
		Eclat = eclat,
		Exposition = exposition,
		Teinte = teinte,
		Elements = elements,
		Couleur = couleur,
	}
end

local function theme(
	id: string,
	nom: string,
	decor: string,
	sol: Rgb,
	materiau: string,
	bordure: Rgb,
	brume: Rgb,
	densite: number,
	teinte: number,
	c: Ciel
): Theme
	return {
		Id = id,
		Nom = nom,
		Sol = sol,
		Materiau = materiau,
		Bordure = bordure,
		Brume = brume,
		Densite = densite,
		Decor = decor,
		Teinte = teinte,
		Ciel = c,
	}
end

-- Biomes 22 et suivants, dans l'ordre de la route.
Chimeres.Themes = {
	theme(
		"Toundra",
		"Toundra Aurore",
		"Glace",
		{ 205, 228, 238 },
		"Snow",
		{ 150, 190, 210 },
		{ 170, 220, 230 },
		0.3,
		185,
		ciel({ 60, 160, 170 }, 1.2, 0.1, -0.4, { 235, 250, 255 }, "Aurore", { 90, 255, 180 })
	),
	theme(
		"Canyon",
		"Canyon Rouge",
		"Desert",
		{ 205, 112, 72 },
		"Sandstone",
		{ 170, 80, 50 },
		{ 255, 190, 140 },
		0.32,
		15,
		ciel({ 255, 130, 80 }, 1.3, 0.3, -0.3, { 255, 235, 220 }, "Soleil", { 255, 170, 80 })
	),
	theme(
		"Champignons",
		"Forêt des Champignons",
		"Foret",
		{ 118, 92, 160 },
		"Grass",
		{ 90, 60, 130 },
		{ 190, 160, 230 },
		0.38,
		290,
		ciel({ 150, 90, 200 }, 2, 0.1, -0.15, { 245, 230, 255 }, "Bulles", { 255, 150, 220 })
	),
	theme(
		"Lagon",
		"Lagon Turquoise",
		"Plage",
		{ 240, 226, 172 },
		"Sand",
		{ 60, 200, 190 },
		{ 180, 240, 240 },
		0.26,
		175,
		ciel({ 60, 200, 230 }, 0.8, 0.25, -0.4, { 240, 255, 255 }, "Nuages", { 255, 255, 255 })
	),
	theme(
		"Cendres",
		"Plaines de Cendre",
		"Volcan",
		{ 92, 86, 96 },
		"Basalt",
		{ 60, 55, 65 },
		{ 160, 120, 110 },
		0.45,
		20,
		ciel({ 150, 70, 50 }, 2.4, 0.2, -0.1, { 255, 225, 210 }, "Eclairs", { 255, 120, 60 })
	),
	theme(
		"Nebuleuse",
		"Nébuleuse Rose",
		"Galaxie",
		{ 62, 32, 92 },
		"Slate",
		{ 120, 60, 150 },
		{ 220, 120, 210 },
		0.4,
		320,
		ciel({ 200, 60, 160 }, 2.5, 0.5, -0.15, { 255, 230, 250 }, "Planetes", { 255, 140, 220 })
	),
	theme(
		"Mangrove",
		"Mangrove Brumeuse",
		"Marais",
		{ 82, 112, 72 },
		"Mud",
		{ 60, 90, 60 },
		{ 170, 200, 170 },
		0.5,
		100,
		ciel({ 120, 160, 120 }, 2.8, 0, -0.1, { 235, 250, 235 }, "Nuages", { 200, 220, 200 })
	),
	theme(
		"Abysses",
		"Abysses Lumineux",
		"Recif",
		{ 32, 52, 92 },
		"Sand",
		{ 20, 40, 80 },
		{ 60, 120, 200 },
		0.5,
		220,
		ciel({ 20, 60, 140 }, 2.8, 0, 0, { 220, 235, 255 }, "Bulles", { 120, 230, 255 })
	),
	theme(
		"Chocolat",
		"Vallée Chocolat",
		"Bonbon",
		{ 122, 72, 42 },
		"Ground",
		{ 90, 50, 30 },
		{ 240, 200, 170 },
		0.3,
		30,
		ciel({ 255, 190, 150 }, 1, 0.2, -0.2, { 255, 240, 230 }, "Montgolfieres", { 255, 120, 170 })
	),
	theme(
		"Bambouseraie",
		"Bambouseraie",
		"Zen",
		{ 132, 190, 92 },
		"Grass",
		{ 90, 150, 70 },
		{ 210, 240, 200 },
		0.3,
		90,
		ciel({ 170, 220, 150 }, 1.2, 0.15, -0.2, { 245, 255, 240 }, "Soleil", { 255, 230, 160 })
	),
	theme(
		"Archipel",
		"Archipel Céleste",
		"Ciel",
		{ 236, 240, 255 },
		"SmoothPlastic",
		{ 180, 200, 255 },
		{ 210, 225, 255 },
		0.2,
		210,
		ciel(
			{ 150, 190, 255 },
			0.6,
			0.25,
			-0.45,
			{ 245, 250, 255 },
			"Montgolfieres",
			{ 255, 200, 120 }
		)
	),
	theme(
		"Clairiere",
		"Clairière Hantée",
		"Manoir",
		{ 72, 82, 72 },
		"Grass",
		{ 50, 60, 55 },
		{ 120, 140, 130 },
		0.55,
		140,
		ciel({ 50, 80, 70 }, 2.6, 0, -0.1, { 225, 245, 235 }, "Lunes", { 180, 255, 210 })
	),
	theme(
		"Steppe",
		"Steppe Dorée",
		"Savane",
		{ 222, 192, 102 },
		"Grass",
		{ 190, 150, 70 },
		{ 255, 230, 170 },
		0.28,
		45,
		ciel({ 255, 200, 110 }, 1.2, 0.3, -0.35, { 255, 245, 225 }, "Soleil", { 255, 210, 90 })
	),
	theme(
		"Horlogerie",
		"Horlogerie Géante",
		"Mecanique",
		{ 152, 122, 82 },
		"WoodPlanks",
		{ 120, 90, 60 },
		{ 220, 190, 150 },
		0.35,
		35,
		ciel(
			{ 200, 150, 90 },
			1.8,
			0.1,
			-0.15,
			{ 255, 245, 230 },
			"Montgolfieres",
			{ 210, 160, 90 }
		)
	),
	theme(
		"Cerisiers",
		"Vallon des Cerisiers",
		"Zen",
		{ 152, 202, 112 },
		"Grass",
		{ 230, 150, 180 },
		{ 255, 220, 235 },
		0.3,
		340,
		ciel({ 255, 170, 200 }, 1, 0.15, -0.25, { 255, 240, 245 }, "Nuages", { 255, 200, 225 })
	),
	theme(
		"Geodes",
		"Grottes Géodes",
		"Cavernes",
		{ 62, 52, 82 },
		"Slate",
		{ 90, 60, 130 },
		{ 120, 90, 180 },
		0.55,
		270,
		ciel({ 70, 40, 120 }, 2.8, 0, 0, { 235, 225, 255 }, "Etoiles", { 200, 150, 255 })
	),
	theme(
		"Ludotheque",
		"Salle de Jeux",
		"Jouets",
		{ 240, 202, 122 },
		"WoodPlanks",
		{ 90, 160, 255 },
		{ 230, 240, 255 },
		0.22,
		200,
		ciel(
			{ 150, 200, 255 },
			0.8,
			0.15,
			-0.3,
			{ 250, 250, 255 },
			"Montgolfieres",
			{ 255, 90, 90 }
		)
	),
	theme(
		"Vergers",
		"Vergers d'Automne",
		"Automne",
		{ 162, 142, 72 },
		"Grass",
		{ 200, 100, 50 },
		{ 255, 210, 160 },
		0.32,
		25,
		ciel({ 240, 140, 70 }, 1.4, 0.2, -0.2, { 255, 240, 225 }, "Soleil", { 255, 150, 70 })
	),
	theme(
		"Ranch",
		"Ranch Sauvage",
		"Ferme",
		{ 172, 192, 92 },
		"Grass",
		{ 170, 120, 70 },
		{ 240, 235, 190 },
		0.28,
		60,
		ciel({ 255, 220, 140 }, 1, 0.2, -0.3, { 255, 250, 235 }, "Nuages", { 255, 255, 255 })
	),
	theme(
		"Songes",
		"Pays des Songes",
		"Reves",
		{ 112, 92, 172 },
		"Grass",
		{ 150, 120, 220 },
		{ 190, 170, 255 },
		0.42,
		260,
		ciel({ 100, 80, 200 }, 2.2, 0.4, -0.15, { 240, 235, 255 }, "Lunes", { 255, 240, 180 })
	),
	theme(
		"Oasis",
		"Oasis Secrète",
		"Desert",
		{ 232, 202, 142 },
		"Sand",
		{ 80, 180, 120 },
		{ 255, 240, 200 },
		0.28,
		160,
		ciel({ 255, 210, 140 }, 1.2, 0.3, -0.35, { 255, 250, 235 }, "Soleil", { 255, 230, 120 })
	),
	theme(
		"Banquise",
		"Banquise Éternelle",
		"Glace",
		{ 230, 245, 255 },
		"Ice",
		{ 170, 210, 240 },
		{ 220, 240, 255 },
		0.3,
		200,
		ciel({ 160, 200, 255 }, 1, 0.1, -0.5, { 240, 248, 255 }, "Aurore", { 120, 200, 255 })
	),
	theme(
		"Lave",
		"Rivières de Lave",
		"Volcan",
		{ 62, 42, 42 },
		"Basalt",
		{ 120, 40, 20 },
		{ 255, 120, 70 },
		0.5,
		5,
		ciel({ 220, 60, 20 }, 2.6, 0.3, -0.1, { 255, 220, 200 }, "Eclairs", { 255, 80, 30 })
	),
	theme(
		"Cosmos",
		"Cosmos Doré",
		"Galaxie",
		{ 28, 22, 48 },
		"Slate",
		{ 200, 160, 60 },
		{ 120, 100, 170 },
		0.45,
		50,
		ciel({ 40, 30, 90 }, 2.6, 0.6, -0.1, { 245, 240, 255 }, "Planetes", { 255, 210, 100 })
	),
	theme(
		"Tourbiere",
		"Tourbière Violette",
		"Marais",
		{ 92, 72, 102 },
		"Mud",
		{ 80, 60, 100 },
		{ 170, 140, 190 },
		0.52,
		280,
		ciel({ 120, 80, 150 }, 2.6, 0, -0.1, { 245, 235, 255 }, "Lunes", { 220, 180, 255 })
	),
	theme(
		"Kelp",
		"Forêt de Kelp",
		"Recif",
		{ 42, 92, 82 },
		"Sand",
		{ 30, 110, 80 },
		{ 100, 200, 170 },
		0.5,
		150,
		ciel({ 30, 120, 110 }, 2.6, 0.05, -0.05, { 225, 255, 245 }, "Bulles", { 150, 255, 220 })
	),
	theme(
		"Guimauve",
		"Monts Guimauve",
		"Bonbon",
		{ 255, 222, 236 },
		"SmoothPlastic",
		{ 255, 170, 210 },
		{ 255, 220, 240 },
		0.24,
		330,
		ciel({ 255, 180, 220 }, 0.8, 0.2, -0.4, { 255, 245, 250 }, "Nuages", { 255, 210, 235 })
	),
	theme(
		"Temple",
		"Temple Perdu",
		"Jungle",
		{ 102, 142, 82 },
		"Grass",
		{ 130, 120, 90 },
		{ 190, 220, 170 },
		0.42,
		120,
		ciel({ 120, 180, 110 }, 2, 0.15, -0.15, { 240, 255, 235 }, "Soleil", { 255, 220, 120 })
	),
	theme(
		"Orage",
		"Ciel d'Orage",
		"Ciel",
		{ 152, 162, 192 },
		"SmoothPlastic",
		{ 90, 100, 140 },
		{ 150, 160, 200 },
		0.4,
		230,
		ciel({ 80, 90, 140 }, 2.4, 0, -0.15, { 230, 235, 255 }, "Eclairs", { 255, 250, 150 })
	),
	theme(
		"Citrouilles",
		"Champ des Citrouilles",
		"Manoir",
		{ 92, 72, 52 },
		"Ground",
		{ 230, 120, 40 },
		{ 200, 140, 100 },
		0.48,
		30,
		ciel({ 160, 80, 50 }, 2.2, 0.1, -0.1, { 255, 235, 220 }, "Lunes", { 255, 170, 70 })
	),
	theme(
		"Cristaux",
		"Mines de Cristal",
		"Cavernes",
		{ 52, 62, 92 },
		"Slate",
		{ 80, 160, 220 },
		{ 100, 160, 220 },
		0.52,
		190,
		ciel({ 40, 90, 150 }, 2.6, 0.1, 0, { 230, 245, 255 }, "Etoiles", { 120, 230, 255 })
	),
	theme(
		"Arcade",
		"Arcade Néon",
		"Jouets",
		{ 42, 42, 72 },
		"SmoothPlastic",
		{ 255, 60, 200 },
		{ 120, 80, 200 },
		0.4,
		300,
		ciel({ 90, 40, 160 }, 2.2, 0.4, -0.05, { 245, 235, 255 }, "Etoiles", { 255, 80, 220 })
	),
	theme(
		"Lunaire",
		"Prairie Lunaire",
		"Reves",
		{ 122, 132, 172 },
		"Grass",
		{ 150, 160, 220 },
		{ 170, 180, 240 },
		0.4,
		240,
		ciel({ 70, 80, 160 }, 2.2, 0.3, -0.15, { 235, 240, 255 }, "Planetes", { 230, 235, 255 })
	),
	theme(
		"Sommet",
		"Sommet Venteux",
		"Glace",
		{ 182, 192, 202 },
		"Slate",
		{ 130, 140, 160 },
		{ 220, 230, 245 },
		0.35,
		210,
		ciel({ 170, 200, 240 }, 1.2, 0.2, -0.35, { 245, 250, 255 }, "Nuages", { 255, 255, 255 })
	),
}

-- Générateur pseudo-aléatoire déterministe (Park-Miller), sans dépassement :
-- renvoie une fonction qui tire un entier entre 1 et n.
local function hasard(graine: number): (n: number) -> number
	local x = graine % 2147483646 + 1
	return function(n: number): number
		x = (x * 48271) % 2147483647
		return math.min(n, math.floor(x / 2147483647 * n) + 1)
	end
end

local VOYELLES = "aeiouy"

local function voyelle(c: string): boolean
	return string.find(VOYELLES, string.lower(c), 1, true) ~= nil
end

-- Coupes possibles : la base garde un début qui finit sur une voyelle, le
-- donneur donne une fin qui commence une syllabe.
local function coupesBase(nom: string): { number }
	local liste = {}
	local l = #nom
	for c = math.ceil(l * 0.4), l - 2 do
		if voyelle(string.sub(nom, c, c)) and not voyelle(string.sub(nom, c + 1, c + 1)) then
			table.insert(liste, c)
		end
	end
	if #liste == 0 then
		table.insert(liste, math.ceil(l * 0.5))
	end
	return liste
end

local function coupesDonneur(nom: string): { number }
	local liste = {}
	local l = #nom
	for c = math.max(2, math.floor(l / 2) - 1), l - 2 do
		if not voyelle(string.sub(nom, c, c)) and voyelle(string.sub(nom, c - 1, c - 1)) then
			table.insert(liste, c)
		end
	end
	if #liste == 0 then
		table.insert(liste, math.floor(l / 2) + 1)
	end
	return liste
end

-- Nom chimérique libre (5 à 12 lettres), ou nil si tous sont pris.
function Chimeres.nom(base: string, donneur: string, pris: { [string]: boolean }): string?
	for _, a in coupesBase(base) do
		for _, d in coupesDonneur(donneur) do
			local nom = string.sub(base, 1, a) .. string.lower(string.sub(donneur, d))
			if #nom >= 5 and #nom <= 12 and not pris[nom] then
				return nom
			end
		end
	end
	return nil
end

local RARETES = { "Commune", "Rare", "Epique", "Legendaire", "Mythique" }
local ZONES = { "Proche", "Moyenne", "Lointaine" }

export type Biome = {
	Id: string,
	Nom: string,
	Sol: Rgb,
	Materiau: string,
	Bordure: Rgb,
	Brume: Rgb,
	Densite: number,
	Decor: string,
	Creatures: { [string]: { string } },
	Monstres: { [string]: { string } },
	Ciel: Ciel?,
}

-- Construit les biomes chimériques à partir des biomes faits à la main
-- (`originaux`). Renvoie la liste des nouveaux biomes et les recettes des
-- espèces (par nom).
function Chimeres.generer(originaux: { any }): ({ Biome }, { [string]: Recette })
	local pris: { [string]: boolean } = {}
	local creatures: { [string]: { string } } = {}
	local monstres: { [string]: { string } } = {}
	local toutes: { string } = {}
	for _, r in RARETES do
		creatures[r] = {}
	end
	for _, z in ZONES do
		monstres[z] = {}
	end
	for _, b in originaux do
		for _, r in RARETES do
			for _, nom in b.Creatures[r] or {} do
				pris[nom] = true
				table.insert(creatures[r], nom)
				table.insert(toutes, nom)
			end
		end
		for _, z in ZONES do
			for _, nom in b.Monstres[z] or {} do
				pris[nom] = true
				table.insert(monstres[z], nom)
			end
		end
	end

	local biomes: { Biome } = {}
	local recettes: { [string]: Recette } = {}
	for i, t in Chimeres.Themes do
		local numero = #originaux + i
		local h = hasard(numero * 7919)
		-- Deux espèces par rareté (ou par sous-zone), bases toutes différentes.
		local function deux(pool: { string }, donneurs: { string }): { string }
			local noms = {}
			local bases: { [string]: boolean } = {}
			for _ = 1, 2 do
				local base = pool[h(#pool)]
				while bases[base] do
					base = pool[h(#pool)]
				end
				bases[base] = true
				local depart = h(#donneurs)
				local nom: string? = nil
				local donneur = donneurs[depart]
				for essai = 0, #donneurs - 1 do
					donneur = donneurs[(depart + essai - 1) % #donneurs + 1]
					if donneur ~= base then
						nom = Chimeres.nom(base, donneur, pris)
						if nom then
							break
						end
					end
				end
				local final = nom or (string.sub(base, 1, 6) .. string.sub(t.Id, 1, 6))
				pris[final] = true
				recettes[final] = { Nom = final, Base = base, Donneur = donneur, Teinte = t.Teinte }
				table.insert(noms, final)
			end
			return noms
		end
		local especesCreatures: { [string]: { string } } = {}
		for _, r in RARETES do
			especesCreatures[r] = deux(creatures[r], toutes)
		end
		local especesMonstres: { [string]: { string } } = {}
		for _, z in ZONES do
			especesMonstres[z] = deux(monstres[z], monstres[z])
		end
		table.insert(biomes, {
			Id = t.Id,
			Nom = t.Nom,
			Sol = t.Sol,
			Materiau = t.Materiau,
			Bordure = t.Bordure,
			Brume = t.Brume,
			Densite = t.Densite,
			Decor = t.Decor,
			Creatures = especesCreatures,
			Monstres = especesMonstres,
			Ciel = t.Ciel,
		})
	end
	return biomes, recettes
end

-- Teinte (0-360) et saturation d'une couleur RGB (0-255).
local function versTsv(c: Rgb): (number, number, number)
	local r, g, b = c[1] / 255, c[2] / 255, c[3] / 255
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local delta = max - min
	local teinte = 0
	if delta > 0 then
		if max == r then
			teinte = 60 * (((g - b) / delta) % 6)
		elseif max == g then
			teinte = 60 * ((b - r) / delta + 2)
		else
			teinte = 60 * ((r - g) / delta + 4)
		end
	end
	local saturation = if max > 0 then delta / max else 0
	return teinte, saturation, max
end

local function versRgb(teinte: number, saturation: number, valeur: number): Rgb
	local c = valeur * saturation
	local x = c * (1 - math.abs((teinte / 60) % 2 - 1))
	local m = valeur - c
	local r, g, b
	if teinte < 60 then
		r, g, b = c, x, 0
	elseif teinte < 120 then
		r, g, b = x, c, 0
	elseif teinte < 180 then
		r, g, b = 0, c, x
	elseif teinte < 240 then
		r, g, b = 0, x, c
	elseif teinte < 300 then
		r, g, b = x, 0, c
	else
		r, g, b = c, 0, x
	end
	return {
		math.floor((r + m) * 255 + 0.5),
		math.floor((g + m) * 255 + 0.5),
		math.floor((b + m) * 255 + 0.5),
	}
end

-- Couleur teintée vers `cible` (degrés) : les gris, blancs et noirs (yeux,
-- reflets, bouches) ne changent pas ; les autres prennent la teinte du biome
-- en gardant leurs écarts (deux couleurs différentes restent différentes).
function Chimeres.teinter(c: Rgb, cible: number, reference: number): Rgb
	local teinte, saturation, valeur = versTsv(c)
	if saturation < 0.18 or valeur < 0.15 then
		return { c[1], c[2], c[3] }
	end
	local nouvelle = (teinte - reference + cible) % 360
	return versRgb(nouvelle, saturation, valeur)
end

-- Teinte « principale » d'une liste de couleurs (la plus saturée et vive).
function Chimeres.teintePrincipale(couleurs: { Rgb }): number
	local meilleure, score = 0, -1
	for _, c in couleurs do
		local teinte, saturation, valeur = versTsv(c)
		if saturation * valeur > score then
			meilleure, score = teinte, saturation * valeur
		end
	end
	return meilleure
end

return Chimeres
