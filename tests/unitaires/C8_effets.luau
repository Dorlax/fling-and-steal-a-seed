local Effets = require("../../src/shared/Effets")
local Bestiaire = require("../../src/shared/Bestiaire")
local Biomes = require("../../src/shared/Biomes")
local Anime = require("../../src/shared/Anime")

local function aPiece(nom: string, prefixe: string): boolean
	for _, b in Bestiaire.Especes[nom].Blocs do
		if string.sub(b.n, 1, #prefixe) == prefixe then
			return true
		end
	end
	return false
end

return {
	["C1 effets : chaque biome a une ambiance qui existe"] = function()
		for _, biome in Biomes.Liste do
			local famille = Effets.ParBiome[biome.Id]
			assert(famille, "pas d'ambiance pour " .. biome.Id)
			assert(Effets.Familles[famille], "famille inconnue : " .. famille)
		end
	end,

	["C2 effets signature : espèce, famille et pièce source existent"] = function()
		for nom, liste in Effets.Especes do
			assert(Bestiaire.Especes[nom], "espèce inconnue : " .. nom)
			for _, s in liste do
				assert(Effets.Familles[s.Famille], nom .. " : famille inconnue " .. s.Famille)
				if s.Source then
					assert(aPiece(nom, s.Source), nom .. " : pas de pièce " .. s.Source)
				end
			end
		end
	end,

	["C3 animations signature : chaque pièce visée existe et reçoit son rôle"] = function()
		for nom, roles in Effets.Roles do
			assert(Bestiaire.Especes[nom], "espèce inconnue : " .. nom)
			for prefixe, role in roles do
				assert(Anime.Pieces[role], "rôle inconnu : " .. role)
				assert(aPiece(nom, prefixe), nom .. " : pas de pièce " .. prefixe)
			end
		end
		for _, b in Bestiaire.Especes.Toupinette.Blocs do
			if string.sub(b.n, 1, 6) == "Ventre" then
				assert(b.a == "Toupie" and b.j, "la toupie tourne")
			end
		end
	end,

	["C4 animations continues : la toupie fait des tours complets"] = function()
		local a = Anime.piece("Toupie", 0, 0, 0, false, 0)
		local b = Anime.piece("Toupie", 0.5, 0, 0, false, 0)
		assert(a.Y == 0 and b.Y > 0, "angle qui avance")
		assert(Anime.piece("Toupie", 100, 0, 0, false, 0).Y < 2 * math.pi, "angle borné")
		local r = Anime.piece("Roue", 1, 0, 0, false, 0)
		assert(r.X > 0 and r.Y == 0, "la roue tourne autour de X")
		local p = Anime.piece("Pendule", 0.3, 0, 0, false, 0)
		assert(math.abs(p.Z) <= Anime.Pieces.Pendule.Repos + 1e-9, "pendule borné")
	end,

	["C5 grosses tailles : effets plus fréquents"] = function()
		local s = { Famille = "Pollen" }
		assert(Effets.intervalle(s, "Titan") < Effets.intervalle(s, "Normale"), "Titan plus vif")
		assert(Effets.intervalle({ Famille = "Inconnue" }, nil) == math.huge, "famille inconnue")
		assert(#Effets.de("Braisillon", "Volcan") == 2, "ambiance + signature")
	end,
}
