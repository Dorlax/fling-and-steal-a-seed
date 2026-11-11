--!strict
-- Gros bouton rond « PLAQUER ! » (bas à droite) + touche clavier et manette.
-- Le client envoie seulement Plaquer:FireServer() sans argument : la cible,
-- la portée et les délais sont décidés par le serveur. L'affichage du délai
-- vient de l'attribut PlaquagePretA écrit par le serveur.
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Plaquage = require(Shared:WaitForChild("Plaquage"))
local Style = require(Shared:WaitForChild("Style"))
local Habillage = require(script.Parent:WaitForChild("Habillage"))

local InterfacePlaquage = {}

local COULEUR_PRET = Habillage.nommee("Orange")
local COULEUR_ATTENTE = Habillage.nommee("Gris")
local TAILLE = 120 -- pixels : assez grand pour le tactile
local MARGE_PORTEE = 2 -- studs : tolérance de l'aide côté client (le serveur tranche)
local DISTANCE_AFFICHAGE = 35 -- studs : le bouton n'apparaît qu'avec un porteur aussi près

-- Noms d'Enum.KeyCode venant de Config (« F », « ButtonY »).
local function codeTouche(nom: string): Enum.KeyCode
	return (Enum.KeyCode :: any)[nom] :: Enum.KeyCode
end

local function racineDe(joueur: Player): BasePart?
	local personnage = joueur.Character
	if personnage == nil then
		return nil
	end
	local racine = (personnage :: Model):FindFirstChild("HumanoidRootPart")
	if racine and racine:IsA("BasePart") then
		return racine
	end
	return nil
end

function InterfacePlaquage.demarrer()
	local joueur = Players.LocalPlayer
	local remote = ReplicatedStorage:WaitForChild("Plaquer") :: RemoteEvent

	local ecran = Instance.new("ScreenGui")
	ecran.Name = "InterfacePlaquage"
	ecran.ResetOnSpawn = false

	-- À gauche du bouton LANCER (bas à droite de l'écran), rond.
	local bouton, texte = Habillage.bouton(ecran, "BoutonPlaquer", {
		texte = "PLAQUER !",
		couleur = COULEUR_PRET,
		taille = Vector2.new(TAILLE, TAILLE),
		rond = true,
	})
	bouton.AnchorPoint = Vector2.new(1, 1)
	bouton.Position = UDim2.new(1, -210, 1, -20)

	-- Jauge de recharge, juste au-dessus du bouton.
	local jauge = Habillage.jauge(ecran, "RechargePlaquer", UDim2.fromOffset(TAILLE - 10, 16))
	jauge.cadre.AnchorPoint = Vector2.new(0.5, 1)
	jauge.cadre.Position = UDim2.new(1, -210 - TAILLE / 2, 1, -28 - TAILLE)

	local function pret(): boolean
		local pretA = joueur:GetAttribute("PlaquagePretA")
		return not (type(pretA) == "number" and Workspace:GetServerTimeNow() < pretA)
	end

	-- Aide côté client seulement : y a-t-il un porteur à moins de `portee` ?
	local function porteurA(portee: number): boolean
		local maRacine = racineDe(joueur)
		if maRacine == nil then
			return false
		end
		local maPosition = (maRacine :: BasePart).Position
		for _, autre in Players:GetPlayers() do
			if autre ~= joueur and autre:GetAttribute("Porte") ~= nil then
				local racine = racineDe(autre)
				if racine ~= nil then
					local distance = ((racine :: BasePart).Position - maPosition).Magnitude
					if distance <= portee then
						return true
					end
				end
			end
		end
		return false
	end

	local function plaquer()
		Habillage.rebondir(bouton)
		remote:FireServer()
	end

	bouton.Activated:Connect(plaquer)

	local clavier = codeTouche(Config.Plaquage.Touches.Clavier)
	local manette = codeTouche(Config.Plaquage.Touches.Manette)
	-- La touche clavier est partagée avec LANCER : si personne n'est à
	-- plaquer, l'appui est laissé au lancer (Pass). Manette et bouton
	-- envoient toujours la demande.
	ContextActionService:BindAction(
		"Plaquer",
		function(_, etat: Enum.UserInputState, entree: InputObject)
			if etat ~= Enum.UserInputState.Begin then
				return Enum.ContextActionResult.Pass
			end
			local portee = Config.Plaquage.Portee + MARGE_PORTEE
			if entree.KeyCode == clavier and not (pret() and porteurA(portee)) then
				return Enum.ContextActionResult.Pass
			end
			plaquer()
			return Enum.ContextActionResult.Sink
		end,
		false,
		clavier,
		manette
	)

	-- Délai : bouton grisé et secondes restantes. Le bouton (et sa jauge)
	-- n'apparaît que si un porteur est dans les parages ou pendant la recharge.
	task.spawn(function()
		while true do
			local estPret = pret()
			local visible = not estPret or porteurA(DISTANCE_AFFICHAGE)
			bouton.Visible = visible
			jauge.cadre.Visible = visible
			local maintenant = Workspace:GetServerTimeNow()
			local pretA = joueur:GetAttribute("PlaquagePretA") :: number?
			texte.Text = Plaquage.texteBouton(maintenant, pretA)
			bouton.BackgroundColor3 = if estPret then COULEUR_PRET else COULEUR_ATTENTE
			texte.TextTransparency = if estPret then 0 else 0.15
			jauge.maj(Style.ratioRecharge(maintenant, pretA, Config.Plaquage.DelaiRecuperation))
			task.wait(0.1)
		end
	end)

	ecran.Parent = joueur:WaitForChild("PlayerGui")
end

return InterfacePlaquage
