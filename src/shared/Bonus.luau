--!strict
-- Progression permanente et boosts (logique pure, testable avec Lune) :
--  * Renaissance : on repart à 0 pièce (créatures, Forge et stats gardées)
--    contre un multiplicateur de revenus et de gain de Force/Vitesse ;
--  * Collection : chaque page de biome complète du Bestiaire ajoute un bonus ;
--  * Boost temporaire (roue) : revenus × Boost pendant sa durée.
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")

local Bonus = {}

local function entier(n: any): number
	if type(n) ~= "number" or n ~= n or n < 0 or n == math.huge then
		return 0
	end
	return math.floor(n)
end

-- Pièces nécessaires pour la renaissance suivante (après `n` renaissances).
function Bonus.prixRenaissance(n: any): number
	local r = Config.Renaissance
	return r.PrixBase * r.CroissancePrix ^ entier(n)
end

-- Multiplicateur de revenus des renaissances (× MultRevenus par renaissance).
function Bonus.revenusRenaissance(n: any): number
	return Config.Renaissance.MultRevenus ^ entier(n)
end

-- Multiplicateur du gain de la Forge (+ BonusForge par renaissance).
function Bonus.forgeRenaissance(n: any): number
	return 1 + Config.Renaissance.BonusForge * entier(n)
end

-- Multiplicateur de revenus de la collection (+ BonusPage par page complète).
function Bonus.revenusCollection(pages: any): number
	return 1 + Config.Renaissance.BonusPage * entier(pages)
end

-- Multiplicateur permanent total des revenus.
function Bonus.revenus(renaissances: any, pages: any): number
	return Bonus.revenusRenaissance(renaissances) * Bonus.revenusCollection(pages)
end

-- Boost temporaire actif ? (fin = heure serveur de fin)
function Bonus.boost(fin: any, maintenant: number): number
	if type(fin) == "number" and fin == fin and maintenant < fin then
		return Config.Roue.Boost
	end
	return 1
end

-- Infos d'une graine (la Simple si l'identifiant est inconnu).
function Bonus.graine(id: any): any
	local liste: any = Config.Graines.Liste
	return if type(id) == "string" and liste[id] then liste[id] else liste.Simple
end

-- La meilleure de deux graines (selon l'ordre de Config.Graines).
function Bonus.meilleureGraine(a: any, b: any): string
	local ordre = Config.Graines.Ordre
	local ia = if type(a) == "string" then table.find(ordre, a) or 1 else 1
	local ib = if type(b) == "string" then table.find(ordre, b) or 1 else 1
	return ordre[math.max(ia, ib)]
end

return Bonus
