--!strict
-- Animations par os des créatures 3D importées de Blender (calcul pur,
-- testable avec Lune). Même squelette pour tous les quadrupèdes :
--   Racine, Bassin, Torse, Cou, Tete, Queue1..4,
--   CuisseAvG/JambeAvG, CuisseAvD/JambeAvD, CuisseArG/JambeArG, CuisseArD/JambeArD.
-- Les formules sont celles des actions Blender (dragon_cristal_rig.fbx) :
-- l'animation tourne pareil dans Blender et dans le jeu.
-- Angles en radians, dans le repère local de chaque os (convention Blender).
local AnimeOs = {}

-- Durée d'un cycle (s) : 24 images/s dans Blender.
AnimeOs.Durees = {
	Idle = 2,
	Marche = 1,
	Course = 16 / 24,
	Joie = 32 / 24,
	Etourdi = 2,
	Porte = 1,
} :: { [string]: number }

-- Vitesse d'avance qui colle aux pas (unités du modèle par seconde, échelle 1) :
-- mesurée dans Blender sur la patte avant gauche, pied au sol.
AnimeOs.Pas = {
	Marche = 0.057 * 24,
	Course = 0.131 * 24,
}

-- Au-delà de ce rapport (vitesse / pas de marche), la créature galope.
AnimeOs.SeuilCourse = 1.6

export type Os = { X: number, Y: number, Z: number, PX: number, PY: number, PZ: number }
export type Pose = { [string]: Os }

local PATTES = { "AvG", "AvD", "ArG", "ArD" }

local function rad(d: number): number
	return math.rad(d)
end

-- sin(2π(k·t + ph))
local function S(t: number, k: number?, ph: number?): number
	return math.sin(2 * math.pi * ((k or 1) * t + (ph or 0)))
end

local function osDe(pose: Pose, nom: string): Os
	local o = pose[nom]
	if not o then
		o = { X = 0, Y = 0, Z = 0, PX = 0, PY = 0, PZ = 0 }
		pose[nom] = o
	end
	return o
end

local function rot(pose: Pose, nom: string, x: number, y: number, z: number)
	local o = osDe(pose, nom)
	o.X, o.Y, o.Z = rad(x), rad(y), rad(z)
end

local function pos(pose: Pose, nom: string, x: number, y: number, z: number)
	local o = osDe(pose, nom)
	o.PX, o.PY, o.PZ = x, y, z
end

local CLIPS: { [string]: (pose: Pose, t: number) -> () } = {}

CLIPS.Idle = function(p, t)
	pos(p, "Bassin", 0, 0.015 * S(t), 0) -- respiration
	rot(p, "Torse", 2 * S(t), 0, 0)
	rot(p, "Cou", 3 * S(t, 1, 0.1), 0, 4 * S(t, 1, 0.25))
	rot(p, "Tete", 4 * S(t, 2, 0.2), 0, 12 * S(t, 1, 0.3))
	for i = 1, 4 do
		rot(p, "Queue" .. i, 4 * S(t, 1, 0.15 * i), 0, 9 * S(t, 1, 0.12 * i))
	end
end

-- Pattes en diagonale ; la patte se lève quand elle revient vers l'avant.
CLIPS.Marche = function(p, t)
	pos(p, "Bassin", 0, 0.03 * S(t, 2), 0)
	rot(p, "Bassin", 0, 3 * S(t), 0)
	rot(p, "Torse", 0, -3 * S(t), 0)
	rot(p, "Tete", 5 * S(t, 2, 0.25), 0, 4 * S(t))
	local phases: { [string]: number } = { AvG = 0, ArD = 0, AvD = 0.5, ArG = 0.5 }
	for _, k in PATTES do
		local ph = phases[k]
		rot(p, "Cuisse" .. k, 28 * S(t, 1, ph), 0, 0)
		rot(p, "Jambe" .. k, -30 * math.max(0, S(t, 1, ph + 0.75)), 0, 0)
	end
	for i = 1, 4 do
		rot(p, "Queue" .. i, 3 * S(t, 2, 0.1 * i), 0, 14 * S(t, 1, 0.12 * i))
	end
end

