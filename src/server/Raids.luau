--!strict
-- Raids de bases (serveur) : vol d'une créature exposée et verrou de la base.
-- Le client n'envoie rien : le vol et le verrou passent par les
-- ProximityPrompts « Voler » / « Verrouiller » (Triggered côté serveur) et
-- toutes les vérifications sont faites ici.
-- `maintenant` (optionnel) sert uniquement aux tests en jeu.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Raid = require(ReplicatedStorage.Shared.Raid)
local Bases = require(script.Parent.Bases)
local Portage = require(script.Parent.Portage)
local Sauvegarde = require(script.Parent.Sauvegarde)

type Etat = {
	verrouJusqua: number?,
	pretA: number?,
	dernierTexte: string?,
	derniereVerrouillee: boolean?,
}

local Raids = {}

local reglages = Config.Raid

local etats: { [any]: Etat } = {}

local function estNombreFini(valeur: any): boolean
	return type(valeur) == "number"
		and valeur == valeur
		and valeur > -math.huge
		and valeur < math.huge
end

local function instant(maintenant: number?): number
	if estNombreFini(maintenant) then
		return maintenant :: number
	end
	return Workspace:GetServerTimeNow()
end

local function estJoueur(joueur: any): boolean
	return typeof(joueur) == "Instance" and joueur:IsA("Player")
end

local function racineEtHumanoide(joueur: any): (BasePart?, Humanoid?)
	local personnage = joueur.Character
	if typeof(personnage) ~= "Instance" then
		return nil, nil
	end
	local racine = (personnage :: Instance):FindFirstChild("HumanoidRootPart")
	local humanoide = (personnage :: Instance):FindFirstChildOfClass("Humanoid")
	if racine == nil or not racine:IsA("BasePart") then
		return nil, humanoide
	end
	return racine :: BasePart, humanoide
end

local function estVivant(joueur: any): boolean
	local racine, humanoide = racineEtHumanoide(joueur)
	return racine ~= nil and humanoide ~= nil and humanoide.Health > 0
end

local function envoyerMessage(joueur: any, texte: string)
	if not estJoueur(joueur) then
		return
	end
	local remote = ReplicatedStorage:FindFirstChild("MessageJeu")
	if remote and remote:IsA("RemoteEvent") then
		remote:FireClient(joueur, texte)
	end
end

local function envoyerAlerte(joueur: any, role: string, rarete: string, autre: string)
	if not estJoueur(joueur) then
		return
	end
	local remote = ReplicatedStorage:FindFirstChild("AlerteVol")
	if remote and remote:IsA("RemoteEvent") then
		remote:FireClient(joueur, role, rarete, autre)
	end
end

local function estVerrouillee(proprietaire: any, maintenant: number): boolean
	local etat = etats[proprietaire]
	return etat ~= nil and Raid.estVerrouillee(maintenant, etat.verrouJusqua)
end

-- Créature exposée n° `numero` de la base de `proprietaire`.
local function creatureExposee(proprietaire: any, numero: number): Model?
	local base = Bases.modeleDe(proprietaire)
	local dossier = base and base:FindFirstChild("CreaturesBase")
	if dossier == nil then
		return nil
	end
	for _, creature in dossier:GetChildren() do
		if creature:IsA("Model") and creature:GetAttribute("Emplacement") == numero then
			return creature
		end
	end
	return nil
end

local function contour(element: GuiObject, epaisseur: number)
	local trait = Instance.new("UIStroke")
	trait.Thickness = epaisseur
	trait.Color = Color3.new(0, 0, 0)
	trait.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	trait.Parent = element
end

