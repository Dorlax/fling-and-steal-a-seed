--!strict
-- Étoiles qui tournent autour de la tête des joueurs étourdis par un monstre
-- (attribut EtourdiJusqua écrit par le serveur). Affichage seulement, pour
-- tous les joueurs visibles.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Sons = require(script.Parent:WaitForChild("Sons"))

local EffetsComiques = {}

local NOMBRE = 3
local RAYON = 1.6
local TOURS_PAR_SECONDE = 1.2
local COULEURS = {
	Color3.fromRGB(255, 230, 60),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(255, 170, 60),
}

type Ronde = { etoiles: { BillboardGui }, fin: number }

local rondes: { [Player]: Ronde } = {}

local function retirer(joueur: Player)
	local ronde = rondes[joueur]
	if ronde then
		for _, e in ronde.etoiles do
			e:Destroy()
		end
		rondes[joueur] = nil
	end
end

local function etourdir(joueur: Player)
	local fin = joueur:GetAttribute("EtourdiJusqua")
	if type(fin) ~= "number" or fin <= Workspace:GetServerTimeNow() then
		return
	end
	local personnageOuNil = joueur.Character
	if personnageOuNil == nil then
		return
	end
	local trouve = (personnageOuNil :: Model):FindFirstChild("Head")
	if trouve == nil or not trouve:IsA("BasePart") then
		return
	end
	local tete = trouve :: BasePart
	retirer(joueur)
	local etoiles = {}
	for i = 1, NOMBRE do
		local panneau = Instance.new("BillboardGui")
		panneau.Name = "EtoileEtourdi"
		panneau.Size = UDim2.fromOffset(34, 34)
		panneau.AlwaysOnTop = true
		panneau.MaxDistance = 120
		panneau.Adornee = tete
		local texte = Instance.new("TextLabel")
		texte.Size = UDim2.fromScale(1, 1)
		texte.BackgroundTransparency = 1
		texte.Text = "★"
		texte.TextScaled = true
		texte.TextColor3 = COULEURS[i]
		texte.TextStrokeTransparency = 0
		texte.Parent = panneau
		panneau.Parent = tete
		table.insert(etoiles, panneau)
	end
	rondes[joueur] = { etoiles = etoiles, fin = fin :: number }
end

local function suivre(joueur: Player)
	joueur:GetAttributeChangedSignal("EtourdiJusqua"):Connect(function()
		etourdir(joueur)
		if joueur == Players.LocalPlayer and joueur:GetAttribute("EtourdiJusqua") ~= nil then
			Sons.jouer("Choc")
		end
	end)
end

function EffetsComiques.demarrer()
	for _, joueur in Players:GetPlayers() do
		suivre(joueur)
	end
	Players.PlayerAdded:Connect(suivre)
	Players.PlayerRemoving:Connect(retirer)

	RunService.RenderStepped:Connect(function()
		local maintenant = Workspace:GetServerTimeNow()
		local angle = os.clock() * TOURS_PAR_SECONDE * 2 * math.pi
		for joueur, ronde in rondes do
			if maintenant >= ronde.fin or joueur.Parent == nil then
				retirer(joueur)
			else
				for i, etoile in ronde.etoiles do
					local a = angle + (i - 1) * 2 * math.pi / NOMBRE
					etoile.StudsOffset = Vector3.new(
						math.cos(a) * RAYON,
						1.4 + math.sin(a * 2) * 0.2,
						math.sin(a) * RAYON
					)
				end
			end
		end
	end)
end

return EffetsComiques
