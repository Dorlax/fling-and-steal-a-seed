--!strict
-- Logique pure des pièges : validation de la pose, victimes, vitesse,
-- expiration et texte des boutons. Testable avec Lune (sans Roblox).
-- Roblox : require(script.Parent.X) ; Lune (tests) : require("./X").
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")

export type Position = { X: number, Y: number, Z: number }

export type ContextePose = {
	typePiege: any,
	vivant: boolean,
	immobilise: boolean,
	pieces: any,
	actifs: number,
	maintenant: number,
	pretA: number?, -- fin du délai entre deux poses
	position: Position,
	dansUneBase: boolean,
	distancePlusProche: number?, -- distance au piège le plus proche (tous poseurs)
}

export type ContexteVictime = {
	memePoseur: boolean,
	vivante: boolean,
	maintenant: number,
	protegeeJusqua: number?,
	immobileJusqua: number?,
}

local Piege = {}

local reglages = Config.Pieges

local function estNombreFini(valeur: any): boolean
	return type(valeur) == "number"
		and valeur == valeur
		and valeur > -math.huge
		and valeur < math.huge
end

local function avant(maintenant: any, limite: any): boolean
	return estNombreFini(maintenant) and estNombreFini(limite) and maintenant < limite
end

-- Vrai seulement pour un nom de Config.Pieges.Ordre.
function Piege.estType(valeur: any): boolean
	return type(valeur) == "string" and table.find(reglages.Ordre, valeur) ~= nil
end

local function horsZone(position: any): boolean
	if type(position) ~= "table" then
		return true
	end
	local x, z = position.X, position.Z
	if not estNombreFini(x) or not estNombreFini(z) then
		return true
	end
	local bord = Config.Monstres.BordBases
	return z < bord + reglages.MargeBases
		or z > bord + Config.Lancer.DistanceMax + 40
		or math.abs(x) > 400
end

-- Renvoie true, ou false et la première raison de refus trouvée.
function Piege.verifierPose(contexte: ContextePose): (boolean, string?)
	if not Piege.estType(contexte.typePiege) then
		return false, "type"
	end
	if contexte.vivant ~= true or contexte.immobilise == true then
		return false, "indisponible"
	end
	if avant(contexte.maintenant, contexte.pretA) then
		return false, "delai"
	end
	if not estNombreFini(contexte.actifs) or contexte.actifs >= reglages.MaxParJoueur then
		return false, "limite"
	end
	local prix = reglages.Types[contexte.typePiege].Prix
	if not estNombreFini(contexte.pieces) or contexte.pieces < prix then
		return false, "pieces"
	end
	if contexte.dansUneBase == true or horsZone(contexte.position) then
		return false, "zone"
	end
	local distance = contexte.distancePlusProche
	if distance ~= nil and (distance ~= distance or distance < reglages.EcartMin) then
		return false, "ecart"
	end
	return true, nil
end

-- Le piège peut-il affecter ce joueur ? true, ou false et la raison.
function Piege.peutAffecter(contexte: ContexteVictime): (boolean, string?)
	if contexte.memePoseur then
		return false, "poseur"
	end
	if contexte.vivante ~= true then
		return false, "morte"
	end
	if avant(contexte.maintenant, contexte.protegeeJusqua) then
		return false, "protegee"
	end
	if avant(contexte.maintenant, contexte.immobileJusqua) then
		return false, "deja"
	end
	return true, nil
end

-- Vrai si le piège a dépassé sa durée de vie (entrées invalides : vrai).
function Piege.estExpire(poseA: number, maintenant: number): boolean
	if not estNombreFini(poseA) or not estNombreFini(maintenant) then
		return true
	end
	return maintenant >= poseA + reglages.DureeVie
end

-- Distance finie et au plus `rayon`.
function Piege.dansRayon(distance: any, rayon: number): boolean
	return estNombreFini(distance) and distance <= rayon
end

-- WalkSpeed final : 0 si immobilisé, ralenti dans la glu, sinon la base.
function Piege.walkSpeed(base: number, immobilise: boolean, englue: boolean): number
	if immobilise then
		return 0
	end
	local vitesse = if estNombreFini(base) then math.max(base, 0) else Config.Forge.WalkSpeedBase
	if englue then
		vitesse *= reglages.Types.Glu.Multiplicateur
	end
	return vitesse
end

-- « <Nom> <Prix> » si prêt, secondes restantes pendant le délai, « MAX » à la limite.
function Piege.texteBouton(
	typePiege: string,
	maintenant: number,
	pretA: number?,
	actifs: number
): string
	if estNombreFini(actifs) and actifs >= reglages.MaxParJoueur then
		return "MAX"
	end
	if avant(maintenant, pretA) then
		return tostring(math.ceil((pretA :: number) - maintenant))
	end
	local infos = reglages.Types[typePiege]
	if infos == nil then
		return "?"
	end
	return infos.Nom .. " " .. infos.Prix
end

return Piege