-- Galop : pattes avant ensemble, puis pattes arrière.
CLIPS.Course = function(p, t)
	pos(p, "Bassin", 0, 0, 0.06 * math.abs(S(t)))
	rot(p, "Bassin", 6 * S(t, 1, 0.25), 0, 0)
	rot(p, "Tete", -8 + 6 * S(t, 2), 0, 0)
	local phases: { [string]: number } = { AvG = 0, AvD = 0.1, ArG = 0.5, ArD = 0.6 }
	for _, k in PATTES do
		local ph = phases[k]
		rot(p, "Cuisse" .. k, 45 * S(t, 1, ph), 0, 0)
		rot(p, "Jambe" .. k, -40 * math.max(0, S(t, 1, ph + 0.75)), 0, 0)
	end
	for i = 1, 4 do
		rot(p, "Queue" .. i, -6 + 8 * S(t, 1, 0.1 * i), 0, 6 * S(t, 2, 0.1 * i))
	end
end

-- Petits bonds, queue qui frétille.
CLIPS.Joie = function(p, t)
	local h = math.max(0, S(t, 2))
	pos(p, "Racine", 0, 0, 0.32 * h)
	rot(p, "Tete", -15 * h, 0, 10 * S(t, 4))
	for _, k in { "AvG", "AvD" } do
		rot(p, "Cuisse" .. k, 25 * h, 0, 0)
		rot(p, "Jambe" .. k, -30 * h, 0, 0)
	end
	for _, k in { "ArG", "ArD" } do
		rot(p, "Cuisse" .. k, -20 * h, 0, 0)
	end
	for i = 1, 4 do
		rot(p, "Queue" .. i, -10, 0, 22 * S(t, 6, 0.08 * i))
	end
end

-- Étourdi par un monstre : la tête tourne en rond, le corps tangue.
CLIPS.Etourdi = function(p, t)
	rot(p, "Bassin", 0, 7 * S(t), 0)
	rot(p, "Cou", 10 * S(t, 2), 0, 10 * S(t, 2, 0.25))
	rot(p, "Tete", 14 * S(t, 2), 10 * S(t), 18 * S(t, 2, 0.25))
	for _, k in PATTES do
		rot(p, "Cuisse" .. k, 0, 6 * S(t, 1, 0.3), 0)
	end
	for i = 1, 4 do
		rot(p, "Queue" .. i, 12, 0, 5 * S(t, 1, 0.1 * i))
	end
end

-- Portée ou volée : les pattes pédalent dans le vide.
CLIPS.Porte = function(p, t)
	local phases: { [string]: number } = { AvG = 0, AvD = 0.5, ArG = 0.25, ArD = 0.75 }
	for _, k in PATTES do
		local ph = phases[k]
		rot(p, "Cuisse" .. k, 40 * S(t, 3, ph), 0, 0)
		rot(p, "Jambe" .. k, -40 * math.max(0, S(t, 3, ph + 0.25)), 0, 0)
	end
	rot(p, "Tete", -10, 0, 20 * S(t, 2))
	for i = 1, 4 do
		rot(p, "Queue" .. i, 0, 0, 25 * S(t, 5, 0.1 * i))
	end
end

AnimeOs.Clips = { "Idle", "Marche", "Course", "Joie", "Etourdi", "Porte" }

-- Pose d'un clip au temps `temps` (secondes, boucle). Les os absents de la
-- table restent au repos.
function AnimeOs.pose(clip: string, temps: number): Pose
	local f = CLIPS[clip] or CLIPS.Idle
	local duree = AnimeOs.Durees[clip] or AnimeOs.Durees.Idle
	local pose: Pose = {}
	f(pose, (temps / duree) % 1)
	return pose
end

-- Choix du clip d'après l'état et la vitesse d'avance (unités du modèle / s,
-- déjà divisée par l'échelle du modèle). Renvoie aussi la cadence à appliquer
-- au temps pour que les pieds ne glissent pas.
function AnimeOs.choisir(etat: string?, vitesse: number): (string, number)
	if etat and CLIPS[etat] then
		return etat, 1
	end
	if vitesse < 0.15 then
		return "Idle", 1
	end
	local rapport = vitesse / AnimeOs.Pas.Marche
	if rapport >= AnimeOs.SeuilCourse then
		return "Course", vitesse / AnimeOs.Pas.Course
	end
	return "Marche", rapport
end

return AnimeOs
