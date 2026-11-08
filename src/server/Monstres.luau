--!strict
-- Monstres des Terres Sauvages (serveur) : apparition, déplacement, coups,
-- vagues de nuit et nettoyage. Le client n'envoie rien pour les monstres :
-- aucun RemoteEvent n'est créé ici, tout est décidé par le serveur.
-- `maintenant` (optionnel) sert uniquement aux tests en jeu.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Monstre = require(ReplicatedStorage.Shared.Monstre)
local Bases = require(script.Parent.Bases)
local Portage = require(script.Parent.Portage)

type Etat = {
	zone: string,
	apparition: Vector3,
	pretA: number?, -- fin de la recharge
	cible: any?, -- joueur poursuivi
	destination: Vector3?, -- point d'errance
	retour: boolean, -- revient à son point d'apparition
	rebond: number,
}

local Monstres = {}

local reglages = Config.Monstres
local DUREE_PAF = 1
local DUREE_POUF = 0.4
local VITESSE_ERRANCE = 0.5 -- fraction de la vitesse quand il erre
local ARRIVE = 2 -- studs : destination atteinte

local etats: { [Model]: Etat } = {}
local protection: { [any]: number } = {} -- fin de protection de chaque joueur
local aleatoire = Random.new()
local demarre = false

local function estNombreFini(valeur: any): boolean
	return type(valeur) == "number"
		and valeur == valeur
		and valeur > -math.huge
		and valeur < math.huge
end

local function instantDe(maintenant: number?): number
	return if estNombreFini(maintenant) then maintenant :: number else Workspace:GetServerTimeNow()
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

local function envoyerMessage(joueur: any, texte: string)
	if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") then
		return
	end
	local remote = ReplicatedStorage:FindFirstChild("MessageJeu")
	if remote and remote:IsA("RemoteEvent") then
		remote:FireClient(joueur, texte)
	end
end

local function couleurDe(rgb: { number }): Color3
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

-- Dossier Workspace.Monstres (créé si besoin).
function Monstres.dossier(): Folder
	local existant = Workspace:FindFirstChild("Monstres")
	if existant and existant:IsA("Folder") then
		return existant
	end
	local dossier = Instance.new("Folder")
	dossier.Name = "Monstres"
	dossier.Parent = Workspace
	return dossier
end

local function hauteurSol(zone: string): number
	return Monstre.reglagesZone(zone).Taille / 2
end

-- Point aléatoire de la bande d'une zone, au niveau du sol.
local function pointAleatoire(zone: string): Vector3
	local zMin, zMax = Monstre.bandeZone(zone)
	local p = Monstre.limiter({
		X = aleatoire:NextNumber(-380, 380),
		Y = hauteurSol(zone),
		Z = aleatoire:NextNumber(zMin, zMax),
	}, zone)
	return Vector3.new(p.X, p.Y, p.Z)
end

-- ----------------------------------------------------------------------------
-- Apparence (cartoon : boule colorée, gros yeux, sourire, langue tirée)

local function partie(
	modele: Model,
	nom: string,
	taille: Vector3,
	couleur: Color3,
	decalage: CFrame
): Part
	local p = Instance.new("Part")
	p.Name = nom
	p.Shape = Enum.PartType.Ball
	p.Size = taille
	p.Color = couleur
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CastShadow = false
	p.CFrame = decalage
	p.Parent = modele
	return p
end

local function appliquerYeux(modele: Model, nuit: boolean)
	for _, objet in modele:GetChildren() do
		if objet:IsA("BasePart") and string.sub(objet.Name, 1, 4) == "Oeil" then
			objet.Material = if nuit then Enum.Material.Neon else Enum.Material.SmoothPlastic
		end
	end
end

