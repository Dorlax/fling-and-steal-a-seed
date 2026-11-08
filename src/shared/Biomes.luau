--!strict
-- Biomes (données pures, testables avec Lune) : les Terres Sauvages sont une
-- longue route de biomes, les uns après les autres, à partir du bord des bases.
-- Chaque biome fait `Longueur` studs et garde les trois sous-zones du Plan
-- (Proche, Moyenne, Lointaine) avec leurs taux de rareté. Plus le biome est
-- loin, plus ses créatures valent cher (× Croissance par biome).
local Biomes = {}

Biomes.Longueur = 600 -- studs par biome
Biomes.Croissance = 1.5 -- valeur des créatures × 1,5 par biome

export type Rgb = { number }
export type Biome = {
	Id: string,
	Nom: string,
	Sol: Rgb, -- couleur du sol
	Materiau: string, -- matériau du sol (Grass, Sand, Snow, ...)
	Bordure: Rgb, -- collines des côtés
	Brume: Rgb, -- couleur de l'atmosphère (côté client)
	Densite: number, -- densité de l'atmosphère
	Decor: string, -- thème du décor (Prairie, Foret, Desert, ...)
	Creatures: { [string]: { string } }, -- espèces par rareté
	Monstres: { [string]: { string } }, -- espèces par sous-zone
}

Biomes.Liste = {
	{
		Id = "Prairie",
		Nom = "Prairie Pétillante",
		Sol = { 90, 200, 70 },
		Materiau = "Grass",
		Bordure = { 80, 175, 70 },
		Brume = { 200, 225, 255 },
		Densite = 0.28,
		Decor = "Prairie",
		Creatures = {
			Commune = { "Poussigraine", "Champichou" },
			Rare = { "Lapinou", "Tortipousse" },
			Epique = { "Renardelle", "Hibouflor" },
			Legendaire = { "Cerfaurore", "Lionfeuille" },
			Mythique = { "Dragonnet", "Phenigraine" },
		},
		Monstres = {
			Proche = { "Gloupinou", "Piquerelle" },
			Moyenne = { "Ronchonbulle", "Croquelune" },
			Lointaine = { "Grobidou", "Brasaurus" },
		},
	},
	{
		Id = "BoisMoussu",
		Nom = "Bois Moussu",
		Sol = { 70, 150, 95 },
		Materiau = "Grass",
		Bordure = { 45, 110, 75 },
		Brume = { 140, 220, 190 },
		Densite = 0.4,
		Decor = "Foret",
		Creatures = {
			Commune = { "Glandouille", "Mousselin" },
			Rare = { "Lanternil", "Crapousse" },
			Epique = { "Oursilierre", "Lucioline" },
			Legendaire = { "Sylvoroi", "Escargolem" },
			Mythique = { "Sylphelune", "Phalenor" },
		},
		Monstres = {
			Proche = { "Champignard" },
			Moyenne = { "Roncebete" },
			Lointaine = { "Grumtronc" },
		},
	},
	{
		Id = "Dunes",
		Nom = "Dunes Dorées",
		Sol = { 240, 200, 115 },
		Materiau = "Sand",
		Bordure = { 225, 165, 90 },
		Brume = { 255, 225, 170 },
		Densite = 0.32,
		Decor = "Desert",
		Creatures = {
			Commune = { "Scarabille", "Cactounet" },
			Rare = { "Fennecil", "Lezardo" },
			Epique = { "Dromadune", "Scorpiou" },
			Legendaire = { "Sphinxou", "Tortusable" },
			Mythique = { "Ibisoleil", "Djinnoule" },
		},
		Monstres = {
			Proche = { "Momiotte" },
			Moyenne = { "Vautourne" },
			Lointaine = { "Golemsable" },
		},
	},
} :: { Biome }

local function estNombreFini(valeur: any): boolean
	return type(valeur) == "number"
		and valeur == valeur
		and valeur > -math.huge
		and valeur < math.huge
end

function Biomes.nombre(): number
	return #Biomes.Liste
end

-- Numéro du biome (1, 2, ...) à une distance (studs depuis le bord des bases).
function Biomes.index(distance: any): number
	if not estNombreFini(distance) or distance < 0 then
		return 1
	end
	return math.clamp(math.floor(distance / Biomes.Longueur) + 1, 1, #Biomes.Liste)
end

-- Distance (depuis le bord des bases) où commence le biome n.
function Biomes.debut(index: number): number
	return (index - 1) * Biomes.Longueur
end

-- Distance maximale d'un lancer : un peu avant la fin du dernier biome.
function Biomes.distanceMax(): number
	return #Biomes.Liste * Biomes.Longueur - 20
end

-- Distance à l'intérieur de son biome (pour les sous-zones et leurs taux).
function Biomes.dansBiome(distance: any): number
	if not estNombreFini(distance) or distance < 0 then
		return 0
	end
	return distance - Biomes.debut(Biomes.index(distance))
end

-- Valeur des créatures du biome n : × Croissance^(n - 1).
function Biomes.multiplicateur(index: number): number
	return Biomes.Croissance ^ (math.max(index, 1) - 1)
end

-- Multiplicateur lisible : « 1 », « 1,5 », « 2,25 », « 38 », « 1,2 M »…
function Biomes.texteMultiplicateur(index: number): string
	local m = Biomes.multiplicateur(index)
	if m >= 1e6 then
		return (string.gsub(string.format("%.1f M", m / 1e6), "%.", ","))
	elseif m >= 100 then
		return string.format("%d", math.floor(m + 0.5))
	end
	local texte = string.format("%.2f", m)
	texte = string.gsub(texte, "0+$", "")
	texte = string.gsub(texte, "%.$", "")
	return (string.gsub(texte, "%.", ","))
end

function Biomes.biome(index: number): Biome
	return Biomes.Liste[math.clamp(index, 1, #Biomes.Liste)]
end

-- Numéro du biome d'une espèce (créature ou monstre), ou nil.
local indexEspeces: { [string]: number } = {}
for i, biome in Biomes.Liste do
	for _, liste in biome.Creatures do
		for _, nom in liste do
			indexEspeces[nom] = i
		end
	end
	for _, liste in biome.Monstres do
		for _, nom in liste do
			indexEspeces[nom] = i
		end
	end
end

function Biomes.indexEspece(nom: any): number?
	if type(nom) ~= "string" then
		return nil
	end
	return indexEspeces[nom]
end

-- Espèces de créatures d'une rareté, tous biomes confondus (validation).
function Biomes.especesDeRarete(rarete: string): { string }
	local liste = {}
	for _, biome in Biomes.Liste do
		local especes: { string } = biome.Creatures[rarete] or {}
		for _, nom in especes do
			table.insert(liste, nom)
		end
	end
	return liste
end

return Biomes
