--!strict
-- Passes Robux (× 2 Force, × 2 Vitesse, × 2 Pièces, Ramassage auto), côté
-- serveur. La possession est lue chez Roblox (UserOwnsGamePassAsync) à
-- l'arrivée et après un achat, puis écrite dans l'attribut « Pass<Id> » du
-- Player. Le client ne fait qu'ouvrir la fenêtre d'achat.
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Passes = require(ReplicatedStorage.Shared.Passes)
local Portage = require(script.Parent.Portage)
local TerresSauvages = require(script.Parent.TerresSauvages)

local PassesRobux = {}

local function possede(joueur: Player, numero: number): boolean
	local ok, resultat = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(joueur.UserId, numero)
	end)
	return ok and resultat == true
end

-- Lit chez Roblox tous les passes créés (Id > 0) et écrit les attributs.
function PassesRobux.verifier(joueur: Player)
	for _, id in Config.Passes.Ordre do
		local numero = (Config.Passes.Liste :: any)[id].Id
		if type(numero) == "number" and numero > 0 and possede(joueur, numero) then
			joueur:SetAttribute(Passes.attribut(id), true)
		end
	end
end

-- Ramassage auto : récolte la créature la plus proche à portée de récolte
-- (Portage.recolter refait toutes les vérifications).
function PassesRobux.ramasser(joueur: Player): boolean
	if joueur:GetAttribute(Passes.attribut("RamassageAuto")) ~= true then
		return false
	end
	if Portage.porte(joueur) then
		return false
	end
	local personnage = joueur.Character
	local racine = personnage and personnage:FindFirstChild("HumanoidRootPart")
	if racine == nil or not racine:IsA("BasePart") then
		return false
	end
	local position = (racine :: BasePart).Position
	local portee = Config.Creatures.DistanceRecolte
	local meilleure: Model? = nil
	for _, creature in TerresSauvages.dossierCreatures():GetChildren() do
		if creature:IsA("Model") then
			local libre = creature:GetAttribute("Libre") == true
			if libre or creature:GetAttribute("Proprietaire") == joueur.UserId then
				local distance = (creature:GetPivot().Position - position).Magnitude
				if distance <= portee then
					portee = distance
					meilleure = creature
				end
			end
		end
	end
	if meilleure == nil then
		return false
	end
	return Portage.recolter(joueur, meilleure)
end

function PassesRobux.demarrer()
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(
		function(joueur: Player, numero: number, achete: boolean)
			local id = Passes.depuisNumero(numero)
			-- Événement envoyé par Roblox au serveur : `achete` est fiable (le cache
			-- de UserOwnsGamePassAsync peut encore dire non juste après l'achat).
			if achete and id ~= nil then
				joueur:SetAttribute(Passes.attribut(id), true)
			end
		end
	)
	task.spawn(function()
		while true do
			task.wait(Config.Passes.IntervalleRamassage)
			for _, joueur in Players:GetPlayers() do
				PassesRobux.ramasser(joueur)
			end
		end
	end)
end

return PassesRobux
