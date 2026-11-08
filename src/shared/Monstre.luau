--!strict
-- Logique pure des monstres : zones, limite des bases, coups, cible, nombre
-- voulu et cycle jour/nuit. Testable avec Lune (pas de dépendance à Roblox).
-- Roblox : require(script.Parent.X) ; Lune (tests) : require("./X").
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")
-- selene: allow(incorrect_standard_library_use)
local Lancer = if script then require(script.Parent.Lancer) else (require :: any)("./Lancer")

export type Position = { X: number, Y: number, Z: number }

export type Contexte = {
	zone: string,
	cibleVivante: boolean,
	cibleDansSaBase: boolean,
	distance: number,
	maintenant: number,
	pretA: number?, -- fin de la recharge du monstre
	protegeeJusqua: number?, -- fin de protection de la cible
}

export type Candidat = { distance: number, valide: boolean }

local Monstre = {}

local reglages = Config.Monstres

-- Sol des Terres Sauvages (voir TerresSauvages) : 800 studs de large centrés
-- sur X = 0, de Z = BordBases à BordBases + DistanceMax + 40.
local MARGE_SOL = 5
local DEMI_LARGEUR = 400 - MARGE_SOL
local Z_FOND = reglages.BordBases + Config.Lancer.DistanceMax + 40 - MARGE_SOL

local function estNombreFini(valeur: any): boolean
	return type(valeur) == "number"
		and valeur == valeur
		and valeur > -math.huge
		and valeur < math.huge
end

local function avant(maintenant: number, limite: number?): boolean
	return estNombreFini(limite) and maintenant < (limite :: number)
end

local function borner(valeur: any, minimum: number, maximum: number, defaut: number): number
	if not estNombreFini(valeur) then
		return defaut
	end
	return math.clamp(valeur, minimum, maximum)
end

-- Réglages d'une zone (Proche par défaut si le nom est inconnu).
function Monstre.reglagesZone(zone: string): any
	local zones: any = reglages.Zones
	return zones[zone] or zones.Proche
end

-- Zone d'une position, mêmes seuils que les lancers.
function Monstre.zoneDe(position: Position): string
	return Lancer.zone(position.Z - reglages.BordBases)
end

-- Bande de Z [min, max] où vivent les monstres d'une zone.
function Monstre.bandeZone(zone: string): (number, number)
	local zones = Config.Lancer.Zones
	local minimum = reglages.BordBases + reglages.MargeBases
	local maximum = Z_FOND
	for i, z in zones do
		if z.Nom == zone then
			minimum = math.max(minimum, reglages.BordBases + z.Min)
			local suivante = zones[i + 1]
			if suivante then
				maximum = reglages.BordBases + suivante.Min - 1
			end
			break
		end
	end
	return minimum, maximum
end

-- Position ramenée sur le sol des Terres Sauvages, jamais dans une base
-- (Z >= BordBases + MargeBases). Avec `zone`, Z reste aussi dans sa bande.
function Monstre.limiter(position: Position, zone: string?): Position
	local zMin = reglages.BordBases + reglages.MargeBases
	local zMax = Z_FOND
	if zone ~= nil then
		zMin, zMax = Monstre.bandeZone(zone)
	end
	local y = if estNombreFini(position.Y) then position.Y else 0
	return {
		X = borner(position.X, -DEMI_LARGEUR, DEMI_LARGEUR, 0),
		Y = y,
		Z = borner(position.Z, zMin, zMax, zMin),
	}
end

-- Renvoie true, ou false et la première raison de refus trouvée.
-- (La protection passe avant la recharge : un joueur protégé l'apprend.)
function Monstre.peutFrapper(contexte: Contexte): (boolean, string?)
	if not contexte.cibleVivante then
		return false, "indisponible"
	end
	if contexte.cibleDansSaBase then
		return false, "base"
	end
	if avant(contexte.maintenant, contexte.protegeeJusqua) then
		return false, "protegee"
	end
	if avant(contexte.maintenant, contexte.pretA) then
		return false, "recharge"
	end
	local portee = Monstre.reglagesZone(contexte.zone).PorteeCoup
	if not estNombreFini(contexte.distance) or contexte.distance > portee then
		return false, "portee"
	end
	return true, nil
end

-- Indice du candidat valide le plus proche à moins de `portee`, ou nil.
function Monstre.choisirCible(candidats: { Candidat }, portee: number): number?
	local meilleur: number? = nil
	local meilleureDistance = math.huge
	for indice, candidat in candidats do
		if
			candidat.valide
			and estNombreFini(candidat.distance)
			and candidat.distance <= portee
			and candidat.distance < meilleureDistance
		then
			meilleur = indice
			meilleureDistance = candidat.distance
		end
	end
	return meilleur
end

-- Nombre de monstres voulu dans une zone.
function Monstre.nombreVoulu(zone: string, nuit: boolean): number
	local r = Monstre.reglagesZone(zone)
	return if nuit then r.NombreNuit else r.NombreJour
end

-- Phase du cycle à l'instant `t` et secondes restantes dans cette phase.
function Monstre.phase(t: number): (string, number)
	local cycle = Config.Cycle
	local duree = cycle.DureeJour + cycle.DureeNuit
	local instant = if estNombreFini(t) then t else 0
	local dans = instant % duree
	if dans < cycle.DureeJour then
		return "Jour", cycle.DureeJour - dans
	end
	return "Nuit", duree - dans
end

return Monstre
