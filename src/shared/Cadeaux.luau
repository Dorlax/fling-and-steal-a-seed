--!strict
-- Logique pure des cadeaux : récompense de connexion (série de 7 jours),
-- défis du jour, montants. Testable avec Lune.
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")

local Cadeaux = {}

-- Numéro du jour UTC d'un instant (secondes).
function Cadeaux.jour(instant: number): number
	return math.floor(instant / 86400)
end

-- Cadeau de connexion : (disponible, numéro de la série 1..7 qu'on obtient).
-- Récupéré hier -> série suivante ; plus ancien -> on repart à 1.
function Cadeaux.quotidien(serie: any, dernierJour: any, aujourdhui: number): (boolean, number)
	local s = if type(serie) == "number" and serie == serie then math.floor(serie) else 0
	local d = if type(dernierJour) == "number" and dernierJour == dernierJour
		then math.floor(dernierJour)
		else -1
	if d == aujourdhui then
		return false, math.clamp(s, 1, #Config.Quotidien.Recompenses)
	end
	if d == aujourdhui - 1 and s >= 1 then
		return true, (s % #Config.Quotidien.Recompenses) + 1
	end
	return true, 1
end

-- Pièces d'une récompense « Minutes » de revenu, avec minimum.
function Cadeaux.pieces(revenuParSeconde: any, minutes: number): number
	local r = if type(revenuParSeconde) == "number"
			and revenuParSeconde == revenuParSeconde
		then math.max(revenuParSeconde, 0)
		else 0
	return math.max(Config.Quotidien.Min, math.floor(r * minutes * 60))
end

-- Les défis du jour pour un joueur : liste d'identifiants (toujours les mêmes
-- pour un jour et un joueur donnés, tous différents).
function Cadeaux.defisDu(jour: number, userId: number): { string }
	local ids = {}
	for id in Config.Defis.Liste do
		table.insert(ids, id)
	end
	table.sort(ids)
	local graine = (jour * 7919 + math.abs(userId) * 104729) % 2147483647
	local choisis = {}
	for _ = 1, math.min(Config.Defis.Nombre, #ids) do
		graine = (graine * 48271) % 2147483647
		local k = graine % #ids + 1
		table.insert(choisis, ids[k])
		table.remove(ids, k)
	end
	return choisis
end

-- Texte d'un défi (« Lance 15 graines »).
function Cadeaux.texteDefi(id: string): string
	local d = (Config.Defis.Liste :: any)[id]
	return if d then string.format(d.Texte, d.Objectif) else id
end

-- Code promo normalisé (majuscules, sans espaces), ou nil s'il est inconnu.
function Cadeaux.code(texte: any): string?
	if type(texte) ~= "string" or #texte > 40 then
		return nil
	end
	local c = string.upper((string.gsub(texte, "%s", "")))
	return if (Config.Codes :: any)[c] then c else nil
end

return Cadeaux
