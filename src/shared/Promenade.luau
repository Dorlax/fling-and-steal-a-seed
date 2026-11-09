--!strict
-- Promenade des créatures dans la base (logique pure, testable avec Lune).
-- Chaque créature erre dans un disque autour de son emplacement : elle
-- marche vers un point, s'arrête, parfois fait une petite figure (saut ou
-- pirouette), puis repart. Tout est déterministe : la position ne dépend que
-- de la graine de la créature et de l'heure du serveur, donc le serveur
-- (vérification des vols) et chaque client (affichage) la calculent sans
-- rien s'envoyer.
local Promenade = {}

Promenade.Rayon = 5 -- studs autour de l'emplacement
Promenade.Duree = 7 -- secondes par étape (marche puis pause)
Promenade.PartMarche = 0.5 -- fraction de l'étape passée à marcher
Promenade.ChanceFigure = 0.35 -- chance d'une figure pendant une pause

export type Etat = {
	X: number, -- décalage depuis l'emplacement (studs)
	Z: number,
	Cap: number, -- orientation (radians, pour CFrame.Angles(0, Cap, 0))
	Marche: boolean,
	Saut: number, -- hauteur en plus (studs), pendant un saut
	Tour: number, -- rotation en plus (radians), pendant une pirouette
}

-- Nombre pseudo-aléatoire dans [0, 1[, toujours le même pour (graine, k, canal).
local function hasard(graine: number, k: number, canal: number): number
	local x = math.sin(graine * 12.9898 + k * 78.233 + canal * 37.719) * 43758.5453
	return x - math.floor(x)
end

-- Point de l'étape k dans le disque de rayon `rayon`.
local function point(graine: number, k: number, rayon: number): (number, number)
	local angle = hasard(graine, k, 1) * math.pi * 2
	local r = math.sqrt(hasard(graine, k, 2)) * rayon
	return math.cos(angle) * r, math.sin(angle) * r
end

local function adoucir(a: number): number
	return a * a * (3 - 2 * a)
end

-- Cap pour regarder dans la direction (dx, dz) (avant du modèle = -Z).
local function cap(dx: number, dz: number): number
	return math.atan2(-dx, -dz)
end

function Promenade.etat(graine: number, t: number, rayon: number?): Etat
	local r = rayon or Promenade.Rayon
	local duree = Promenade.Duree
	local temps = t + graine * 7.31 -- désynchronise les créatures
	local k = math.floor(temps / duree)
	local u = (temps - k * duree) / duree
	local x0, z0 = point(graine, k, r)
	local x1, z1 = point(graine, k + 1, r)
	local direction = cap(x1 - x0, z1 - z0)
	local etat: Etat = { X = x1, Z = z1, Cap = direction, Marche = false, Saut = 0, Tour = 0 }
	if u < Promenade.PartMarche then
		local a = adoucir(u / Promenade.PartMarche)
		etat.X = x0 + (x1 - x0) * a
		etat.Z = z0 + (z1 - z0) * a
		etat.Marche = true
		return etat
	end
	-- Pause : une figure de temps en temps, au milieu de la pause.
	local tirage = hasard(graine, k, 3)
	if tirage < Promenade.ChanceFigure then
		local p = (u - Promenade.PartMarche) / (1 - Promenade.PartMarche)
		local debut, fin = 0.3, 0.7
		if p > debut and p < fin then
			local q = (p - debut) / (fin - debut)
			if tirage < Promenade.ChanceFigure / 2 then
				etat.Saut = math.sin(q * math.pi) * 1.6
			else
				etat.Tour = q * math.pi * 2
				etat.Saut = math.sin(q * math.pi) * 0.5
			end
		end
	end
	return etat
end

return Promenade
