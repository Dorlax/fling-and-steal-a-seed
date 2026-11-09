--!strict
-- Logique pure des passes Robux : nom d'attribut, possession, multiplicateurs.
-- La possession est vérifiée par le serveur (MarketplaceService) qui écrit
-- l'attribut « Pass<Id> » sur le Player ; rien ne vient du client.
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")

local Passes = {}

-- Nom de l'attribut du Player pour un passe : « PassX2Force »…
function Passes.attribut(id: string): string
	return "Pass" .. id
end

-- Vrai si l'identifiant est un passe connu.
function Passes.existe(id: any): boolean
	return type(id) == "string" and (Config.Passes.Liste :: any)[id] ~= nil
end

-- Le passe dont l'identifiant Roblox est `numero` (nil si aucun ou numéro 0).
function Passes.depuisNumero(numero: any): string?
	if type(numero) ~= "number" or numero <= 0 then
		return nil
	end
	for _, id in Config.Passes.Ordre do
		if (Config.Passes.Liste :: any)[id].Id == numero then
			return id
		end
	end
	return nil
end

-- Multiplicateur du gain de Forge pour une stat (2 avec le passe × 2 de la stat).
function Passes.multiplicateurStat(stat: string, possedeX2: any): number
	if (stat == "Force" or stat == "Vitesse") and possedeX2 == true then
		return 2
	end
	return 1
end

-- Multiplicateur des revenus (2 avec le passe × 2 Pièces).
function Passes.multiplicateurPieces(possede: any): number
	return if possede == true then 2 else 1
end

return Passes
