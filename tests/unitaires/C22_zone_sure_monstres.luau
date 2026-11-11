-- Zone sûre, monstres qui n'attaquent qu'après le ramassage, tailles des
-- monstres et capacité de la base sur un seul niveau.
local Config = require("../../src/shared/Config")
local Monstre = require("../../src/shared/Monstre")
local Plaquage = require("../../src/shared/Plaquage")
local ZoneSure = require("../../src/shared/ZoneSure")
local Donnees = require("../../src/shared/Donnees")

local M = Config.Monstres

local function contexteMonstre(modif: { [string]: any }?): any
	local c: { [string]: any } = {
		zone = "Proche",
		cibleVivante = true,
		cibleDansSaBase = false,
		distance = 3,
		maintenant = 100,
		cibleEnZoneSure = false,
		ciblePorte = true,
	}
	for k, v in modif or {} do
		c[k] = v
	end
	return c
end

local function contextePlaquage(modif: { [string]: any }?): any
	local c: { [string]: any } = {
		memeJoueur = false,
		plaqueurVivant = true,
		plaqueurAuSol = false,
		plaqueurDansSaBase = false,
		cibleVivante = true,
		ciblePorte = true,
		cibleDansSaBase = false,
		distance = 3,
		maintenant = 100,
		cibleEnZoneSure = false,
	}
	for k, v in modif or {} do
		c[k] = v
	end
	return c
end

return {
	["C1 la ligne de la zone sûre repousse le premier biome"] = function()
		local zs = Config.ZoneSure
		assert(zs.Profondeur > 0, "profondeur positive")
		assert(M.BordBases == zs.BordBases + zs.Profondeur, "ligne = bord des bases + profondeur")
		assert(ZoneSure.Ligne == M.BordBases, "ZoneSure.Ligne = début des Terres Sauvages")
	end,

	["C1 ZoneSure.contient : avant la ligne oui, après non, invalide non"] = function()
		assert(ZoneSure.contient({ Z = M.BordBases - 0.1 }) == true, "juste avant la ligne")
		assert(ZoneSure.contient({ Z = -50 }) == true, "dans les bases")
		assert(ZoneSure.contient({ Z = M.BordBases }) == false, "sur la ligne : Terres Sauvages")
		assert(ZoneSure.contient({ Z = M.BordBases + 200 }) == false, "loin")
		assert(ZoneSure.contient({ Z = 0 / 0 }) == false, "NaN")
		assert(ZoneSure.contient(nil) == false, "nil")
		assert(ZoneSure.contient({ Z = "x" }) == false, "texte")
	end,

	["C2 monstres : aucun coup dans la zone sûre"] = function()
		local ok, raison = Monstre.peutFrapper(contexteMonstre({ cibleEnZoneSure = true }))
		assert(ok == false and raison == "zonesure", "refus zonesure attendu : " .. tostring(raison))
	end,

	["C2 monstres : aucun coup sans créature portée"] = function()
		local ok, raison = Monstre.peutFrapper(contexteMonstre({ ciblePorte = false }))
		assert(ok == false and raison == "sansgraine", "refus sansgraine : " .. tostring(raison))
		assert(Monstre.peutFrapper(contexteMonstre()) == true, "porteur hors zone sûre : coup permis")
	end,

	["C2 la base passe avant la zone sûre (raison base)"] = function()
		local _, raison = Monstre.peutFrapper(
			contexteMonstre({ cibleDansSaBase = true, cibleEnZoneSure = true, ciblePorte = false })
		)
		assert(raison == "base", "raison base attendue : " .. tostring(raison))
	end,

	["C3 plaquage refusé sur une cible en zone sûre"] = function()
		local ok, raison = Plaquage.verifier(contextePlaquage({ cibleEnZoneSure = true }))
		assert(ok == false and raison == "zonesure", "refus zonesure : " .. tostring(raison))
		assert(Plaquage.verifier(contextePlaquage()) == true, "hors zone sûre : permis")
	end,

	["C4 tailles des monstres : tirage valide, toutes les tailles possibles"] = function()
		local t = M.Tailles
		local vues = {}
		for i = 0, 999 do
			local nom, echelle = Monstre.tirerTaille(i / 1000)
			assert(t.Echelle[nom] == echelle, "échelle cohérente pour " .. tostring(nom))
			vues[nom] = true
		end
		for _, nom in t.Ordre do
			assert(vues[nom], "taille jamais tirée : " .. nom)
		end
		local nom = Monstre.tirerTaille(0 / 0)
		assert(t.Echelle[nom] ~= nil, "NaN -> taille valide")
		assert(t.Echelle.Petit < t.Echelle.Normal and t.Echelle.Normal < t.Echelle.Geant, "ordre")
	end,

	["C4 un grand monstre frappe de plus loin et projette plus fort"] = function()
		local portee = Monstre.porteeCoup("Proche", 1)
		assert(portee == M.Zones.Proche.PorteeCoup, "échelle 1 = portée de Config")
		assert(Monstre.porteeCoup("Proche", 2) > portee, "plus grand -> plus loin")
		assert(Monstre.porteeCoup("Proche", 0 / 0) == portee, "NaN -> échelle 1")
		local loin = M.Zones.Proche.PorteeCoup * 1.8
		assert(
			Monstre.peutFrapper(contexteMonstre({ distance = loin, echelle = 1 })) == false,
			"petit monstre hors de portée"
		)
		assert(
			Monstre.peutFrapper(contexteMonstre({ distance = loin, echelle = 2 })) == true,
			"grand monstre à portée"
		)
		local h1, v1 = Monstre.recul("Proche", 1, 1)
		local h2, v2 = Monstre.recul("Proche", 1, 2)
		assert(h2 > h1 and v2 > v1, "projection plus forte")
		local hMax = Monstre.recul("Lointaine", 50, 5)
		assert(hMax <= M.ReculMax, "plafond respecté")
	end,

	["C5 moins de monstres : au plus 9 par biome la nuit"] = function()
		local total = 0
		for _, zone in M.Zones do
			total += zone.NombreNuit
		end
		assert(total <= 9, "trop de monstres la nuit : " .. total)
		assert(M.IntervalleControle <= 1, "contrôle des biomes au moins chaque seconde")
	end,

	["C6 base sur un seul niveau : places croissantes par agrandissement"] = function()
		local b = Config.Bases
		assert(b.EtagesMax == nil and b.PrixEtages == nil, "plus d'étages dans Config")
		assert(#b.Capacites == #b.Tailles and #b.EchelleMax == #b.Tailles, "une valeur par niveau")
		assert(#b.PrixAgrandissement == #b.Tailles - 1, "un prix par niveau après le 1er")
		assert(b.Capacites[1] == Config.Creatures.MaxCreaturesBase, "niveau 1 = 10 places")
		for i = 2, #b.Tailles do
			assert(b.Tailles[i] > b.Tailles[i - 1], "sol croissant")
			assert(b.Capacites[i] > b.Capacites[i - 1], "places croissantes")
		end
		assert(b.Tailles[#b.Tailles] < b.Ecart, "la plus grande base tient entre ses voisines")
		assert(Donnees.capacite(1) == b.Capacites[1], "capacite(1)")
		assert(Donnees.capacite(99) == b.Capacites[#b.Capacites], "borné en haut")
		assert(Donnees.capacite(nil) == b.Capacites[1], "nil -> niveau 1")
	end,
}
