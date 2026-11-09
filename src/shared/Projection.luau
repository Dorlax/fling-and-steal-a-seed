--!strict
-- Styles comiques de projection quand un monstre frappe (logique pure,
-- testable avec Lune). Le serveur tire un style à chaque coup ; la force de
-- base vient de Monstre.recul (zone et biome).
--   MultH / MultV : multiplicateurs de la poussée horizontale / verticale
--   Tourne        : vitesse de rotation (radians/s) pendant l'étourdissement
--   Ballon        : secondes de flottement accroché à des ballons
local Projection = {}

export type Style = {
	Id: string,
	Mots: { string }, -- onomatopée affichée au-dessus du joueur (une au hasard)
	Message: string, -- bandeau du joueur projeté
	Couleur: { number },
	MultH: number,
	MultV: number,
	Tourne: number?,
	Ballon: number?,
}

Projection.Liste = {
	{
		Id = "Boing",
		Mots = { "BOING !", "BAM !", "PAF !" },
		Message = "BOING ! Un monstre t'a propulsé !",
		Couleur = { 255, 220, 40 },
		MultH = 1,
		MultV = 1,
	},
	{
		Id = "Toupie",
		Mots = { "WHIIIZ !", "TOUPIE !", "VRRRR !" },
		Message = "Tu tournes comme une toupie !",
		Couleur = { 120, 230, 255 },
		MultH = 0.8,
		MultV = 1.2,
		Tourne = 25,
	},
	{
		Id = "Fusee",
		Mots = { "FIUUUU !", "DÉCOLLAGE !", "ZOOOM !" },
		Message = "Décollage immédiat ! Bon vol !",
		Couleur = { 255, 120, 60 },
		MultH = 0.3,
		MultV = 2.4,
	},
	{
		Id = "Ballon",
		Mots = { "POUET !", "BYE BYE !", "HOP LÀ !" },
		Message = "Accroche-toi aux ballons… POP !",
		Couleur = { 255, 130, 200 },
		MultH = 0.25,
		MultV = 0.6,
		Ballon = 1.6,
	},
} :: { Style }

-- Style tiré avec `tirage` dans [0, 1[ (tous équiprobables).
function Projection.tirer(tirage: number): Style
	local t = if type(tirage) == "number" and tirage == tirage then tirage else 0
	local rang = math.clamp(math.floor(t * #Projection.Liste) + 1, 1, #Projection.Liste)
	return Projection.Liste[rang]
end

-- Style par identifiant, ou nil.
function Projection.style(id: any): Style?
	for _, s in Projection.Liste do
		if s.Id == id then
			return s
		end
	end
	return nil
end

-- Poussée finale (studs/s) d'un style à partir de la poussée de base.
function Projection.poussee(style: Style, horizontal: number, vertical: number): (number, number)
	return horizontal * style.MultH, vertical * style.MultV
end

-- Durée d'étourdissement : celle de la zone, allongée par le vol en ballon.
function Projection.duree(style: Style, base: number): number
	return math.max(base, (style.Ballon or 0) + 0.6)
end

-- Onomatopée tirée avec `tirage` dans [0, 1[.
function Projection.mot(style: Style, tirage: number): string
	local t = if type(tirage) == "number" and tirage == tirage then tirage else 0
	return style.Mots[math.clamp(math.floor(t * #style.Mots) + 1, 1, #style.Mots)]
end

return Projection
