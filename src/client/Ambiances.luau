--!strict
-- Ambiance de chaque biome (côté client, affichage seulement) : couleur et
-- densité de l'atmosphère changent en douceur quand le joueur change de
-- biome, et un bandeau annonce le nom du biome et sa valeur.
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Biomes = require(Shared:WaitForChild("Biomes"))
local Config = require(Shared:WaitForChild("Config"))
local Bandeaux = require(script.Parent:WaitForChild("Bandeaux"))

local Ambiances = {}

local BORD_BASES = Config.Monstres.BordBases
local demarre = false

local function appliquer(numero: number)
	local biome = Biomes.biome(numero)
	local atmosphere = Lighting:FindFirstChild("AtmosphereCartoon")
	if atmosphere and atmosphere:IsA("Atmosphere") then
		local c = biome.Brume
		TweenService:Create(atmosphere, TweenInfo.new(2), {
			Color = Color3.fromRGB(c[1], c[2], c[3]),
			Density = biome.Densite,
		}):Play()
	end
end

function Ambiances.demarrer()
	if demarre then
		return
	end
	demarre = true
	local joueur = Players.LocalPlayer
	local actuel = 1
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
					local biome = Biomes.biome(numero)
					Bandeaux.afficher(
						`{biome.Nom} · créatures ×{Biomes.texteMultiplicateur(numero)}`
					)
				end
			end
		end
	end)
end

return Ambiances