local function creerModele(zone: string, position: Vector3): Model
	local r = Monstre.reglagesZone(zone)
	local t = r.Taille
	local modele = Instance.new("Model")
	modele.Name = "Monstre"

	-- Construit à l'origine, face vers -Z (LookVector), puis déplacé.
	local corps = partie(modele, "Corps", Vector3.one * t, couleurDe(r.Couleur), CFrame.new())
	modele.PrimaryPart = corps
	for _, cote in { -1, 1 } do
		local nom = if cote < 0 then "Gauche" else "Droite"
		partie(
			modele,
			"Oeil" .. nom,
			Vector3.one * t * 0.38,
			Color3.new(1, 1, 1),
			CFrame.new(cote * t * 0.2, t * 0.18, -t * 0.36)
		)
		partie(
			modele,
			"Pupille" .. nom,
			Vector3.one * t * 0.16,
			Color3.new(0.05, 0.05, 0.05),
			CFrame.new(cote * t * 0.2, t * 0.18, -t * 0.53)
		)
	end
	local bouche = partie(
		modele,
		"Bouche",
		Vector3.new(t * 0.34, t * 0.12, t * 0.12),
		Color3.fromRGB(120, 30, 60),
		CFrame.new(0, -t * 0.14, -t * 0.47)
	)
	bouche.Shape = Enum.PartType.Cylinder
	bouche.Size = Vector3.new(t * 0.08, t * 0.3, t * 0.3)
	bouche.CFrame = CFrame.new(0, -t * 0.14, -t * 0.47) * CFrame.Angles(0, math.rad(90), 0)
	partie(
		modele,
		"Langue",
		Vector3.new(t * 0.16, t * 0.1, t * 0.16),
		Color3.fromRGB(255, 120, 160),
		CFrame.new(t * 0.05, -t * 0.24, -t * 0.5)
	)

	local panneau = Instance.new("BillboardGui")
	panneau.Name = "Panneau"
	panneau.Size = UDim2.fromOffset(160, 36)
	panneau.StudsOffset = Vector3.new(0, t / 2 + 1.5, 0)
	panneau.MaxDistance = 150
	panneau.Parent = corps
	local texte = Instance.new("TextLabel")
	texte.Name = "Nom"
	texte.Size = UDim2.fromScale(1, 1)
	texte.BackgroundTransparency = 1
	texte.Font = Enum.Font.FredokaOne
	texte.TextScaled = true
	texte.TextColor3 = couleurDe(r.Couleur)
	texte.TextStrokeColor3 = Color3.new(0, 0, 0)
	texte.TextStrokeTransparency = 0
	texte.Text = r.Nom
	texte.Parent = panneau

	modele:SetAttribute("Monstre", true)
	modele:SetAttribute("Zone", zone)
	appliquerYeux(modele, Workspace:GetAttribute("Nuit") == true)
	local angle = aleatoire:NextNumber(0, 2 * math.pi)
	modele:PivotTo(CFrame.new(position) * CFrame.Angles(0, angle, 0))
	return modele
end

-- Petit nuage « pouf » quand un monstre disparaît.
local function pouf(position: Vector3)
	local nuage = Instance.new("Part")
	nuage.Name = "PoufMonstre"
	nuage.Shape = Enum.PartType.Ball
	nuage.Size = Vector3.one * 2
	nuage.Color = Color3.new(1, 1, 1)
	nuage.Material = Enum.Material.SmoothPlastic
	nuage.Anchored = true
	nuage.CanCollide = false
	nuage.CanTouch = false
	nuage.CastShadow = false
	nuage.Position = position
	nuage.Parent = Workspace
	TweenService
		:Create(nuage, TweenInfo.new(DUREE_POUF), { Size = Vector3.one * 8, Transparency = 1 })
		:Play()
	task.delay(DUREE_POUF, function()
		nuage:Destroy()
	end)
end

-- « PAF ! » jaune au-dessus du joueur frappé.
local function effetPaf(joueur: any)
	local personnage = joueur.Character
	if typeof(personnage) ~= "Instance" then
		return
	end
	local support = (personnage :: Instance):FindFirstChild("Head")
		or (personnage :: Instance):FindFirstChild("HumanoidRootPart")
	if support == nil or not support:IsA("BasePart") then
		return
	end
	local ancien = support:FindFirstChild("EffetMonstre")
	if ancien then
		ancien:Destroy()
	end
	local effet = Instance.new("BillboardGui")
	effet.Name = "EffetMonstre"
	effet.Size = UDim2.fromOffset(180, 70)
	effet.StudsOffset = Vector3.new(0, 3, 0)
	effet.AlwaysOnTop = true
	effet.MaxDistance = 150
	local texte = Instance.new("TextLabel")
	texte.Size = UDim2.fromScale(1, 1)
	texte.BackgroundTransparency = 1
	texte.Font = Enum.Font.FredokaOne
	texte.TextScaled = true
	texte.TextColor3 = Color3.fromRGB(255, 220, 40)
	texte.Rotation = 8
	texte.Text = "PAF !"
	texte.Parent = effet
	local trait = Instance.new("UIStroke")
	trait.Thickness = 4
	trait.Color = Color3.new(0, 0, 0)
	trait.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	trait.Parent = texte
	effet.Parent = support
	task.delay(DUREE_PAF, function()
		effet:Destroy()
	end)
