local Style = require("../../src/shared/Style")

local VERT = { 70, 220, 90 }
local JAUNE = { 255, 220, 40 }
local ORANGE = { 255, 140, 30 }
local ROUGE = { 240, 50, 50 }
local VIOLET = { 110, 70, 200 }
local BLEU = { 60, 150, 255 }

local function verifie(texte, attendu)
	local c = Style.couleurBandeau(texte)
	assert(
		c[1] == attendu[1] and c[2] == attendu[2] and c[3] == attendu[3],
		"mauvaise couleur pour « " .. texte .. " »"
	)
end

return {
	["C8 couleurBandeau : messages d'alerte"] = function()
		verifie("VOLÉ !", ROUGE)
		verifie("Base pleine !", ORANGE)
		verifie("Créature déposée !", VERT)
	end,

	["C8 couleurBandeau : nuit et jour"] = function()
		verifie("La nuit tombe", VIOLET)
		verifie("Nuit noire", VIOLET)
		verifie("Le jour se lève", JAUNE)
		verifie("Jour 2", JAUNE)
	end,

	["C8 couleurBandeau : autre -> bleu"] = function()
		verifie("Personne à plaquer !", BLEU)
		verifie("Bonsoir", BLEU)
	end,
}
