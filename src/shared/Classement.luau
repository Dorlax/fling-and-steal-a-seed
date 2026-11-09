--!strict
-- Logique pure des classements : score mondial des revenus, tri, record de
-- biome. Testable avec Lune.
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")

export type Entree = { Nom: string, Valeur: number }

local Classement = {}

-- Un OrderedDataStore ne garde que des entiers : les revenus (qui grandissent
-- sans limite) y sont rangés en millièmes de log10. Toujours croissant.
function Classement.scoreRevenus(revenu: any): number
	if type(revenu) ~= "number" or revenu ~= revenu or revenu <= 0 then
		return 0
	end
	if revenu == math.huge then
		return 308000
	end
	return math.floor(math.log10(1 + revenu) * 1000)
end

-- Revenu approximatif d'un score (inverse de scoreRevenus).
function Classement.revenusDeScore(score: any): number
	if type(score) ~= "number" or score ~= score or score <= 0 then
		return 0
	end
	return 10 ^ (score / 1000) - 1
end

-- Entrées valides triées par valeur décroissante (puis par nom), coupées à
-- `taille` (Config.Classement.Taille par défaut).
function Classement.trier(entrees: any, taille: number?): { Entree }
	local propres: { Entree } = {}
	if type(entrees) ~= "table" then
		return propres
	end
	for _, e in ipairs(entrees) do
		if
			type(e) == "table"
			and type(e.Nom) == "string"
			and type(e.Valeur) == "number"
			and e.Valeur == e.Valeur
		then
			table.insert(propres, { Nom = e.Nom, Valeur = e.Valeur })
		end
	end
	table.sort(propres, function(a, b)
		if a.Valeur ~= b.Valeur then
			return a.Valeur > b.Valeur
		end
		return a.Nom < b.Nom
	end)
	local limite = taille or Config.Classement.Taille
	while #propres > limite do
		table.remove(propres)
	end
	return propres
end

-- Nouveau record de biome : (record, true si battu). Valeurs invalides -> 1.
function Classement.record(ancien: any, biome: any): (number, boolean)
	local a = if type(ancien) == "number"
			and ancien == ancien
			and ancien >= 1
		then math.floor(ancien)
		else 1
	if type(biome) ~= "number" or biome ~= biome or biome <= a then
		return a, false
	end
	return math.floor(biome), true
end

return Classement
