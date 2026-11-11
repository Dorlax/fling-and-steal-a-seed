--!strict
-- Logique pure du plaquage : validation, choix de la cible, texte du bouton.
-- Testable avec Lune (pas de dépendance à Roblox).
-- Roblox : require(script.Parent.X) ; Lune (tests) : require("./X").
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")

export type Contexte = {
	memeJoueur: boolean,
	plaqueurVivant: boolean,
	plaqueurAuSol: boolean,
	plaqueurDansSaBase: boolean,
	cibleVivante: boolean,
	ciblePorte: boolean,
	cibleDansSaBase: boolean,
	distance: number,
	maintenant: number,
	pretA: number?, -- fin du délai du plaqueur
	protegeeJusqua: number?, -- fin de protection de la cible
	-- Cible derrière la ligne de la zone sûre (hors voleur portant une
	-- créature volée) : intouchable.
	cibleEnZoneSure: boolean?,
}

export type Candidat = { distance: number, valide: boolean }

local Plaquage = {}

local function estNombreFini(valeur: any): boolean
	return type(valeur) == "number"
		and valeur == valeur
		and valeur > -math.huge
		and valeur < math.huge
end

local function avant(maintenant: number, limite: number?): boolean
	return estNombreFini(limite) and maintenant < (limite :: number)
end

-- Renvoie true, ou false et la première raison de refus trouvée.
function Plaquage.verifier(contexte: Contexte): (boolean, string?)
	if contexte.memeJoueur then
		return false, "soi-même"
	end
	if not contexte.plaqueurVivant or contexte.plaqueurAuSol then
		return false, "indisponible"
	end
	if avant(contexte.maintenant, contexte.pretA) then
		return false, "recuperation"
	end
	if contexte.plaqueurDansSaBase then
		return false, "base"
	end
	if not contexte.cibleVivante or not contexte.ciblePorte then
		return false, "cible"
	end
	if contexte.cibleDansSaBase then
		return false, "base"
	end
	if contexte.cibleEnZoneSure == true then
		return false, "zonesure"
	end
	if avant(contexte.maintenant, contexte.protegeeJusqua) then
		return false, "protegee"
	end
	if not estNombreFini(contexte.distance) or contexte.distance > Config.Plaquage.Portee then
		return false, "portee"
	end
	return true, nil
end

-- Indice du candidat valide le plus proche (égalité : le premier), ou nil.
function Plaquage.choisirCible(candidats: { Candidat }): number?
	local meilleur: number? = nil
	local meilleureDistance = math.huge
	for indice, candidat in candidats do
		if candidat.valide and estNombreFini(candidat.distance) then
			if meilleur == nil or candidat.distance < meilleureDistance then
				meilleur = indice
				meilleureDistance = candidat.distance
			end
		end
	end
	return meilleur
end

-- « PLAQUER ! » si prêt, sinon les secondes restantes arrondies au supérieur.
function Plaquage.texteBouton(maintenant: number, pretA: number?): string
	if not avant(maintenant, pretA) then
		return "PLAQUER !"
	end
	return tostring(math.ceil((pretA :: number) - maintenant))
end

return Plaquage
