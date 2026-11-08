--!strict
-- Logique pure de la jauge de timing : position (onde triangle) et palier.
-- Testable avec Lune (pas de dépendance à Roblox).
-- Roblox : require(script.Parent.X) ; Lune (tests) : require("./X").
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")

export type Palier = {
	Couleur: string,
	Min: number,
	Bonus: number,
	Message: string,
}

local Jauge = {}

local function estNombreFini(valeur: any): boolean
	return type(valeur) == "number"
		and valeur == valeur
		and valeur > -math.huge
		and valeur < math.huge
end

-- Onde triangle : 0 à t = 0, 1 à periode / 2, 0 à periode, puis se répète.
-- t négatif (ou invalide) est traité comme 0.
function Jauge.position(t: number, periode: number?): number
	local duree = periode or Config.Lancer.Jauge.Periode
	if not estNombreFini(t) or t <= 0 or not estNombreFini(duree) or duree <= 0 then
		return 0
	end
	local phase = (t % duree) / duree
	local p = if phase <= 0.5 then phase * 2 else 2 - phase * 2
	return math.clamp(p, 0, 1)
end

-- Palier dont le Min est le plus grand <= p (p borné à [0, 1]).
function Jauge.palier(p: number): Palier
	local valeur = if estNombreFini(p) then math.clamp(p, 0, 1) else 0
	local paliers = Config.Lancer.Jauge.Paliers
	local choisi = paliers[1]
	for _, palier in paliers do
		if palier.Min <= valeur and palier.Min >= choisi.Min then
			choisi = palier
		end
	end
	return choisi
end

return Jauge