-- « VOLÉ ! » rebondissant au-dessus du voleur pendant DureeAlerte.
local function afficherEffet(voleur: any)
	local personnage = voleur.Character
	if typeof(personnage) ~= "Instance" then
		return
	end
	local support = (personnage :: Instance):FindFirstChild("Head")
		or (personnage :: Instance):FindFirstChild("HumanoidRootPart")
	if support == nil or not support:IsA("BasePart") then
		return
	end
	local ancien = (personnage :: Instance):FindFirstChild("EffetVol", true)
	if ancien then
		ancien:Destroy()
	end

	local effet = Instance.new("BillboardGui")
	effet.Name = "EffetVol"
	effet.Size = UDim2.fromOffset(220, 90)
	effet.StudsOffset = Vector3.new(0, 7, 0)
	effet.AlwaysOnTop = true
	effet.MaxDistance = 150

	local texte = Instance.new("TextLabel")
	texte.Name = "Vole"
	texte.AnchorPoint = Vector2.new(0.5, 0.5)
	texte.Position = UDim2.fromScale(0.5, 0.5)
	texte.Size = UDim2.fromScale(1, 0.8)
	texte.BackgroundTransparency = 1
	texte.Font = Enum.Font.FredokaOne
	texte.TextScaled = true
	texte.TextColor3 = Color3.fromRGB(255, 60, 60)
	texte.Rotation = 6
	texte.Text = "VOLÉ !"
	texte.Parent = effet
	contour(texte, 4)
	effet.Parent = support

	local debut = os.clock()
	task.spawn(function()
		while effet.Parent ~= nil do
			RunService.Heartbeat:Wait()
			local ecoule = os.clock() - debut
			-- Rebond : saute puis retombe, de moins en moins haut.
			local hauteur = math.abs(math.sin(ecoule * 7)) * 18 * math.exp(-ecoule * 0.6)
			texte.Position = UDim2.new(0.5, 0, 0.5, -hauteur)
		end
	end)
	task.delay(reglages.DureeAlerte, function()
		effet:Destroy()
	end)
end

-- Candidats à l'expulsion : joueurs connectés et joueurs ayant une base.
local function candidats(): { any }
	local vus: { [any]: boolean } = {}
	local liste = {}
	for _, joueur in Players:GetPlayers() do
		vus[joueur] = true
		table.insert(liste, joueur)
	end
	for _, joueur in Bases.joueurs() do
		if not vus[joueur] then
			vus[joueur] = true
			table.insert(liste, joueur)
		end
	end
	return liste
end

-- Replace hors de la base tout intrus de la base verrouillée de `proprietaire`.
local function expulserIntrus(proprietaire: any, maintenant: number)
	local verrouillee = estVerrouillee(proprietaire, maintenant)
	if not verrouillee then
		return
	end
	local point = Bases.pointExpulsion(proprietaire)
	if point == nil then
		return
	end
	for _, joueur in candidats() do
		local estProprietaire = joueur == proprietaire
		if
			not estProprietaire
			and Raid.doitExpulser(
				estProprietaire,
				Bases.estDansBaseDe(joueur, proprietaire),
				verrouillee
			)
		then
			local personnage = joueur.Character
			if typeof(personnage) == "Instance" and personnage:IsA("Model") then
				personnage:PivotTo(point :: CFrame)
				envoyerMessage(joueur, "Base verrouillée !")
			end
		end
	end
end

local function publier(proprietaire: any, etat: Etat, maintenant: number)
	proprietaire:SetAttribute("VerrouJusqua", etat.verrouJusqua)
	proprietaire:SetAttribute("VerrouPretA", etat.pretA)
	etat.dernierTexte = Raid.texteVerrou(maintenant, etat.verrouJusqua, etat.pretA)
	etat.derniereVerrouillee = Raid.estVerrouillee(maintenant, etat.verrouJusqua)
	Bases.afficherVerrou(proprietaire, maintenant)
end

