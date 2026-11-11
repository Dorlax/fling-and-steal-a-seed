--!strict
-- Logique pure des raids : validation du vol.
-- Testable avec Lune (pas de dépendance à Roblox).
-- Roblox : require(script.Parent.X) ; Lune (tests) : require("./X").
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")

export type ContexteVol = {
	memeJoueur: boolean,
	voleurVivant: boolean,
	voleurPorte: boolean,
	voleurDansBaseCible: boolean,
	emplacementValide: boolean,
	distance: number,
}

local Raid = {}

local reglages = Config.Raid

local function estNombreFini(valeur: any): boolean
	return type(valeur) == "number"
		and valeur == valeur
		and valeur > -math.huge
		and valeur < math.huge
end

-- Renvoie (true, nil) si le vol est permis, sinon (false, raison).
function Raid.verifierVol(contexte: ContexteVol): (boolean, string?)
	if contexte.memeJoueur then
		return false, "soi-même"
	end
	if not contexte.voleurVivant then
		return false, "indisponible"
	end
	if contexte.voleurPorte then
		return false, "porte"
	end
	if not contexte.voleurDansBaseCible then
		return false, "base"
	end
	if not contexte.emplacementValide then
		return false, "creature"
	end
	if not estNombreFini(contexte.distance) or contexte.distance > reglages.DistanceVol then
		return false, "portee"
	end
	return true, nil
end

-- Copie de `liste` sans l'élément `numero` (les suivants remontent) et la
-- rareté retirée ; numéro ou élément invalide : copie inchangée et nil.
function Raid.retirerEmplacement(liste: { any }, numero: any): ({ any }, string?)
	local copie = table.clone(liste)
	if
		not estNombreFini(numero)
		or numero % 1 ~= 0
		or numero < 1
		or numero > #copie
		or type(copie[numero]) ~= "string"
	then
		return copie, nil
	end
	local rarete = table.remove(copie, numero)
	return copie, rarete
end

return Raid
