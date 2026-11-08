--!strict
-- Logique pure des raids : validation du vol et du verrou, textes.
-- Testable avec Lune (pas de dépendance à Roblox).
-- Roblox : require(script.Parent.X) ; Lune (tests) : require("./X").
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")

export type ContexteVol = {
	memeJoueur: boolean,
	voleurVivant: boolean,
	voleurPorte: boolean,
	voleurDansBaseCible: boolean,
	baseVerrouillee: boolean,
	emplacementValide: boolean,
	distance: number,
}

export type ContexteVerrou = {
	estProprietaire: boolean,
	vivant: boolean,
	distance: number,
	pieces: number?,
	maintenant: number,
	verrouJusqua: number?,
	pretA: number?,
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
	if contexte.baseVerrouillee then
		return false, "verrouillee"
	end
	if not contexte.emplacementValide then
		return false, "creature"
	end
	if not estNombreFini(contexte.distance) or contexte.distance > reglages.DistanceVol then
		return false, "portee"
	end
	return true, nil
end

-- Renvoie (true, nil) si l'achat du verrou est permis, sinon (false, raison).
function Raid.verifierVerrou(contexte: ContexteVerrou): (boolean, string?)
	if not contexte.estProprietaire then
		return false, "proprietaire"
	end
	if not contexte.vivant then
		return false, "indisponible"
	end
	if not estNombreFini(contexte.distance) or contexte.distance > reglages.DistanceVerrou then
		return false, "portee"
	end
	if Raid.estVerrouillee(contexte.maintenant, contexte.verrouJusqua) then
		return false, "verrouillee"
	end
	local pretA = contexte.pretA
	if estNombreFini(pretA) and contexte.maintenant < (pretA :: number) then
		return false, "recharge"
	end
	local pieces = contexte.pieces
	if not estNombreFini(pieces) or (pieces :: number) < reglages.PrixVerrou then
		return false, "pieces"
	end
	return true, nil
end

-- Achat à l'instant `maintenant` : (fin du verrou, prochaine disponibilité).
function Raid.acheterVerrou(maintenant: number): (number, number)
	return maintenant + reglages.DureeVerrou, maintenant + reglages.DureeVerrou + reglages.Recharge
end

function Raid.estVerrouillee(maintenant: number, verrouJusqua: number?): boolean
	if not estNombreFini(verrouJusqua) or not estNombreFini(maintenant) then
		return false
	end
	return maintenant < (verrouJusqua :: number)
end

-- Vrai seulement pour un non-propriétaire présent dans une base verrouillée.
function Raid.doitExpulser(
	estProprietaire: boolean,
	dansLaBase: boolean,
	verrouillee: boolean
): boolean
	return estProprietaire == false and dansLaBase == true and verrouillee == true
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

-- Texte du panneau de la porte.
function Raid.texteVerrou(maintenant: number, verrouJusqua: number?, pretA: number?): string
	if Raid.estVerrouillee(maintenant, verrouJusqua) then
		return "VERROUILLÉ " .. math.ceil((verrouJusqua :: number) - maintenant) .. " s"
	end
	if estNombreFini(pretA) and estNombreFini(maintenant) and maintenant < (pretA :: number) then
		return "Prêt dans " .. math.ceil((pretA :: number) - maintenant) .. " s"
	end
	return "Verrouiller : " .. reglages.PrixVerrou .. " pièces"
end

return Raid
