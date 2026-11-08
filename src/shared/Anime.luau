--!strict
-- Petites animations d'affichage (calcul pur, testable avec Lune).
-- Le client s'en sert pour faire sautiller les créatures posées et dandiner
-- les monstres. Aucune règle de jeu : le serveur reste maître des positions.
local Anime = {}

Anime.DistanceMax = 160 -- studs : au-delà, rien n'est animé (économie)

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

export type Decalage = { Hauteur: number, Lacet: number, Roulis: number }

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

return Anime
