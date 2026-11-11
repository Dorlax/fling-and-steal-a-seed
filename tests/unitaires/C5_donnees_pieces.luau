local Config = require("../../src/shared/Config")
local Donnees = require("../../src/shared/Donnees")

local plafond = Config.Creatures.PiecesMax
local maxBase = Config.Creatures.MaxCreaturesBase

return {
	["C5 parDefaut contient Pieces = 0 et CreaturesBase = {}"] = function()
		local d = Donnees.parDefaut()
		assert(d.Pieces == 0, "Pieces doit valoir 0")
		assert(
			type(d.CreaturesBase) == "table" and #d.CreaturesBase == 0,
			"CreaturesBase doit être vide"
		)
	end,

	["C5 parDefaut renvoie des listes CreaturesBase distinctes"] = function()
		local a, b = Donnees.parDefaut(), Donnees.parDefaut()
		table.insert(a.CreaturesBase, "Rare")
		assert(#b.CreaturesBase == 0, "b ne doit pas être affectée")
	end,

	["C6 pièces négatives, NaN, infinies ou texte deviennent 0"] = function()
		for _, v in { -5, 0 / 0, math.huge, -math.huge, "abc" } do
			local d = Donnees.nettoyer({ Pieces = v })
			assert(d.Pieces == 0, "0 attendu pour " .. tostring(v))
		end
	end,

	["C6 pièces décimales arrondies vers le bas"] = function()
		assert(Donnees.nettoyer({ Pieces = 12.9 }).Pieces == 12)
	end,

	["C6 pièces plafonnées à PiecesMax"] = function()
		assert(Donnees.nettoyer({ Pieces = plafond * 10 }).Pieces == plafond)
	end,

	["C6 CreaturesBase non-table devient {}"] = function()
		for _, v in { "Rare", 5, true } do
			local d = Donnees.nettoyer({ CreaturesBase = v })
			assert(type(d.CreaturesBase) == "table" and #d.CreaturesBase == 0)
		end
	end,

	["C6 raretés invalides retirées de CreaturesBase"] = function()
		local d = Donnees.nettoyer({ CreaturesBase = { "Commune", "Triche", 5, "Mythique" } })
		assert(#d.CreaturesBase == 2, "2 entrées attendues, obtenu " .. #d.CreaturesBase)
		assert(d.CreaturesBase[1] == "Commune" and d.CreaturesBase[2] == "Mythique")
	end,

	["C6 CreaturesBase tronquée à la capacité de la plus grande base"] = function()
		local maxTotal = Config.Bases.Capacites[#Config.Bases.Capacites]
		assert(maxTotal >= maxBase, "la plus grande base a au moins les places du niveau 1")
		local liste = {}
		for _ = 1, maxTotal + 5 do
			table.insert(liste, "Commune")
		end
		assert(#Donnees.nettoyer({ CreaturesBase = liste }).CreaturesBase == maxTotal)
	end,

	["C6 agrandissement : 1 par défaut, borné, anciens étages convertis"] = function()
		local n = #Config.Bases.Tailles
		assert(Donnees.nettoyer({}).Agrandissement == 1, "niveau 1 par défaut")
		assert(Donnees.nettoyer({ Agrandissement = 99 }).Agrandissement == n, "borné")
		assert(Donnees.nettoyer({ Agrandissement = "x" }).Agrandissement == 1, "invalide -> 1")
		assert(Donnees.nettoyer({ Etages = 3 }).Agrandissement == 3, "3 étages -> niveau 3")
		assert(
			Donnees.nettoyer({ Etages = 2, Agrandissement = 3 }).Agrandissement == 3,
			"on garde le plus grand"
		)
		assert(Donnees.nettoyer({ Etages = 0 / 0 }).Agrandissement == 1, "NaN ignoré")
		assert((Donnees.nettoyer({ Etages = 3 }) :: any).Etages == nil, "plus de champ Etages")
	end,

	["C6 anciennes données sans ces champs restent valides"] = function()
		local d =
			Donnees.nettoyer({ Force = 12, Vitesse = 34, ModeForge = "Vitesse", NiveauForge = 1 })
		assert(d.Force == 12 and d.Vitesse == 34, "Force et Vitesse conservées")
		assert(d.Pieces == 0 and #d.CreaturesBase == 0, "nouveaux champs par défaut")
	end,
}
