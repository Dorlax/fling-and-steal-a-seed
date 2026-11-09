--!strict
-- Logique pure du lancer : distance, zone, tirage de rareté, texte des taux.
-- Testable avec Lune (pas de dépendance à Roblox).
-- Roblox : require(script.Parent.X) ; Lune (tests) : require("./X").
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")
-- selene: allow(incorrect_standard_library_use)
local Biomes = if script then require(script.Parent.Biomes) else (require :: any)("./Biomes")

local Lancer = {}

local function estNombreFini(valeur: any): boolean
	return type(valeur) == "number"
		and valeur == valeur
		and valeur > -math.huge
		and valeur < math.huge
end

-- Distance en studs : la Force et le bonus de jauge s'additionnent. Plafonds :
-- DistanceMax (sécurité) et la fin du dernier biome.
function Lancer.distance(force: number, bonusJauge: number): number
	local reglages = Config.Lancer
	local forceNettoyee = 0
	if type(force) == "number" and force == force and force > 0 then
		forceNettoyee = math.min(force, Config.Forge.PlafondStat)
	end
	local bonus = if estNombreFini(bonusJauge) and bonusJauge > 0 then bonusJauge else 0
	local lineaire = math.min(forceNettoyee, Config.Forge.StatLineaire)
	local brute = reglages.DistanceMin + lineaire * reglages.DistanceParForce + bonus
	if forceNettoyee > Config.Forge.StatLineaire then
		-- Au-delà, chaque doublement de la Force fait avancer d'un biome.
		brute += math.log(forceNettoyee / Config.Forge.StatLineaire, 2) * Biomes.Longueur
	end
	return math.min(reglages.DistanceMax, Biomes.distanceMax(), brute)
end

-- Sous-zone d'atterrissage dans son biome : celle dont le Min est le plus
-- grand <= distance dans le biome (chaque biome a ses Proche/Moyenne/Lointaine).
function Lancer.zone(distanceTotale: number): string
	local zones = Config.Lancer.Zones
	local choisie = zones[1]
	if not estNombreFini(distanceTotale) then
		return choisie.Nom
	end
	local distance = Biomes.dansBiome(distanceTotale)
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

-- Taux (en %) d'une zone avec une graine de `chance` : le poids de la rareté
-- de rang r est multiplié par (1 + chance)^(r - 1), puis tout est ramené à
-- 100 %. Sans graine (chance 0) : exactement les taux du Plan.
function Lancer.tauxAvecChance(zone: string, chance: number?): { [string]: number }
	local raretes: any = Config.Raretes
	local taux = raretes.Taux[zone] or raretes.Taux[Config.Lancer.Zones[1].Nom]
	local c = if estNombreFini(chance) and (chance :: number) > 0 then chance :: number else 0
	local poids: { [string]: number } = {}
	local total = 0
	for rang, rarete in raretes.Ordre do
		local p = taux[rarete] * (1 + c) ^ (rang - 1)
		poids[rarete] = p
		total += p
	end
	for rarete, p in poids do
		poids[rarete] = p / total * 100
	end
	return poids
end

-- Tirage de la rareté avec une graine (ne dépend pas non plus de la jauge).
function Lancer.tirerRareteChance(zone: string, aleatoire: number, chance: number?): string
	local raretes: any = Config.Raretes
	if not estNombreFini(chance) or (chance :: number) <= 0 then
		return Lancer.tirerRarete(zone, aleatoire)
	end
	local taux = Lancer.tauxAvecChance(zone, chance)
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
-- `chance` (facultatif) : taux avec la graine équipée.
function Lancer.texteTaux(zone: string, chance: number?): string
	local raretes: any = Config.Raretes -- indexé par des noms dynamiques
	if raretes.Taux[zone] == nil then
		return zone
	end
	local brut = Lancer.tauxAvecChance(zone, chance)
	local taux: { [string]: number } = {}
	for rarete, valeur in brut do
		-- Arrondi à 0,01 % pour l'affichage.
		taux[rarete] = math.floor(valeur * 100 + 0.5) / 100
	end
	local morceaux = {}
	for _, rarete in raretes.Ordre do
		table.insert(morceaux, `{raretes.Noms[rarete]} {formaterNombre(taux[rarete])} %`)
	end
	return `{zone} : {table.concat(morceaux, " · ")}`
end

return Lancer