-- Vol de la créature n° `numero` de la base de `proprietaire` par `voleur`.
function Raids.voler(voleur: any, proprietaire: any, numero: any, maintenant: number?): boolean
	if voleur == nil or proprietaire == nil then
		return false
	end
	local t = instant(maintenant)
	local liste = Sauvegarde.creaturesDe(proprietaire)
	local emplacementValide = estNombreFini(numero)
		and numero % 1 == 0
		and numero >= 1
		and numero <= #liste
		and type(liste[numero]) == "string"

	local distance = math.huge
	local racine = racineEtHumanoide(voleur)
	local exposee = if emplacementValide then creatureExposee(proprietaire, numero) else nil
	if racine ~= nil and exposee ~= nil then
		distance = (racine.Position - exposee:GetPivot().Position).Magnitude
	end

	local ok = Raid.verifierVol({
		memeJoueur = voleur == proprietaire,
		voleurVivant = estVivant(voleur),
		voleurPorte = Portage.porte(voleur) or voleur:GetAttribute("Porte") ~= nil,
		voleurDansBaseCible = Bases.estDansBaseDe(voleur, proprietaire),
		baseVerrouillee = estVerrouillee(proprietaire, t),
		emplacementValide = emplacementValide,
		distance = distance,
	})
	if not ok then
		return false
	end

	local rarete = Sauvegarde.retirerCreature(proprietaire, numero)
	if rarete == nil then
		return false
	end
	if not Portage.porterVolee(voleur, rarete) then
		-- Ne devrait pas arriver (déjà vérifié) : la créature revient.
		Sauvegarde.ajouterCreature(proprietaire, rarete)
		Bases.afficherCreatures(proprietaire, Sauvegarde.creaturesDe(proprietaire))
		return false
	end
	Bases.afficherCreatures(proprietaire, Sauvegarde.creaturesDe(proprietaire))

	afficherEffet(voleur)
	envoyerAlerte(proprietaire, "victime", rarete, tostring(voleur.Name))
	envoyerAlerte(voleur, "voleur", rarete, tostring(proprietaire.Name))
	return true
end

-- Achat du verrou de la base de `proprietaire` par `declencheur`.
function Raids.verrouiller(proprietaire: any, declencheur: any, maintenant: number?): boolean
	if proprietaire == nil or declencheur == nil then
		return false
	end
	local t = instant(maintenant)
	local etat: Etat = etats[proprietaire] or {}

	local distance = math.huge
	local racine = racineEtHumanoide(declencheur)
	local base = Bases.modeleDe(proprietaire)
	local bouton = base and base:FindFirstChild("BoutonVerrou")
	if racine ~= nil and bouton ~= nil and bouton:IsA("BasePart") then
		distance = (racine.Position - bouton.Position).Magnitude
	end

	local pieces = proprietaire:GetAttribute("Pieces")
	local ok, raison = Raid.verifierVerrou({
		estProprietaire = declencheur == proprietaire,
		vivant = estVivant(declencheur),
		distance = distance,
		pieces = if type(pieces) == "number" then pieces else nil,
		maintenant = t,
		verrouJusqua = etat.verrouJusqua,
		pretA = etat.pretA,
	})
	if not ok then
		if declencheur == proprietaire then
			if raison == "pieces" then
				envoyerMessage(declencheur, "Pas assez de pièces !")
			elseif raison == "recharge" then
				envoyerMessage(declencheur, "Verrou en recharge !")
			end
		end
		return false
	end

	proprietaire:SetAttribute("Pieces", (pieces :: number) - reglages.PrixVerrou)
	local jusqua, pretA = Raid.acheterVerrou(t)
	etat.verrouJusqua = jusqua
	etat.pretA = pretA
	etats[proprietaire] = etat
	publier(proprietaire, etat, t)
	envoyerMessage(proprietaire, "Base verrouillée !")
	expulserIntrus(proprietaire, t)
	return true
end

-- Un pas de la boucle serveur : expulse les intrus des bases verrouillées et
-- met à jour panneaux et boucliers quand le texte change (une fois par seconde).
function Raids.pas(maintenant: number?)
	local t = instant(maintenant)
	for proprietaire, etat in etats do
		expulserIntrus(proprietaire, t)
		local texte = Raid.texteVerrou(t, etat.verrouJusqua, etat.pretA)
		local verrouillee = Raid.estVerrouillee(t, etat.verrouJusqua)
		if texte ~= etat.dernierTexte or verrouillee ~= etat.derniereVerrouillee then
			etat.dernierTexte = texte
			etat.derniereVerrouillee = verrouillee
			Bases.afficherVerrou(proprietaire, t)
		end
	end
end

-- Départ du joueur : oublie son verrou.
function Raids.nettoyer(joueur: any)
	etats[joueur] = nil
end

return Raids
