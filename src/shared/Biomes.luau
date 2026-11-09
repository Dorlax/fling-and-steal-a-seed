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
	{
		Id = "Glacier",
		Nom = "Glacier Givré",
		Sol = { 225, 240, 255 },
		Materiau = "Snow",
		Bordure = { 170, 200, 235 },
		Brume = { 200, 225, 255 },
		Densite = 0.42,
		Decor = "Glace",
		Creatures = {
			Commune = { "Pingouinou", "Bonhommeige" },
			Rare = { "Phoquinet", "Renarctique" },
			Epique = { "Morsabre", "Yetinou" },
			Legendaire = { "Mammouflon", "Cristalynx" },
			Mythique = { "Narvalune", "Draconeige" },
		},
		Monstres = {
			Proche = { "Bouleneige" },
			Moyenne = { "Grognours" },
			Lointaine = { "Abominou" },
		},
	},
	{
		Id = "Volcan",
		Nom = "Volcan Ardent",
		Sol = { 60, 45, 45 },
		Materiau = "Basalt",
		Bordure = { 90, 50, 40 },
		Brume = { 255, 140, 90 },
		Densite = 0.45,
		Decor = "Volcan",
		Creatures = {
			Commune = { "Braisillon", "Caillouflam" },
			Rare = { "Crabraise", "Chauvesouffre" },
			Epique = { "Rhinocendre", "Serpenlave" },
			Legendaire = { "Taurobraise", "Salamandreine" },
			Mythique = { "Ifritou", "Cerberou" },
		},
		Monstres = {
			Proche = { "Magmouille" },
			Moyenne = { "Cendrecroc" },
			Lointaine = { "Titanflamme" },
		},
	},
	{
		Id = "Galaxie",
		Nom = "Galaxie Étoilée",
		Sol = { 45, 30, 90 },
		Materiau = "Slate",
		Bordure = { 70, 45, 130 },
		Brume = { 120, 80, 200 },
		Densite = 0.38,
		Decor = "Galaxie",
		Creatures = {
			Commune = { "Astrogoutte", "Alienou" },
			Rare = { "Satellapin", "Planetortue" },
			Epique = { "Meduspace", "Robochat" },
			Legendaire = { "Nebulion", "Ovniouf" },
			Mythique = { "Trounoir", "Baleinastrale" },
		},
		Monstres = {
			Proche = { "Asteroidon" },
			Moyenne = { "Zorglouf" },
			Lointaine = { "Krakosmos" },
		},
	},
	{
		Id = "Marais",
		Nom = "Marais Brumeux",
		Sol = { 75, 95, 60 },
		Materiau = "Mud",
		Bordure = { 55, 75, 50 },
		Brume = { 150, 130, 190 },
		Densite = 0.5,
		Decor = "Marais",
		Creatures = {
			Commune = { "Tetardou", "Nenuflou" },
			Rare = { "Libellume", "Heronet" },
			Epique = { "Crocodouille", "Loutrine" },
			Legendaire = { "Sorcicroa", "Hydranou" },
			Mythique = { "Feufollet", "Kappanou" },
		},
		Monstres = {
			Proche = { "Vasepouf" },
			Moyenne = { "Moustiroc" },
			Lointaine = { "Croquemarais" },
		},
	},
	{
		Id = "Recif",
		Nom = "Récif Corail",
		Sol = { 240, 225, 180 },
		Materiau = "Sand",
		Bordure = { 80, 190, 210 },
		Brume = { 90, 200, 230 },
		Densite = 0.45,
		Decor = "Recif",
		Creatures = {
			Commune = { "Poissolo", "Etoilou" },
			Rare = { "Hippocampou", "Poulpinou" },
			Epique = { "Raietoile", "Dauphinou" },
			Legendaire = { "Requinou", "Bernardor" },
			Mythique = { "Leviatou", "Perlune" },
		},
		Monstres = {
			Proche = { "Oursinou" },
			Moyenne = { "Murenoire" },
			Lointaine = { "Gueulabysse" },
		},
	},
	{
		Id = "Bonbon",
		Nom = "Royaume Bonbon",
		Sol = { 255, 190, 220 },
		Materiau = "SmoothPlastic",
		Bordure = { 255, 150, 200 },
		Brume = { 255, 200, 235 },
		Densite = 0.3,
		Decor = "Bonbon",
		Creatures = {
			Commune = { "Guimauvette", "Bonbouboule" },
			Rare = { "Cupcaket", "Oursongomme" },
			Epique = { "Licornougat", "Escarbiscuit" },
			Legendaire = { "Gateaurex", "Pinatou" },
			Mythique = { "Arcencielle", "Dragefee" },
		},
		Monstres = {
			Proche = { "Gelatinou" },
			Moyenne = { "Croquebiscuit" },
			Lointaine = { "Gateaugeant" },
		},
	},
	{
		Id = "Jungle",
		Nom = "Jungle Émeraude",
		Sol = { 60, 140, 70 },
		Materiau = "Grass",
		Bordure = { 40, 100, 55 },
		Brume = { 150, 220, 150 },
		Densite = 0.4,
		Decor = "Jungle",
		Creatures = {
			Commune = { "Singinou", "Perruchette" },
			Rare = { "Toucanou", "Cameleou" },
			Epique = { "Panthelune", "Paressou" },
			Legendaire = { "Gorillon", "Tigrebois" },
			Mythique = { "Quetzaflamme", "Idolou" },
		},
		Monstres = {
			Proche = { "Fourmigeant" },
			Moyenne = { "Serpentacle" },
			Lointaine = { "Plantegloutonne" },
		},
	},
	{
		Id = "Ciel",
		Nom = "Îles Célestes",
		Sol = { 230, 238, 255 },
		Materiau = "SmoothPlastic",
		Bordure = { 160, 200, 255 },
		Brume = { 190, 220, 255 },
		Densite = 0.25,
		Decor = "Ciel",
		Creatures = {
			Commune = { "Nuageon", "Plumichou" },
			Rare = { "Ballonard", "Cerfvolant" },
			Epique = { "Griffonnet", "Pegasou" },
			Legendaire = { "Soleillon", "Lunarelle" },
			Mythique = { "Aurorine", "Baleinuage" },
		},
		Monstres = {
			Proche = { "Orageon" },
			Moyenne = { "Corbeauvent" },
			Lointaine = { "Tornadogre" },
		},
	},
	{
		Id = "Manoir",
		Nom = "Manoir Hanté",
		Sol = { 70, 62, 82 },
		Materiau = "Slate",
		Bordure = { 50, 40, 65 },
		Brume = { 120, 90, 160 },
		Densite = 0.55,
		Decor = "Manoir",
		Creatures = {
			Commune = { "Fantomou", "Citrouillou" },
			Rare = { "Chauvinette", "Chandelou" },
			Epique = { "Squelettou", "Grimoirou" },
			Legendaire = { "Vampichat", "Armurinou" },
			Mythique = { "Spectrelle", "Chapodou" },
		},
		Monstres = {
			Proche = { "Toilou" },
			Moyenne = { "Momiflet" },
			Lointaine = { "Gargouillard" },
		},
	},
	{
		Id = "Savane",
		Nom = "Savane Dorée",
		Sol = { 215, 180, 95 },
		Materiau = "Grass",
		Bordure = { 170, 120, 60 },
		Brume = { 255, 210, 150 },
		Densite = 0.3,
		Decor = "Savane",
		Creatures = {
			Commune = { "Zebrinou", "Suricatou" },
			Rare = { "Girafon", "Phacochou" },
			Epique = { "Elephanteau", "Gazellune" },
			Legendaire = { "Rhinocorne", "Autruchou" },
			Mythique = { "Baobabou", "Guepardor" },
		},
		Monstres = {
			Proche = { "Hyenard" },
			Moyenne = { "Vautourbe" },
			Lointaine = { "Bufflegrogne" },
		},
	},
	{
		Id = "Mecanique",
		Nom = "Cité Mécanique",
		Sol = { 120, 110, 100 },
		Materiau = "DiamondPlate",
		Bordure = { 180, 130, 60 },
		Brume = { 210, 170, 120 },
		Densite = 0.4,
		Decor = "Mecanique",
		Creatures = {
			Commune = { "Boulonou", "Ressortin" },
			Rare = { "Robichat", "Hiboulon" },
			Epique = { "Locomotou", "Helicopou" },
			Legendaire = { "Gardengrenage", "Theierobot" },
			Mythique = { "Horlogeon", "Mecadragon" },
		},
		Monstres = {
			Proche = { "Visseur" },
			Moyenne = { "Pistonard" },
			Lointaine = { "Broyeurex" },
		},
	},
	{
		Id = "Zen",
		Nom = "Jardin Zen",
		Sol = { 120, 170, 100 },
		Materiau = "Grass",
		Bordure = { 230, 150, 180 },
		Brume = { 255, 210, 225 },
		Densite = 0.25,
		Decor = "Zen",
		Creatures = {
			Commune = { "Koinou", "Tanukou" },
			Rare = { "Grulune", "Pandaroux" },
			Epique = { "Kitsunou", "Lanternou" },
			Legendaire = { "Dragonbambou", "Tortujade" },
			Mythique = { "Sakurelle", "Carpedor" },
		},
		Monstres = {
			Proche = { "Bambougre" },
			Moyenne = { "Oniboule" },
			Lointaine = { "Komapierre" },
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
