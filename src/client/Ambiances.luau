--!strict
-- Ambiance de chaque biome (côté client, affichage seulement) : chaque biome
-- a son propre ciel (couleur de l'atmosphère, horizon, voile), sa teinte et
-- son exposition, qui changent en douceur quand le joueur change de biome.
-- L'exposition baisse dans les biomes clairs (neige, sable, nuages) pour
-- qu'ils n'éblouissent pas. Aucun texte n'annonce le biome.
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Biomes = require(Shared:WaitForChild("Biomes"))
local Config = require(Shared:WaitForChild("Config"))
local CielBiome = require(script.Parent:WaitForChild("CielBiome"))

local Ambiances = {}

local BORD_BASES = Config.Monstres.BordBases
local demarre = false

type Ciel = {
	Horizon: { number }, -- couleur du ciel près de l'horizon (Atmosphere.Decay)
	Voile: number, -- Atmosphere.Haze
	Eclat: number, -- Atmosphere.Glare (reflet du soleil)
	Exposition: number, -- Lighting.ExposureCompensation (négatif = plus sombre)
	Teinte: { number }, -- ColorCorrection.TintColor (légère)
	Elements: string?, -- décor du ciel (client CielBiome) : Soleil, Planetes…
	Couleur: { number }?, -- couleur des éléments du ciel
}

-- Un ciel par biome (Id de Shared.Biomes) ; Prairie par défaut.
local CIELS: { [string]: Ciel } = {
	Prairie = {
		Horizon = { 120, 170, 255 },
		Voile = 0.6,
		Eclat = 0.15,
		Exposition = -0.1,
		Teinte = { 255, 255, 250 },
		Elements = "Nuages",
		Couleur = { 255, 255, 255 },
	},
	BoisMoussu = {
		Horizon = { 60, 140, 110 },
		Voile = 1.4,
		Eclat = 0,
		Exposition = -0.1,
		Teinte = { 235, 255, 240 },
		Elements = "Nuages",
		Couleur = { 220, 240, 220 },
	},
	Dunes = {
		Horizon = { 255, 170, 90 },
		Voile = 1.2,
		Eclat = 0.2,
		Exposition = -0.35,
		Teinte = { 255, 245, 225 },
		Elements = "Soleil",
		Couleur = { 255, 180, 80 },
	},
	Glacier = {
		Horizon = { 140, 190, 255 },
		Voile = 1,
		Eclat = 0.1,
		Exposition = -0.45,
		Teinte = { 235, 245, 255 },
		Elements = "Aurore",
		Couleur = { 100, 255, 190 },
	},
	Volcan = {
		Horizon = { 200, 60, 30 },
		Voile = 2.2,
		Eclat = 0.3,
		Exposition = -0.15,
		Teinte = { 255, 230, 215 },
		Elements = "Eclairs",
		Couleur = { 255, 110, 50 },
	},
	Galaxie = {
		Horizon = { 60, 20, 120 },
		Voile = 2.5,
		Eclat = 0.5,
		Exposition = -0.2,
		Teinte = { 230, 220, 255 },
		Elements = "Planetes",
		Couleur = { 180, 120, 255 },
	},
	Marais = {
		Horizon = { 90, 80, 120 },
		Voile = 2.5,
		Eclat = 0,
		Exposition = -0.15,
		Teinte = { 235, 235, 250 },
		Elements = "Lunes",
		Couleur = { 220, 230, 180 },
	},
	Recif = {
		Horizon = { 30, 140, 200 },
		Voile = 1.8,
		Eclat = 0.1,
		Exposition = -0.15,
		Teinte = { 225, 245, 255 },
		Elements = "Bulles",
		Couleur = { 140, 230, 255 },
	},
	Bonbon = {
		Horizon = { 255, 140, 210 },
		Voile = 1,
		Eclat = 0.2,
		Exposition = -0.3,
		Teinte = { 255, 240, 250 },
		Elements = "Montgolfieres",
		Couleur = { 255, 130, 200 },
	},
	Jungle = {
		Horizon = { 70, 160, 90 },
		Voile = 1.6,
		Eclat = 0.05,
		Exposition = -0.1,
		Teinte = { 240, 255, 235 },
		Elements = "Soleil",
		Couleur = { 255, 220, 110 },
	},
	Ciel = {
		Horizon = { 160, 200, 255 },
		Voile = 0.8,
		Eclat = 0.2,
		Exposition = -0.4,
		Teinte = { 245, 250, 255 },
		Elements = "Montgolfieres",
		Couleur = { 255, 200, 110 },
	},
	Manoir = {
		Horizon = { 60, 40, 100 },
		Voile = 2.5,
		Eclat = 0,
		Exposition = -0.15,
		Teinte = { 230, 220, 255 },
		Elements = "Lunes",
		Couleur = { 200, 190, 255 },
	},
	Savane = {
		Horizon = { 255, 150, 70 },
		Voile = 1.4,
		Eclat = 0.3,
		Exposition = -0.3,
		Teinte = { 255, 240, 220 },
		Elements = "Soleil",
		Couleur = { 255, 160, 60 },
	},
	Mecanique = {
		Horizon = { 170, 120, 70 },
		Voile = 1.8,
		Eclat = 0.1,
		Exposition = -0.15,
		Teinte = { 255, 245, 230 },
		Elements = "Montgolfieres",
		Couleur = { 200, 150, 90 },
	},
	Zen = {
		Horizon = { 255, 160, 190 },
		Voile = 1,
		Eclat = 0.15,
		Exposition = -0.25,
		Teinte = { 255, 240, 245 },
		Elements = "Nuages",
		Couleur = { 255, 210, 225 },
	},
	Cavernes = {
		Horizon = { 40, 70, 150 },
		Voile = 2.5,
		Eclat = 0,
		Exposition = -0.1,
		Teinte = { 225, 235, 255 },
		Elements = "Etoiles",
		Couleur = { 140, 200, 255 },
	},
	Jouets = {
		Horizon = { 255, 200, 120 },
		Voile = 0.8,
		Eclat = 0.15,
		Exposition = -0.3,
		Teinte = { 255, 250, 240 },
		Elements = "Montgolfieres",
		Couleur = { 255, 90, 90 },
	},
	Automne = {
		Horizon = { 230, 120, 60 },
		Voile = 1.4,
		Eclat = 0.2,
		Exposition = -0.2,
		Teinte = { 255, 240, 225 },
		Elements = "Soleil",
		Couleur = { 255, 150, 70 },
	},
	Ferme = {
		Horizon = { 255, 210, 120 },
		Voile = 0.9,
		Eclat = 0.15,
		Exposition = -0.3,
		Teinte = { 255, 250, 235 },
		Elements = "Nuages",
		Couleur = { 255, 255, 255 },
	},
	Reves = {
		Horizon = { 90, 70, 180 },
		Voile = 2.2,
		Eclat = 0.4,
		Exposition = -0.15,
		Teinte = { 240, 230, 255 },
		Elements = "Lunes",
		Couleur = { 255, 240, 180 },
	},
	Plage = {
		Horizon = { 70, 180, 255 },
		Voile = 0.8,
		Eclat = 0.25,
		Exposition = -0.4,
		Teinte = { 245, 252, 255 },
		Elements = "Soleil",
		Couleur = { 255, 220, 100 },
	},
}

local function rgb(c: { number }): Color3
	return Color3.fromRGB(c[1], c[2], c[3])
end

-- Teinte locale du biome (ColorCorrection propre au client, sans toucher
-- à celles du serveur ni des événements).
local teinteLocale: ColorCorrectionEffect? = nil
local function teinte(): ColorCorrectionEffect
	if teinteLocale == nil or teinteLocale.Parent == nil then
		local c = Instance.new("ColorCorrectionEffect")
		c.Name = "TeinteBiome"
		c.Parent = Lighting
		teinteLocale = c
	end
	return teinteLocale :: ColorCorrectionEffect
end

local function appliquer(numero: number)
	local biome = Biomes.biome(numero)
	local ciel: Ciel = biome.Ciel or CIELS[biome.Id] or CIELS.Prairie
	CielBiome.afficher(ciel.Elements or "Nuages", rgb(ciel.Couleur or { 255, 255, 255 }), numero)
	local fondu = TweenInfo.new(2)
	local atmosphere = Lighting:FindFirstChild("AtmosphereCartoon")
	if atmosphere and atmosphere:IsA("Atmosphere") then
		TweenService:Create(atmosphere, fondu, {
			Color = rgb(biome.Brume),
			Density = biome.Densite,
			Decay = rgb(ciel.Horizon),
			Haze = ciel.Voile,
			Glare = ciel.Eclat,
		}):Play()
	end
	TweenService:Create(Lighting, fondu, { ExposureCompensation = ciel.Exposition }):Play()
	TweenService:Create(teinte(), fondu, { TintColor = rgb(ciel.Teinte) }):Play()
end

function Ambiances.demarrer()
	if demarre then
		return
	end
	demarre = true
	local joueur = Players.LocalPlayer
	local actuel = 1
	appliquer(1)
	task.spawn(function()
		while true do
			task.wait(0.5)
			local personnage = joueur.Character
			local racine = personnage and personnage:FindFirstChild("HumanoidRootPart")
			if racine and racine:IsA("BasePart") then
				local distance = racine.Position.Z - BORD_BASES
				local numero = if distance < 0 then 1 else Biomes.index(distance)
				if numero ~= actuel then
					actuel = numero
					appliquer(numero)
				end
			end
		end
	end)
end

return Ambiances
