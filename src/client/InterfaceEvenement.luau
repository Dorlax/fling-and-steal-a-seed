--!strict
-- Pastille de l'événement en cours (en haut à gauche) : nom, effet et temps
-- restant. Affichage seulement : tout vient des attributs de Workspace
-- (Evenement, EvenementFin), écrits par le serveur.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Style = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Style"))
local Evenement = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Evenement"))
local Habillage = require(script.Parent:WaitForChild("Habillage"))

local InterfaceEvenement = {}

function InterfaceEvenement.demarrer()
	local ecran = Instance.new("ScreenGui")
	ecran.Name = "InterfaceEvenement"
	ecran.ResetOnSpawn = false
	ecran.DisplayOrder = 4

	local cadre = Instance.new("Frame")
	cadre.Name = "Evenement"
	-- Sous le compteur de pièces, au centre (ne chevauche plus les stats).
	cadre.AnchorPoint = Vector2.new(0.5, 0)
	cadre.Position = UDim2.new(0.5, 0, 0, 100)
	cadre.Size = UDim2.fromOffset(250, 64)
	cadre.Visible = false
	cadre.Parent = ecran
	Habillage.arrondi(cadre, 0.25)
	Habillage.contour(cadre, Style.Contour.Moyen, Enum.ApplyStrokeMode.Border)

	local nom = Habillage.texte(cadre, "Nom", { contour = Style.Contour.Moyen })
	nom.TextXAlignment = Enum.TextXAlignment.Center
	nom.Position = UDim2.fromOffset(10, 4)
	nom.Size = UDim2.new(1, -20, 0, 30)

	local effet = Habillage.texte(cadre, "Effet", { contour = Style.Contour.Petit })
	effet.Position = UDim2.fromOffset(10, 34)
	effet.Size = UDim2.new(1, -20, 0, Style.TailleTexteMin + 4)
	effet.TextXAlignment = Enum.TextXAlignment.Center

	local actuel = ""
	local function maj()
		local id = Workspace:GetAttribute("Evenement")
		local trouve = Evenement.infos(id)
		if trouve == nil then
			cadre.Visible = false
			actuel = ""
			return
		end
		local infos = trouve :: Evenement.Infos
		local restant =
			Evenement.restant(Workspace:GetAttribute("EvenementFin"), Workspace:GetServerTimeNow())
		cadre.BackgroundColor3 = Habillage.couleur(infos.Couleur)
		nom.Text = `{infos.Nom} · {Evenement.texteDuree(restant)}`
		effet.Text = infos.Texte
		if not cadre.Visible or actuel ~= id then
			cadre.Visible = true
			actuel = id :: string
			Habillage.apparaitre(cadre)
		end
	end

	Workspace:GetAttributeChangedSignal("Evenement"):Connect(maj)
	ecran.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	maj()
	task.spawn(function()
		while true do
			task.wait(1)
			if cadre.Visible then
				maj()
			end
		end
	end)
end

return InterfaceEvenement
