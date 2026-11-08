--!strict
-- Logique pure des revenus des créatures et du portage.
-- Testable avec Lune (pas de dépendance à Roblox).
-- Roblox : require(script.Parent.X) ; Lune (tests) : require("./X").
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")
-- selene: allow(incorrect_standard_library_use)
local Fiche = if script then require(script.Parent.Fiche) else (require :: any)("./Fiche")
-- selene: allow(incorrect_standard_library_use)
local Biomes = if script then require(script.Parent.Biomes) else (require :: any)("./Biomes")

local Revenus = {}

local reglages = Config.Creatures
local revenus: { [string]: number } = reglages.RevenuParSeconde :: any

local function estNombreFini(valeur: any): boolean
	return type(valeur) == "number"
		and valeur == valeur
		and valeur > -math.huge
		and valeur < math.huge
end

-- Pièces valides : entier fini, entre 0 et PiecesMax.
local function borner(pieces: any): number
	if not estNombreFini(pieces) then
		return 0
	end
	return math.clamp(math.floor(pieces), 0, reglages.PiecesMax)
end

-- Revenu par seconde d'une créature (fiche « Rarete[:Taille[:Espece]] ») :
-- revenu de la rareté × multiplicateur de taille × valeur de son biome
-- (× 1,5 par biome), arrondi ; 0 si la fiche est invalide.
function Revenus.parSeconde(fiche: any): number
	local infos = Fiche.lire(fiche)
	if infos == nil then
		return 0
	end
	local biome = Biomes.indexEspece(infos.Espece) or 1
	local brut = (revenus[infos.Rarete] or 0) * Fiche.multiplicateur(infos.Taille)
	return math.floor(brut * Biomes.multiplicateur(biome) + 0.5)
end

-- Somme des revenus d'une liste de raretés (entrées invalides : 0).
function Revenus.total(liste: any): number
	if type(liste) ~= "table" then
		return 0
	end
	local somme = 0
	for _, rarete in ipairs(liste) do
		somme += Revenus.parSeconde(rarete)
	end
	return somme
end

-- Pièces + gain : entier, jamais négatif, plafonné à PiecesMax.
-- Un gain non fini ou non numérique laisse les pièces inchangées.
function Revenus.ajouter(pieces: any, gain: any): number
	local actuel = borner(pieces)
	if not estNombreFini(gain) then
		return actuel
	end
	return borner(actuel + gain)
end

-- WalkSpeed pendant le portage.
function Revenus.walkSpeedPortage(walkSpeed: number): number
	return walkSpeed * reglages.MultiplicateurPortage
end

return Revenus