end

-- ----------------------------------------------------------------------------
-- Apparition et disparition

local function apparaitre(zone: string): Model
	local position = pointAleatoire(zone)
	local modele = creerModele(zone, position)
	etats[modele] = {
		zone = zone,
		apparition = position,
		pretA = nil,
		cible = nil,
		destination = nil,
		retour = false,
		rebond = 0,
	}
	modele.Parent = Monstres.dossier()
	return modele
end

local function retirer(modele: Model)
	etats[modele] = nil
	if modele.Parent ~= nil then
		pouf(modele:GetPivot().Position)
	end
	modele:Destroy()
end

-- Monstres vivants d'une zone (oublie ceux détruits ailleurs).
local function monstresDe(zone: string): { Model }
	local dossier = Monstres.dossier()
	local liste = {}
	for modele, etat in etats do
		if modele.Parent ~= dossier then
			etats[modele] = nil
		elseif etat.zone == zone then
			table.insert(liste, modele)
		end
	end
	return liste
end

-- Complète (ou réduit) chaque zone jusqu'au nombre voulu pour la phase de
-- `maintenant` : NombreJour le jour, NombreNuit la nuit (vague).
function Monstres.completer(maintenant: number?)
	local nuit = Monstre.phase(instantDe(maintenant)) == "Nuit"
	for _, z in Config.Lancer.Zones do
		local zone = z.Nom
		local liste = monstresDe(zone)
		local voulu = Monstre.nombreVoulu(zone, nuit)
		for _ = #liste + 1, voulu do
			apparaitre(zone)
		end
		for i = #liste, voulu + 1, -1 do
			retirer(liste[i])
		end
	end
end

-- ----------------------------------------------------------------------------
-- Coups

-- Tente un coup du monstre sur le joueur. Renvoie true, ou false et la raison.
function Monstres.frapper(monstre: any, joueur: any, maintenant: number?): (boolean, string?)
	if typeof(monstre) ~= "Instance" or not monstre:IsA("Model") then
		return false, "monstre"
	end
	local etat = etats[monstre :: Model]
	if etat == nil or monstre.Parent ~= Monstres.dossier() then
		return false, "monstre"
	end
	local instant = instantDe(maintenant)
	local position = (monstre :: Model):GetPivot().Position
	local racine, humanoide = racineEtHumanoide(joueur)
	local vivant = racine ~= nil and humanoide ~= nil and (humanoide :: Humanoid).Health > 0
	local distance = if racine then (racine.Position - position).Magnitude else math.huge

	local ok, raison = Monstre.peutFrapper({
		zone = etat.zone,
		cibleVivante = vivant,
		cibleDansSaBase = vivant and Bases.estDansSaBase(joueur),
		distance = distance,
		maintenant = instant,
		pretA = etat.pretA,
		protegeeJusqua = protection[joueur],
	})
	if not ok then
		return false, raison
	end

	local hum = humanoide :: Humanoid
	hum:TakeDamage(Monstre.reglagesZone(etat.zone).Degats)
	-- S'il meurt, la règle de Portage (mort = la créature retombe) s'applique.
	local creature: Model? = nil
	if hum.Health > 0 and Portage.porte(joueur) then
		creature = Portage.lacher(joueur, position, instant)
	end

	protection[joueur] = instant + reglages.DureeProtection
	joueur:SetAttribute("ProtegeMonstreJusqua", instant + reglages.DureeProtection)
	etat.pretA = instant + Monstre.reglagesZone(etat.zone).Recharge

	effetPaf(joueur)
	if creature then
		envoyerMessage(joueur, "Un monstre t'a frappé… tu as lâché ta créature !")
	else
		envoyerMessage(joueur, "Un monstre t'a frappé !")
	end
	return true, nil
end

-- ----------------------------------------------------------------------------
-- Déplacement

type InfoJoueur = { joueur: any, position: Vector3, valide: boolean }

local function infosJoueurs(instant: number): { InfoJoueur }
	local infos = {}
	for _, joueur in Players:GetPlayers() do
		local racine, humanoide = racineEtHumanoide(joueur)
		if racine and humanoide then
			local p = racine.Position
			local protege = protection[joueur]
			local valide = humanoide.Health > 0
				and p.Z >= reglages.BordBases
				and not (protege ~= nil and instant < protege)
				and not Bases.estDansSaBase(joueur)
			table.insert(infos, { joueur = joueur, position = p, valide = valide })
		end
	end
	return infos
