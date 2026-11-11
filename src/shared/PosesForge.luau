--!strict
-- Poses du personnage sur la Forge (calcul pur, testable avec Lune) :
-- course (Vitesse), soulevé de barre (Force), corde à sauter (Double).
-- Angles en radians. Conventions (appliquées par le client à R15 / R6) :
--   hanche, epaule > 0 : membre vers l'avant (epaule ~3 : bras au-dessus de la tête)
--   genou, coude > 0 : articulation pliée
--   ecart > 0 : bras écarté du corps ; penche > 0 : buste vers l'avant
--   tete > 0 : regard vers le haut ; dy : décalage vertical du corps (studs)
local PosesForge = {}

export type Pose = {
	dy: number,
	penche: number,
	tete: number,
	hancheG: number,
	hancheD: number,
	genouG: number,
	genouD: number,
	epauleG: number,
	epauleD: number,
	ecartG: number,
	ecartD: number,
	coudeG: number,
	coudeD: number,
}

local function melange(a: number, b: number, t: number): number
	return a + (b - a) * t
end

local function borne(i: number): number
	return if i ~= i then 0 else math.clamp(i, 0, 1)
end

-- Vitesse de l'animation (radians par seconde, ou répétitions par seconde
-- pour le soulevé) selon l'intensité de la série (0 -> 1).
function PosesForge.tempo(mode: string, intensite: number): number
	local i = borne(intensite)
	if mode == "Vitesse" then
		return melange(8, 20, i) -- foulées de plus en plus rapides
	elseif mode == "Force" then
		return melange(0.4, 0.8, i) -- répétitions (épaulé-jeté) par seconde
	end
	return melange(7, 12, i) -- tours de corde
end

-- Course sur le tapis : `phase` en radians. Foulée de sprint : genou qui
-- monte haut devant, talon qui remonte derrière, bras pliés à angle droit
-- qui balancent à l'opposé des jambes, buste penché et léger rebond.
local function jambe(phi: number, amp: number, i: number): (number, number)
	local hanche = 0.12 + amp * math.sin(phi)
	-- Le genou se plie surtout pendant le retour de la jambe vers l'avant.
	local retour = math.max(0, math.sin(phi + 0.9)) ^ 1.5
	local genou = 0.25 + melange(1.1, 1.7, i) * retour
	return hanche, genou
end

function PosesForge.course(phase: number, intensite: number): Pose
	local i = borne(intensite)
	local amp = melange(0.6, 1.05, i)
	local hancheG, genouG = jambe(phase, amp, i)
	local hancheD, genouD = jambe(phase + math.pi, amp, i)
	local bras = amp * 0.95
	return {
		dy = melange(0.1, 0.22, i) * math.abs(math.cos(phase)),
		penche = melange(0.14, 0.34, i),
		tete = melange(0.04, 0.16, i), -- le regard reste devant malgré le buste penché
		hancheG = hancheG,
		hancheD = hancheD,
		genouG = genouG,
		genouD = genouD,
		epauleG = -bras * math.sin(phase) + 0.15,
		epauleD = bras * math.sin(phase) + 0.15,
		ecartG = 0.1,
		ecartD = 0.1,
		coudeG = 1.55 + 0.2 * math.sin(phase),
		coudeD = 1.55 - 0.2 * math.sin(phase),
	}
end

-- Hauteur de la barre (0 = au sol, 1 = bras tendus au-dessus de la tête)
-- pour une répétition avancée de `progres` (0 -> 1).
function PosesForge.hauteurBarre(progres: number): number
	return (1 - math.cos(2 * math.pi * progres)) / 2
end

-- Positions clés de l'épaulé-jeté : accroupi barre au sol, barre aux
-- épaules, barre au-dessus de la tête (tenue), puis retour.
type Cle = { t: number, pose: Pose }

local function cle(t: number, p: { number }): Cle
	return {
		t = t,
		pose = {
			dy = p[1],
			penche = p[2],
			tete = p[3],
			hancheG = p[4],
			hancheD = p[4],
			genouG = p[5],
			genouD = p[5],
			epauleG = p[6],
			epauleD = p[6],
			ecartG = p[7],
			ecartD = p[7],
			coudeG = p[8],
			coudeD = p[8],
		},
	}
end

-- { dy, penche, tete, hanche, genou, epaule, ecart, coude }
local ACCROUPI = { -1.0, 0.55, 0.3, 1.25, 1.75, 0.3, 0.12, 0.3 }
local AUX_EPAULES = { -0.15, 0.04, 0.12, 0.25, 0.45, 0.45, 0.32, 2.4 }
local AU_DESSUS = { 0.05, -0.06, 0.32, 0, 0.05, 2.95, 0.22, 0.08 }
local CLES: { Cle } = {
	cle(0, ACCROUPI),
	cle(0.08, ACCROUPI),
	cle(0.28, AUX_EPAULES),
	cle(0.42, AU_DESSUS),
	cle(0.62, AU_DESSUS),
	cle(0.78, AUX_EPAULES),
	cle(1, ACCROUPI),
}

local function adoucir(t: number): number
	return t * t * (3 - 2 * t)
end

-- Épaulé-jeté : `progres` de la répétition en cours (0 -> 1). Plus la série
-- est intense, plus on descend bas et plus le geste est franc.
function PosesForge.souleve(progres: number, intensite: number): Pose
	local i = borne(intensite)
	local p = if progres ~= progres then 0 else progres % 1
	local a, b = CLES[1], CLES[#CLES]
	for k = 1, #CLES - 1 do
		if p >= CLES[k].t and p <= CLES[k + 1].t then
			a, b = CLES[k], CLES[k + 1]
			break
		end
	end
	local u = adoucir(if b.t > a.t then (p - a.t) / (b.t - a.t) else 0)
	local profondeur = melange(0.75, 1, i)
	local pose = {} :: any
	for nom, va in a.pose :: any do
		local v = melange(va, (b.pose :: any)[nom], u)
		if nom == "dy" or nom == "genouG" or nom == "genouD" then
			v *= if v < 0 or nom ~= "dy" then profondeur else 1
		end
		pose[nom] = v
	end
	return pose :: Pose
end

-- Hauteur du saut (0 -> 1) : au sommet quand la corde passe sous les pieds
-- (phase = pi).
function PosesForge.saut(phase: number): number
	return math.max(0, -math.cos(phase)) ^ 0.7
end

-- Corde à sauter : `phase` en radians (un tour de corde = 2 pi).
function PosesForge.corde(phase: number, intensite: number): Pose
	local i = borne(intensite)
	local haut = PosesForge.saut(phase)
	return {
		dy = melange(0.9, 1.3, i) * haut,
		penche = 0.05,
		tete = 0,
		hancheG = 0.45 * haut,
		hancheD = 0.45 * haut,
		genouG = 0.9 * haut,
		genouD = 0.9 * haut,
		epauleG = 0.35 + 0.25 * math.cos(phase),
		epauleD = 0.35 + 0.25 * math.cos(phase),
		ecartG = 0.55,
		ecartD = 0.55,
		coudeG = 1.0,
		coudeD = 1.0,
	}
end

-- Pose d'un mode (nil pour un mode inconnu).
function PosesForge.pose(mode: any, phase: number, intensite: number): Pose?
	if mode == "Vitesse" then
		return PosesForge.course(phase, intensite)
	elseif mode == "Force" then
		return PosesForge.souleve(phase, intensite)
	elseif mode == "Double" then
		return PosesForge.corde(phase, intensite)
	end
	return nil
end

return PosesForge
