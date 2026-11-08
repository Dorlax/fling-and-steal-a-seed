local Style = require("../../src/shared/Style")

local VERT = { 70, 220, 90 }
local JAUNE = { 255, 220, 40 }
local ORANGE = { 255, 140, 30 }
local ROUGE = { 240, 50, 50 }

local function egal(c, attendu)
	return c[1] == attendu[1] and c[2] == attendu[2] and c[3] == attendu[3]
end

local function texte(c)
	return string.format("{%s, %s, %s}", tostring(c[1]), tostring(c[2]), tostring(c[3]))
end

return {
	["C1 couleurJauge : points exacts du dégradé"] = function()
		assert(egal(Style.couleurJauge(0), VERT), "0 doit donner Vert : " .. texte(Style.couleurJauge(0)))
		assert(egal(Style.couleurJauge(1 / 3), JAUNE), "1/3 doit donner Jaune : " .. texte(Style.couleurJauge(1 / 3)))
		assert(egal(Style.couleurJauge(2 / 3), ORANGE), "2/3 doit donner Orange : " .. texte(Style.couleurJauge(2 / 3)))
		assert(egal(Style.couleurJauge(1), ROUGE), "1 doit donner Rouge : " .. texte(Style.couleurJauge(1)))
	end,

	["C1 couleurJauge : 1/6 est strictement entre Vert et Jaune"] = function()
		local c = Style.couleurJauge(1 / 6)
		for i = 1, 3 do
			local bas, haut = math.min(VERT[i], JAUNE[i]), math.max(VERT[i], JAUNE[i])
			assert(c[i] >= bas and c[i] <= haut, "composante " .. i .. " hors de l'intervalle : " .. texte(c))
		end
		assert(not egal(c, VERT) and not egal(c, JAUNE), "1/6 ne doit être ni Vert ni Jaune : " .. texte(c))
	end,

	["C1 couleurJauge : ratio borné et valeurs invalides"] = function()
		assert(egal(Style.couleurJauge(-1), VERT), "-1 doit donner Vert")
		assert(egal(Style.couleurJauge(2), ROUGE), "2 doit donner Rouge")
		assert(egal(Style.couleurJauge(0 / 0), VERT), "NaN doit donner Vert")
		assert(egal((Style.couleurJauge :: any)("x"), VERT), '"x" doit donner Vert')
		assert(egal((Style.couleurJauge :: any)(nil), VERT), "nil doit donner Vert")
	end,

	["C1 Degrade : les 4 points du Plan"] = function()
		local d = Style.Degrade
		assert(#d == 4, "4 points attendus")
		assert(d[1][1] == 0 and d[4][1] == 1, "le dégradé doit aller de 0 à 1")
		assert(math.abs(d[2][1] - 1 / 3) < 1e-9 and math.abs(d[3][1] - 2 / 3) < 1e-9, "points à 1/3 et 2/3")
	end,
}
