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
		return melange(0.6, 1.3, i) -- répétitions par seconde
	end
	return melange(7, 12, i) -- tours de corde
end

-- Course sur le tapis : `phase` en radians.
function PosesForge.course(phase: number, intensite: number): Pose
	local i = borne(intensite)
	local s = math.sin(phase)
	local amp = melange(0.55, 0.95, i)
	return {
		dy = 0.12 * math.abs(math.cos(phase)) * (1 + i),
		penche = melange(0.08, 0.3, i),
		tete = -0.05,
		hancheG = amp * s,
		hancheD = -amp * s,
		genouG = 0.3 + melange(0.7, 1.2, i) * math.max(0, -s),
		genouD = 0.3 + melange(0.7, 1.2, i) * math.max(0, s),
		epauleG = -amp * 0.9 * s,
		epauleD = amp * 0.9 * s,
		ecartG = 0.12,
		ecartD = 0.12,
		coudeG = 1.4,
		coudeD = 1.4,
	}
end

-- Hauteur de la barre (0 = contre la poitrine, 1 = bras tendus) pour une
-- répétition avancée de `progres` (0 -> 1).
function PosesForge.hauteurBarre(progres: number): number
	return (1 - math.cos(2 * math.pi * progres)) / 2
end

-- Développé debout : `progres` de la répétition en cours (0 -> 1).
function PosesForge.souleve(progres: number, intensite: number): Pose
	local i = borne(intensite)
	local h = PosesForge.hauteurBarre(progres)
	local flexion = (1 - h) * melange(0.6, 1, i) -- on plie les jambes en bas
	return {
		dy = -0.35 * flexion,
		penche = 0,
		tete = 0.25 * h,
		hancheG = 0.4 * flexion,
		hancheD = 0.4 * flexion,
		genouG = 0.8 * flexion,
		genouD = 0.8 * flexion,
		epauleG = melange(0.55, 2.95, h),
		epauleD = melange(0.55, 2.95, h),
		ecartG = melange(0.35, 0.28, h),
		ecartD = melange(0.35, 0.28, h),
		coudeG = melange(2.3, 0.15, h),
		coudeD = melange(2.3, 0.15, h),
	}
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
