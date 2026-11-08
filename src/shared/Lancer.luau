--!strict
-- Logique pure du lancer : distance, zone, tirage de rareté, texte des taux.
-- Testable avec Lune (pas de dépendance à Roblox).
-- Roblox : require(script.Parent.X) ; Lune (tests) : require("./X").
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")

local Lancer = {}

local function estNombreFini(valeur: any): boolean
	return type(valeur) == "number"
		and valeur == valeur
		and valeur > -math.huge
		and valeur < math.huge
end

-- Distance en studs : la Force et le bonus de jauge s'additionnent, plafond DistanceMax.
function Lancer.distance(force: number, bonusJauge: number): number
	local reglages = Config.Lancer
	local forceNettoyee = 0
	if type(force) == "number" and force == force and force > 0 then
		forceNettoyee = math.min(force, Config.Forge.PlafondStat)
	end
	local bonus = if estNombreFini(bonusJauge) and bonusJauge > 0 then bonusJauge else 0
	local brute = reglages.DistanceMin + forceNettoyee * reglages.DistanceParForce + bonus
	return math.min(reglages.DistanceMax, brute)
end

-- Zone d'atterrissage : celle dont le Min est le plus grand <= distance.
function Lancer.zone(distance: number): string
	local zones = Config.Lancer.Zones
	local choisie = zones[1]
	if not estNombreFini(distance) then
		return choisie.Nom
	end
	for _, zone in zones do
		if zone.Min <= distance and zone.Min >= choisie.Min then
			choisie = zone
		end
	end
	return choisie.Nom
end

-- Tirage de la rareté : ne dépend QUE de la zone et du nombre aléatoire [0, 1[.
function Lancer.tirerRarete(zone: string, aleatoire: number): string
	local raretes: any = Config.Raretes -- indexé par des noms dynamiques
	local taux = raretes.Taux[zone] or raretes.Taux[Config.Lancer.Zones[1].Nom]
	local valeur = if estNombreFini(aleatoire) then math.clamp(aleatoire, 0, 1) else 0
	local cumul = 0
	for _, rarete in raretes.Ordre do
		cumul += taux[rarete] / 100
		if valeur < cumul then
			return rarete
		end
	end
	return raretes.Ordre[#raretes.Ordre]
end

-- Nombre à la française : « 70 », « 1,8 », « 0,2 » (jamais « 1,0 »).
local function formaterNombre(n: number): string
	if n == math.floor(n) then
		return string.format("%d", n)
	end
	local texte = string.format("%.2f", n)
	texte = string.gsub(texte, "0+$", "")
	return (string.gsub(texte, "%.", ","))
end

-- Ex. « Proche : Commune 70 % · Rare 22 % · Épique 6 % · Légendaire 1,8 % · Mythique 0,2 % »
function Lancer.texteTaux(zone: string): string
	local raretes: any = Config.Raretes -- indexé par des noms dynamiques
	local taux = raretes.Taux[zone]
	if taux == nil then
		return zone
	end
	local morceaux = {}
	for _, rarete in raretes.Ordre do
		table.insert(morceaux, `{raretes.Noms[rarete]} {formaterNombre(taux[rarete])} %`)
	end
	return `{zone} : {table.concat(morceaux, " · ")}`
end

return Lancer
