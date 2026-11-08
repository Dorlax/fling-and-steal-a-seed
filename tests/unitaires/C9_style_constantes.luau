local Style = require("../../src/shared/Style")

-- Liste fixe des noms valides d'Enum.Font.
local POLICES_VALIDES = {
	"Legacy",
	"Arial",
	"ArialBold",
	"SourceSans",
	"SourceSansBold",
	"SourceSansSemibold",
	"SourceSansLight",
	"SourceSansItalic",
	"Bodoni",
	"Garamond",
	"Cartoon",
	"Code",
	"Highway",
	"SciFi",
	"Arcade",
	"Fantasy",
	"Antique",
	"Gotham",
	"GothamSemibold",
	"GothamBold",
	"GothamBlack",
	"AmaticSC",
	"Bangers",
	"Creepster",
	"DenkOne",
	"Fondamento",
	"FredokaOne",
	"GrenzeGotisch",
	"IndieFlower",
	"JosefinSans",
	"Jura",
	"Kalam",
	"LuckiestGuy",
	"Merriweather",
	"Michroma",
	"Nunito",
	"Oswald",
	"PatrickHand",
	"PermanentMarker",
	"Roboto",
	"RobotoCondensed",
	"RobotoMono",
	"Sarpanch",
	"SpecialElite",
	"TitilliumWeb",
	"Ubuntu",
}

local function valide(nom: any)
	return table.find(POLICES_VALIDES, nom) ~= nil
end

return {
	["C9 Police : FredokaOne, nom valide d'Enum.Font"] = function()
		assert(Style.Police == "FredokaOne", "Police doit être FredokaOne")
		assert(valide(Style.Police), "Police n'est pas un Enum.Font valide")
		assert(Style.PoliceSecondaire == "FredokaOne", "PoliceSecondaire doit être FredokaOne")
		assert(valide(Style.PoliceSecondaire), "PoliceSecondaire n'est pas un Enum.Font valide")
	end,

	["C9 Contour : toutes les épaisseurs >= 3"] = function()
		local n = 0
		for nom, v in Style.Contour do
			n += 1
			assert(type(v) == "number" and v >= 3, "contour " .. tostring(nom) .. " trop fin")
		end
		assert(n >= 3, "Gros, Moyen et Petit attendus")
		assert(Style.Contour.Gros >= Style.Contour.Moyen, "Gros >= Moyen")
		assert(Style.Contour.Moyen >= Style.Contour.Petit, "Moyen >= Petit")
	end,

	["C9 tailles minimales lisibles"] = function()
		assert(Style.TailleBoutonMin >= 90, "TailleBoutonMin >= 90")
		assert(Style.TailleTexteMin >= 18, "TailleTexteMin >= 18")
	end,

	["C9 durées d'animation positives"] = function()
		assert(Style.Flottant.Duree > 0, "Flottant.Duree > 0")
		assert(Style.Flottant.Montee > 0, "Flottant.Montee > 0")
		assert(Style.Bandeau.Duree > 0, "Bandeau.Duree > 0")
		assert(Style.Bandeau.Glisse > 0, "Bandeau.Glisse > 0")
		assert(Style.Rebond.Duree > 0, "Rebond.Duree > 0")
		assert(Style.Rebond.Echelle > 0 and Style.Rebond.Echelle < 1, "Rebond.Echelle entre 0 et 1")
		assert(Style.ArrondiBouton == 0.25, "ArrondiBouton == 0.25")
	end,
}
