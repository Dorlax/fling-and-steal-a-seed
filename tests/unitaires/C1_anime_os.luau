local AnimeOs = require("../../src/shared/AnimeOs")

local PATTES = { "AvG", "AvD", "ArG", "ArD" }

return {
	["C1 chaque clip donne une pose finie et bornée"] = function()
		for _, clip in AnimeOs.Clips do
			for i = 0, 60 do
				local pose = AnimeOs.pose(clip, i * 0.05)
				for nom, o in pose do
					for _, v in { o.X, o.Y, o.Z, o.PX, o.PY, o.PZ } do
						assert(v == v, clip .. " " .. nom .. " : NaN")
						assert(math.abs(v) <= math.rad(60), clip .. " " .. nom .. " : trop grand")
					end
				end
			end
		end
	end,

	["C1 les clips bouclent sans saut"] = function()
		for _, clip in AnimeOs.Clips do
			local d = AnimeOs.Durees[clip]
			local a, b = AnimeOs.pose(clip, 0), AnimeOs.pose(clip, d)
			for nom, o in a do
				local p = b[nom]
				assert(math.abs(o.X - p.X) < 1e-6 and math.abs(o.Z - p.Z) < 1e-6, clip .. " " .. nom)
			end
		end
	end,

	["C1 à la marche, la patte est levée seulement quand elle revient vers l'avant"] = function()
		-- Cuisse : l'angle augmente quand la patte part vers l'arrière (appui au sol).
		local n = 48
		for _, k in PATTES do
			for i = 0, n - 1 do
				local t = i / n
				local p1 = AnimeOs.pose("Marche", t)
				local p2 = AnimeOs.pose("Marche", t + 1 / n)
				local versArriere = p2["Cuisse" .. k].X > p1["Cuisse" .. k].X + 1e-6
				local leve = p1["Jambe" .. k].X < -math.rad(5)
				assert(not (versArriere and leve), "patte " .. k .. " levée pendant l'appui")
			end
		end
	end,

	["C1 le choix du clip suit la vitesse et l'état"] = function()
		assert(AnimeOs.choisir(nil, 0) == "Idle")
		assert(AnimeOs.choisir(nil, AnimeOs.Pas.Marche) == "Marche")
		assert(AnimeOs.choisir(nil, AnimeOs.Pas.Course * 2) == "Course")
		assert(AnimeOs.choisir("Porte", 50) == "Porte")
		assert(AnimeOs.choisir("Inconnu", 0) == "Idle")
		local _, cadence = AnimeOs.choisir(nil, AnimeOs.Pas.Marche)
		assert(math.abs(cadence - 1) < 1e-9, "à la vitesse du pas, cadence normale")
	end,
}