end

local function horizontal(v: Vector3): Vector3
	return Vector3.new(v.X, 0, v.Z)
end

local function avancer(modele: Model, etat: Etat, infos: { InfoJoueur }, instant: number)
	local r = Monstre.reglagesZone(etat.zone)
	local position = modele:GetPivot().Position

	-- Cible : le joueur valide le plus proche à portée de détection.
	local candidats: { Monstre.Candidat } = {}
	for i, info in infos do
		candidats[i] = { distance = (info.position - position).Magnitude, valide = info.valide }
	end
	local choix = Monstre.choisirCible(candidats, r.PorteeDetection)
	local loin = horizontal(position - etat.apparition).Magnitude > reglages.DistanceDisparition

	local but: Vector3
	local vitesse = r.Vitesse
	if etat.retour or (choix ~= nil and loin) then
		-- Trop loin de chez lui : il abandonne et rentre.
		etat.retour = true
		etat.cible = nil
		but = etat.apparition
		if horizontal(position - but).Magnitude <= ARRIVE then
			etat.retour = false
		end
	elseif choix ~= nil then
		local info = infos[choix :: number]
		etat.cible = info.joueur
		etat.destination = nil
		but = info.position
	else
		etat.cible = nil
		local destination = etat.destination
		if destination == nil or horizontal(position - destination).Magnitude <= ARRIVE then
			destination = pointAleatoire(etat.zone)
			etat.destination = destination
		end
		but = destination :: Vector3
		vitesse *= VITESSE_ERRANCE
	end

	local ecart = horizontal(but - position)
	local pas = math.min(vitesse * reglages.IntervalleIA, ecart.Magnitude)
	local direction = if ecart.Magnitude > 0.01 then ecart.Unit else nil
	local suivant = if direction then position + direction * pas else position
	if pas > 0.01 then
		etat.rebond += reglages.IntervalleIA * 12
	end
	-- Rebond vertical (visuel seulement).
	local hauteur = hauteurSol(etat.zone) + math.abs(math.sin(etat.rebond)) * r.Taille * 0.15
	-- Chaque pas passe par la limite : jamais dans une base, jamais hors de sa zone.
	local p = Monstre.limiter({ X = suivant.X, Y = hauteur, Z = suivant.Z }, etat.zone)
	local nouvelle = Vector3.new(p.X, p.Y, p.Z)
	local regard = if direction then direction else modele:GetPivot().LookVector
	modele:PivotTo(CFrame.lookAt(nouvelle, nouvelle + horizontal(regard)))

	if etat.cible ~= nil then
		Monstres.frapper(modele, etat.cible, instant)
	end
end

-- Un pas de la boucle d'IA pour tous les monstres.
function Monstres.pas(maintenant: number?)
	local instant = instantDe(maintenant)
	local dossier = Monstres.dossier()
	local infos = infosJoueurs(instant)
	for modele, etat in etats do
		if modele.Parent ~= dossier then
			etats[modele] = nil
		else
			avancer(modele, etat, infos, instant)
		end
	end
end

-- Départ d'un joueur : sa protection est oubliée et les monstres qui le
-- poursuivaient en choisiront un autre.
function Monstres.nettoyer(joueur: any)
	protection[joueur] = nil
	for _, etat in etats do
		if etat.cible == joueur then
			etat.cible = nil
		end
	end
end

-- Premiers monstres, yeux brillants la nuit, boucle d'IA et vagues.
function Monstres.demarrer()
	Monstres.dossier()
	Monstres.completer()
	if demarre then
		return
	end
	demarre = true
	Workspace:GetAttributeChangedSignal("Nuit"):Connect(function()
		local nuit = Workspace:GetAttribute("Nuit") == true
		for modele in etats do
			appliquerYeux(modele, nuit)
		end
	end)
	task.spawn(function()
		local dernierePhase = Monstre.phase(Workspace:GetServerTimeNow())
		local derniereVague = Workspace:GetServerTimeNow()
		while true do
			task.wait(reglages.IntervalleIA)
			local instant = Workspace:GetServerTimeNow()
			Monstres.pas(instant)
			-- Tombée de la nuit (vague), lever du jour (« pouf »), puis
			-- complément régulier toutes les IntervalleVague secondes.
			local phase = Monstre.phase(instant)
			if phase ~= dernierePhase or instant - derniereVague >= reglages.IntervalleVague then
				dernierePhase = phase
				derniereVague = instant
				Monstres.completer(instant)
			end
		end
	end)
end

return Monstres
