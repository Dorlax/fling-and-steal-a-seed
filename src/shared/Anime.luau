--!strict
-- Petites animations d'affichage (calcul pur, testable avec Lune).
-- Le client s'en sert pour faire vivre les créatures et les monstres en blocs :
-- tout le modèle sautille ou se dandine, et chaque pièce animée (patte, bras,
-- aile, queue, oreille, tête, mâchoire) tourne autour de son articulation.
-- Aucune règle de jeu : le serveur reste maître des positions.
local Anime = {}

Anime.DistanceMax = 160 -- studs : au-delà, rien n'est animé (économie)
Anime.DureeMarche = 0.35 -- s : un monstre déplacé depuis moins longtemps « marche »
Anime.DureeFrappe = 0.45 -- s : durée de l'animation de coup

Anime.Creature = {
	Frequence = 2.2, -- radians par seconde
	Saut = 0.35, -- studs, hauteur max du sautillement
	Lacet = 0.25, -- radians, la créature regarde un peu autour d'elle
	Roulis = 0.08, -- radians, léger dandinement
}

Anime.Monstre = {
	Frequence = 6,
	Roulis = 0.12,
}

-- Amplitudes (radians) et vitesses des pièces animées.
Anime.Pieces = {
	Patte = { Repos = 0.05, Marche = 0.7, Vitesse = 10 },
	Bras = { Repos = 0.08, Marche = 0.6, Vitesse = 10, Frappe = 1.8 },
	Aile = { Repos = 0.35, Marche = 0.6, Vitesse = 9 },
	Queue = { Repos = 0.35, Marche = 0.5, Vitesse = 5 },
	Oreille = { Repos = 0.15, Marche = 0.25, Vitesse = 3 },
	Tete = { Repos = 0.08, Marche = 0.12, Vitesse = 2.5, Frappe = 0.5 },
	Antenne = { Repos = 0.25, Marche = 0.35, Vitesse = 4 },
	Machoire = { Repos = 0.08, Marche = 0.15, Vitesse = 4, Frappe = 0.7 },
	-- Animations signature (Shared.Effets.Roles) : rotations continues…
	Toupie = { Repos = 0, Marche = 0, Vitesse = 5 }, -- autour de Y
	Helice = { Repos = 0, Marche = 0, Vitesse = 14 }, -- autour de Y, très vite
	Roue = { Repos = 0, Marche = 0, Vitesse = 4 }, -- autour de X
	Moulin = { Repos = 0, Marche = 0, Vitesse = 1.5 }, -- autour de Z (face avant)
	-- … et oscillations.
	Pendule = { Repos = 0.45, Marche = 0.45, Vitesse = 2.6 }, -- autour de Z
	Bascule = { Repos = 0.22, Marche = 0.3, Vitesse = 2.2 }, -- autour de X
	Flamme = { Repos = 0.14, Marche = 0.14, Vitesse = 13 }, -- frémissement
}

-- Rôles qui tournent sans fin (angle = temps × vitesse).
local CONTINUS = { Toupie = "Y", Helice = "Y", Roue = "X", Moulin = "Z" }

export type Decalage = { Hauteur: number, Lacet: number, Roulis: number }
export type Rotation = { X: number, Y: number, Z: number }

-- Décalage d'une créature à l'instant `t` (secondes) ; `phase` désynchronise
-- les créatures entre elles.
function Anime.creature(t: number, phase: number): Decalage
	local r = Anime.Creature
	local x = t * r.Frequence + phase
	return {
		Hauteur = math.abs(math.sin(x)) * r.Saut,
		Lacet = math.sin(x * 0.5) * r.Lacet,
		Roulis = math.sin(x) * r.Roulis,
	}
end

-- Décalage d'un monstre : il se dandine d'un pied sur l'autre.
function Anime.monstre(t: number, phase: number): Decalage
	local r = Anime.Monstre
	return {
		Hauteur = 0,
		Lacet = 0,
		Roulis = math.sin(t * r.Frequence + phase) * r.Roulis,
	}
end

-- Rotation d'une pièce animée autour de son articulation.
--   role   : Patte, Bras, Aile, Queue, Oreille, Tete, Antenne, Machoire,
--            Toupie, Helice, Roue, Moulin, Pendule, Bascule ou Flamme
--   t      : temps (s) ; phase : décalage de la pièce + du modèle
--   cote   : -1 gauche, 1 droite, 0 au centre
--   marche : vrai si le modèle se déplace
--   frappe : 0 (pas de coup) à 1 (début du coup)
function Anime.piece(
	role: string,
	t: number,
	phase: number,
	cote: number,
	marche: boolean,
	frappe: number
): Rotation
	local r = (Anime.Pieces :: any)[role]
	if r == nil then
		return { X = 0, Y = 0, Z = 0 }
	end
	local axe = (CONTINUS :: any)[role]
	if axe then
		local angle = (t * r.Vitesse + phase) % (2 * math.pi)
		return {
			X = if axe == "X" then angle else 0,
			Y = if axe == "Y" then angle else 0,
			Z = if axe == "Z" then -angle else 0,
		}
	end
	local amplitude = if marche then r.Marche else r.Repos
	local onde = math.sin(t * r.Vitesse + phase)
	local coup = if r.Frappe then r.Frappe * math.sin(math.clamp(frappe, 0, 1) * math.pi) else 0
	if role == "Patte" then
		return { X = onde * amplitude, Y = 0, Z = 0 }
	elseif role == "Bras" then
		return { X = onde * amplitude + coup, Y = 0, Z = 0 }
	elseif role == "Aile" then
		-- Les deux ailes battent ensemble, vers le haut puis vers le bas.
		return { X = 0, Y = 0, Z = cote * (onde * 0.5 + 0.5) * amplitude }
	elseif role == "Queue" then
		return { X = 0, Y = onde * amplitude, Z = 0 }
	elseif role == "Oreille" then
		return { X = 0, Y = 0, Z = -cote * math.max(onde, 0) * amplitude }
	elseif role == "Tete" then
		return {
			X = onde * amplitude - coup,
			Y = math.sin(t * r.Vitesse * 0.5 + phase) * amplitude,
			Z = 0,
		}
	elseif role == "Pendule" then
		return { X = 0, Y = 0, Z = onde * amplitude }
	elseif role == "Bascule" then
		return { X = onde * amplitude, Y = 0, Z = 0 }
	elseif role == "Flamme" then
		return { X = onde * amplitude, Y = 0, Z = math.cos(t * r.Vitesse * 0.8 + phase) * amplitude }
	elseif role == "Machoire" then
		-- Négatif : l'avant de la mâchoire descend (la bouche s'ouvre).
		return { X = -((onde * 0.5 + 0.5) * amplitude + coup), Y = 0, Z = 0 }
	end
	-- Antenne : balancement latéral.
	return { X = 0, Y = 0, Z = onde * amplitude }
end

return Anime
