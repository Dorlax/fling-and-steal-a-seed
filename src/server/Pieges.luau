--!strict
-- Pièges des Terres Sauvages (serveur) : pose, déclenchement, effets, boucle
-- et nettoyage. Le client n'envoie que le nom du type de piège : position,
-- prix, délais, limites et victimes sont décidés et vérifiés ici.
-- `maintenant` (optionnel) sert uniquement aux tests en jeu ; le gestionnaire
-- du RemoteEvent ne le transmet jamais.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Piege = require(ReplicatedStorage.Shared.Piege)
local Bases = require(script.Parent.Bases)
local Entrainement = require(script.Parent.Entrainement)

type Info = {
	poseur: any,
	poseurId: number,
	typePiege: string,
	poseA: number,
}

type Saut = { useJumpPower: boolean, jumpPower: number, jumpHeight: number }

local Pieges = {}

local reglages = Config.Pieges
local types = reglages.Types
local DUREE_POUF = 0.4
local NOM_EFFET = "EffetPiege"
local NOM_FILET_TETE = "FiletTete"
local TAILLE_GRAINE = 3 -- même gabarit qu'une créature au sol

local infos: { [Model]: Info } = {}
local pretA: { [any]: number } = {} -- fin du délai entre deux poses
local protegeJusqua: { [any]: number } = {} -- fin de protection de chaque victime
local immobileJusqua: { [any]: number } = {} -- fin d'immobilisation
local englues: { [any]: boolean } = {}
local sauts: { [any]: Saut } = {} -- valeurs de saut à restaurer
local connus: { [any]: boolean } = {} -- joueurs (y compris faux joueurs de test) déjà vus
local derniereRequete: { [any]: number } = {} -- anti-spam (os.clock)
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

local function couleurDe(rgb: { number }): Color3
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
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

local function horizontale(a: Vector3, b: Vector3): number
	return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
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

-- Dossier Workspace.Pieges (créé si besoin).
function Pieges.dossier(): Folder
	local existant = Workspace:FindFirstChild("Pieges")
	if existant and existant:IsA("Folder") then
		return existant
	end
	local dossier = Instance.new("Folder")
	dossier.Name = "Pieges"
	dossier.Parent = Workspace
	return dossier
end

-- Nombre de pièges actifs posés par le joueur.
function Pieges.actifsDe(joueur: any): number
	local dossier = Pieges.dossier()
	local n = 0
	for modele, info in infos do
		if info.poseur == joueur and modele.Parent == dossier then
			n += 1
		end
	end
	return n
end

local function majActifs(joueur: any)
	local n = Pieges.actifsDe(joueur)
	joueur:SetAttribute("PiegesActifs", if n > 0 then n else nil)
end

-- ----------------------------------------------------------------------------
-- Apparence

local function partie(
	modele: Model,
	nom: string,
	taille: Vector3,
	cframe: CFrame,
	couleur: Color3
): Part
	local p = Instance.new("Part")
	p.Name = nom
	p.Size = taille
	p.CFrame = cframe
	p.Color = couleur
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = modele
	return p
end

local function disque(
	modele: Model,
	nom: string,
	diametre: number,
	epaisseur: number,
	centre: Vector3,
	couleur: Color3
): Part
	local p = partie(
		modele,
		nom,
		Vector3.new(epaisseur, diametre, diametre),
		CFrame.new(centre) * CFrame.Angles(0, 0, math.rad(90)),
		couleur
	)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function creerFilet(modele: Model, sol: Vector3)
	local couleur = couleurDe(types.Filet.Couleur)
	local diametre = reglages.RayonDeclenchement * 2
	local base = disque(modele, "Base", diametre, 0.2, sol + Vector3.new(0, 0.1, 0), couleur)
	base.Transparency = 0.55
	base.Material = Enum.Material.SmoothPlastic
	modele.PrimaryPart = base
	-- Quadrillage fin (Neon), légèrement visible.
	local pas = diametre / 4
	for i = -1, 1 do
		local corde = math.sqrt(math.max((diametre / 2) ^ 2 - (i * pas) ^ 2, 0)) * 2
		local fil = partie(
			modele,
			"FilX",
			Vector3.new(corde, 0.08, 0.12),
			CFrame.new(sol + Vector3.new(0, 0.22, i * pas)),
			couleur
		)
		fil.Material = Enum.Material.Neon
		fil.Transparency = 0.35
		local fil2 = partie(
			modele,
			"FilZ",
			Vector3.new(0.12, 0.08, corde),
			CFrame.new(sol + Vector3.new(i * pas, 0.22, 0)),
			couleur
		)
		fil2.Material = Enum.Material.Neon
		fil2.Transparency = 0.35
	end
end

local function creerGlu(modele: Model, sol: Vector3)
	local couleur = couleurDe(types.Glu.Couleur)
	local flaque =
		disque(modele, "Flaque", types.Glu.Rayon * 2, 0.15, sol + Vector3.new(0, 0.08, 0), couleur)
	flaque.Material = Enum.Material.Glass
	flaque.Reflectance = 0.25
	flaque.Transparency = 0.1
	modele.PrimaryPart = flaque
	-- Quelques grosses bulles pour l'aspect cartoon.
	for i, decalage in
		{ Vector3.new(1.8, 0, 1), Vector3.new(-2.2, 0, -1.4), Vector3.new(0.4, 0, -2.6) }
	do
		local bulle = partie(
			modele,
			"Bulle" .. i,
			Vector3.one * (0.8 + i * 0.2),
			CFrame.new(sol + decalage + Vector3.new(0, 0.2, 0)),
			couleur:Lerp(Color3.new(1, 1, 1), 0.3)
		)
		bulle.Shape = Enum.PartType.Ball
		bulle.Material = Enum.Material.Neon
	end
end

local function creerFausseGraine(modele: Model, sol: Vector3)
	local couleur = couleurDe(types.FausseGraine.Couleur)
	local corps = partie(
		modele,
		"Corps",
		Vector3.one * TAILLE_GRAINE,
		CFrame.new(sol + Vector3.new(0, TAILLE_GRAINE / 2, 0)),
		couleur
	)
	corps.Shape = Enum.PartType.Ball
	corps.Material = Enum.Material.Neon
	modele.PrimaryPart = corps
	for _, cote in { -1, 1 } do
		local oeil = partie(
			modele,
			"Oeil",
			Vector3.one * 0.6,
			corps.CFrame * CFrame.new(cote * 0.6, 0.4, -TAILLE_GRAINE / 2 + 0.1),
			Color3.new(0.05, 0.05, 0.05)
		)
		oeil.Shape = Enum.PartType.Ball
	end
	local lumiere = Instance.new("PointLight")
	lumiere.Color = couleur
	lumiere.Range = 12
	lumiere.Brightness = 2
	lumiere.Parent = corps

	local nomRarete = Config.Raretes.Noms.Legendaire
	local panneau = Instance.new("BillboardGui")
	panneau.Name = "Panneau"
	panneau.Size = UDim2.fromOffset(160, 40)
	panneau.StudsOffset = Vector3.new(0, TAILLE_GRAINE + 1, 0)
	panneau.MaxDistance = 250
	panneau.Parent = corps
	local texte = Instance.new("TextLabel")
	texte.Size = UDim2.fromScale(1, 1)
	texte.BackgroundTransparency = 1
	texte.Font = Enum.Font.FredokaOne
	texte.TextScaled = true
	texte.TextColor3 = couleur
	texte.TextStrokeTransparency = 0
	texte.TextStrokeColor3 = Color3.new(0, 0, 0)
	texte.Text = nomRarete
	texte.Parent = panneau

	-- Même bouton « Récolter » qu'une vraie créature au sol.
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "Recolter"
	prompt.ActionText = "Récolter"
	prompt.ObjectText = nomRarete
	prompt.HoldDuration = Config.Creatures.DureeRecolte
	prompt.MaxActivationDistance = reglages.DistanceRecolteFausse
	prompt.RequiresLineOfSight = false
	prompt.Parent = corps
	prompt.Triggered:Connect(function(declencheur: Player)
		Pieges.declencherFausse(declencheur, modele)
	end)
end

-- Petit nuage « pouf » quand un piège disparaît.
local function pouf(position: Vector3)
	local nuage = Instance.new("Part")
	nuage.Name = "PoufPiege"
	nuage.Shape = Enum.PartType.Ball
	nuage.Size = Vector3.one * 2
	nuage.Color = Color3.new(1, 1, 1)
	nuage.Anchored = true
	nuage.CanCollide = false
	nuage.CanTouch = false
	nuage.CastShadow = false
	nuage.Position = position
	nuage.Parent = Workspace
	TweenService
		:Create(nuage, TweenInfo.new(DUREE_POUF), { Size = Vector3.one * 7, Transparency = 1 })
		:Play()
	task.delay(DUREE_POUF, function()
		nuage:Destroy()
	end)
end

local function retirer(modele: Model, avecPouf: boolean)
	local info = infos[modele]
	infos[modele] = nil
	if avecPouf and modele.Parent ~= nil then
		pouf(modele:GetPivot().Position + Vector3.new(0, 1, 0))
	end
	modele:Destroy()
	if info then
		majActifs(info.poseur)
	end
end

-- ----------------------------------------------------------------------------
-- Effets visibles

local function supportTete(joueur: any): BasePart?
	local personnage = joueur.Character
	if typeof(personnage) ~= "Instance" then
		return nil
	end
	local support = (personnage :: Instance):FindFirstChild("Head")
		or (personnage :: Instance):FindFirstChild("HumanoidRootPart")
	if support and support:IsA("BasePart") then
		return support
	end
	return nil
end

local function retirerEffets(joueur: any)
	local personnage = joueur.Character
	if typeof(personnage) ~= "Instance" then
		return
	end
	for _, objet in (personnage :: Instance):GetDescendants() do
		if objet.Name == NOM_EFFET or objet.Name == NOM_FILET_TETE then
			objet:Destroy()
		end
	end
end

-- Gros texte comique au-dessus de la tête pendant `duree` secondes.
local function afficherTexte(joueur: any, texte: string, couleur: Color3, duree: number?)
	local supportOuNil = supportTete(joueur)
	if supportOuNil == nil then
		return
	end
	local support = supportOuNil :: BasePart
	local ancien = support:FindFirstChild(NOM_EFFET)
	if ancien then
		ancien:Destroy()
	end
	local effet = Instance.new("BillboardGui")
	effet.Name = NOM_EFFET
	effet.Size = UDim2.fromOffset(260, 70)
	effet.StudsOffset = Vector3.new(0, 4, 0)
	effet.AlwaysOnTop = true
	effet.MaxDistance = 150
	local etiquette = Instance.new("TextLabel")
	etiquette.Size = UDim2.fromScale(1, 1)
	etiquette.BackgroundTransparency = 1
	etiquette.Font = Enum.Font.FredokaOne
	etiquette.TextScaled = true
	etiquette.TextColor3 = couleur
	etiquette.Rotation = -6
	etiquette.Text = texte
	etiquette.Parent = effet
	local trait = Instance.new("UIStroke")
	trait.Thickness = 4
	trait.Color = Color3.new(0, 0, 0)
	trait.Parent = etiquette
	effet.Parent = support
	if duree then
		task.delay(duree, function()
			effet:Destroy()
		end)
	end
end

-- Filet orange au-dessus de la tête de la victime.
local function afficherFiletTete(joueur: any)
	local supportOuNil = supportTete(joueur)
	if supportOuNil == nil then
		return
	end
	local support = supportOuNil :: BasePart
	local filet = Instance.new("Part")
	filet.Name = NOM_FILET_TETE
	filet.Shape = Enum.PartType.Ball
	filet.Size = Vector3.new(4, 4, 4)
	filet.Color = couleurDe(types.Filet.Couleur)
	filet.Material = Enum.Material.ForceField
	filet.CanCollide = false
	filet.CanTouch = false
	filet.CanQuery = false
	filet.Massless = true
	filet.Anchored = false
	filet.CFrame = support.CFrame
	local soudure = Instance.new("WeldConstraint")
	soudure.Part0 = filet
	soudure.Part1 = support
	soudure.Parent = filet
	filet.Parent = support
end

-- ----------------------------------------------------------------------------
-- Effets de jeu

local function bloquerSaut(joueur: any, humanoideOuNil: Humanoid?)
	if humanoideOuNil == nil or sauts[joueur] ~= nil then
		return
	end
	local humanoide = humanoideOuNil :: Humanoid
	sauts[joueur] = {
		useJumpPower = humanoide.UseJumpPower,
		jumpPower = humanoide.JumpPower,
		jumpHeight = humanoide.JumpHeight,
	}
	humanoide.JumpPower = 0
	humanoide.JumpHeight = 0
end

local function restaurerSaut(joueur: any)
	local saut = sauts[joueur]
	sauts[joueur] = nil
	if saut == nil then
		return
	end
	local _, humanoide = racineEtHumanoide(joueur)
	if humanoide then
		humanoide.JumpPower = saut.jumpPower
		humanoide.JumpHeight = saut.jumpHeight
	end
end

-- Immobilise la victime `duree` secondes (la créature portée est gardée).
local function immobiliser(joueur: any, duree: number, instant: number)
	connus[joueur] = true
	local fin = instant + duree
	immobileJusqua[joueur] = fin
	joueur:SetAttribute("ImmobileJusqua", fin)
	local _, humanoide = racineEtHumanoide(joueur)
	bloquerSaut(joueur, humanoide)
	Entrainement.appliquerVitesse(joueur)
end

local function liberer(joueur: any, instant: number)
	immobileJusqua[joueur] = nil
	joueur:SetAttribute("ImmobileJusqua", nil)
	local finProtection = instant + reglages.DureeProtection
	protegeJusqua[joueur] = math.max(protegeJusqua[joueur] or finProtection, finProtection)
	joueur:SetAttribute("ProtegePiegeJusqua", protegeJusqua[joueur])
	restaurerSaut(joueur)
	local support = supportTete(joueur)
	local filet = support and support:FindFirstChild(NOM_FILET_TETE)
	if filet then
		filet:Destroy()
	end
	Entrainement.appliquerVitesse(joueur)
end

local function decoller(joueur: any, instant: number)
	englues[joueur] = nil
	joueur:SetAttribute("Englue", nil)
	local finProtection = instant + reglages.DureeProtection
	protegeJusqua[joueur] = math.max(protegeJusqua[joueur] or finProtection, finProtection)
	joueur:SetAttribute("ProtegePiegeJusqua", protegeJusqua[joueur])
	Entrainement.appliquerVitesse(joueur)
end

local function peutAffecter(joueur: any, info: Info, instant: number): (boolean, string?)
	return Piege.peutAffecter({
		memePoseur = joueur.UserId == info.poseurId,
		vivante = estVivant(joueur),
		maintenant = instant,
		protegeeJusqua = protegeJusqua[joueur],
		immobileJusqua = immobileJusqua[joueur],
	})
end

local function nomDe(joueur: any): string
	local nom = joueur.Name
	return if type(nom) == "string" then nom else "Quelqu'un"
end

-- ----------------------------------------------------------------------------
-- Pose

local function distancePlusProche(position: Vector3): number?
	local meilleure: number? = nil
	local dossier = Pieges.dossier()
	for modele in infos do
		if modele.Parent == dossier then
			local d = horizontale(modele:GetPivot().Position, position)
			if meilleure == nil or d < (meilleure :: number) then
				meilleure = d
			end
		end
	end
	return meilleure
end

local MESSAGES_REFUS: { [string]: string } = {
	pieces = "Pas assez de pièces !",
	zone = "Pas dans une base !",
	limite = "Trop de pièges !",
	delai = "Patiente un peu…",
	ecart = "Trop près d'un autre piège !",
}

-- Pose un piège sous le joueur. Renvoie le modèle, ou nil si refusé.
function Pieges.poser(joueur: any, typePiege: any, maintenant: number?): Model?
	local instant = instantDe(maintenant)
	connus[joueur] = true
	local racine = racineEtHumanoide(joueur)
	local position = if racine then racine.Position else Vector3.new(0 / 0, 0, 0 / 0)
	local sol = Vector3.new(position.X, 0, position.Z)

	local ok, raison = Piege.verifierPose({
		typePiege = typePiege,
		vivant = estVivant(joueur),
		immobilise = immobileJusqua[joueur] ~= nil and instant < immobileJusqua[joueur],
		pieces = joueur:GetAttribute("Pieces"),
		actifs = Pieges.actifsDe(joueur),
		maintenant = instant,
		pretA = pretA[joueur],
		position = { X = position.X, Y = position.Y, Z = position.Z },
		dansUneBase = Bases.proprietaireDeBaseOu(joueur) ~= nil,
		distancePlusProche = if racine then distancePlusProche(sol) else nil,
	})
	if not ok then
		local texte = MESSAGES_REFUS[raison :: string]
		if texte then
			envoyerMessage(joueur, texte)
		end
		return nil
	end

	local nom = typePiege :: string
	local pieces = joueur:GetAttribute("Pieces") :: number
	joueur:SetAttribute("Pieces", pieces - types[nom].Prix)
	pretA[joueur] = instant + reglages.DelaiPose
	joueur:SetAttribute("PiegePretA", instant + reglages.DelaiPose)

	local modele = Instance.new("Model")
	if nom == "Filet" then
		modele.Name = "Filet"
		creerFilet(modele, sol)
	elseif nom == "Glu" then
		modele.Name = "Glu"
		creerGlu(modele, sol)
	else
		modele.Name = "Creature" -- se fait passer pour une vraie créature
		creerFausseGraine(modele, sol)
	end
	modele:SetAttribute("Type", nom)
	modele:SetAttribute("PoseA", instant)
	modele:SetAttribute("PoseurId", joueur.UserId)
	infos[modele] = {
		poseur = joueur,
		poseurId = joueur.UserId,
		typePiege = nom,
		poseA = instant,
	}
	modele.Parent = Pieges.dossier()
	majActifs(joueur)
	envoyerMessage(joueur, "Piège posé ! Hé hé hé…")
	return modele
end

-- Gestionnaire de PoserPiege : seul le type est lu, tout le reste est ignoré.
-- selene: allow(unused_variable)
function Pieges.traiterRequete(joueur: any, typePiege: any, ...: any): Model?
	local horloge = os.clock()
	local derniere = derniereRequete[joueur]
	if derniere ~= nil and horloge - derniere < reglages.IntervalleMinRequetes then
		return nil
	end
	derniereRequete[joueur] = horloge
	return Pieges.poser(joueur, typePiege)
end

-- ----------------------------------------------------------------------------
-- Déclenchement

-- Un joueur « récolte » une fausse graine. Renvoie true si elle l'a piégé.
function Pieges.declencherFausse(joueur: any, piege: any, maintenant: number?): boolean
	local instant = instantDe(maintenant)
	if typeof(piege) ~= "Instance" or not piege:IsA("Model") then
		return false
	end
	local info = infos[piege :: Model]
	if info == nil or info.typePiege ~= "FausseGraine" or piege.Parent ~= Pieges.dossier() then
		return false
	end
	connus[joueur] = true
	local racineOuNil = racineEtHumanoide(joueur)
	if racineOuNil == nil then
		return false
	end
	local racine = racineOuNil :: BasePart
	local distance = (racine.Position - (piege :: Model):GetPivot().Position).Magnitude
	if not Piege.dansRayon(distance, reglages.DistanceRecolteFausse) then
		return false
	end
	local ok, raison = peutAffecter(joueur, info, instant)
	if not ok then
		if raison == "poseur" then
			envoyerMessage(joueur, "C'est ta propre fausse graine !")
		end
		return false
	end
	retirer(piege :: Model, true)
	immobiliser(joueur, types.FausseGraine.Duree, instant)
	afficherTexte(
		joueur,
		"HA HA ! FAUSSE GRAINE !",
		couleurDe(types.FausseGraine.Couleur),
		types.FausseGraine.Duree
	)
	envoyerMessage(joueur, "Oups, c'était une fausse graine !")
	envoyerMessage(info.poseur, `{nomDe(joueur)} a mordu à l'hameçon !`)
	return true
end

-- Joueurs examinés par la boucle : vrais joueurs, joueurs avec une base et
-- joueurs déjà vus par les pièges.
local function joueursSuivis(): { any }
	local vus: { [any]: boolean } = {}
	local liste = {}
	local function ajouter(joueur: any)
		if not vus[joueur] then
			vus[joueur] = true
			table.insert(liste, joueur)
		end
	end
	for _, joueur in Players:GetPlayers() do
		ajouter(joueur)
	end
	for _, joueur in Bases.joueurs() do
		ajouter(joueur)
	end
	for joueur in connus do
		ajouter(joueur)
	end
	return liste
end

-- Un passage de la boucle : expiration, fin d'effets, filets et glu.
function Pieges.pas(maintenant: number?)
	local instant = instantDe(maintenant)
	local dossier = Pieges.dossier()

	-- Expiration (et oubli des modèles détruits ailleurs).
	for modele, info in infos do
		if modele.Parent ~= dossier then
			infos[modele] = nil
			majActifs(info.poseur)
		elseif Piege.estExpire(info.poseA, instant) then
			retirer(modele, true)
		end
	end

	for _, joueur in joueursSuivis() do
		-- Fin d'immobilisation.
		local fin = immobileJusqua[joueur]
		if fin ~= nil and instant >= fin then
			liberer(joueur, instant)
		end

		local racine = racineEtHumanoide(joueur)
		local dansGlu = false
		if racine then
			local position = racine.Position
			for modele, info in infos do
				if modele.Parent == dossier then
					local distance = horizontale(position, modele:GetPivot().Position)
					if
						info.typePiege == "Filet"
						and Piege.dansRayon(distance, reglages.RayonDeclenchement)
					then
						if peutAffecter(joueur, info, instant) then
							retirer(modele, false)
							immobiliser(joueur, types.Filet.Duree, instant)
							afficherTexte(
								joueur,
								"PRIS AU FILET !",
								couleurDe(types.Filet.Couleur),
								types.Filet.Duree
							)
							afficherFiletTete(joueur)
							envoyerMessage(joueur, "Gigote, gigote ! Tu es pris au filet !")
							envoyerMessage(info.poseur, `Ton filet a attrapé {nomDe(joueur)} !`)
						end
					elseif
						info.typePiege == "Glu" and Piege.dansRayon(distance, types.Glu.Rayon)
					then
						if englues[joueur] or peutAffecter(joueur, info, instant) then
							dansGlu = true
						end
					end
				end
			end
		end

		if dansGlu and not englues[joueur] then
			connus[joueur] = true
			englues[joueur] = true
			joueur:SetAttribute("Englue", true)
			Entrainement.appliquerVitesse(joueur)
			afficherTexte(joueur, "SPLOTCH !", couleurDe(types.Glu.Couleur), 1.5)
			envoyerMessage(joueur, "Beurk ! Tu colles !")
		elseif not dansGlu and englues[joueur] then
			decoller(joueur, instant)
		end
	end
end

-- Départ du joueur (ou nettoyage de test) : ses pièges, délais, protections
-- et effets sont oubliés. Les pièges ne sont pas sauvegardés.
function Pieges.nettoyer(joueur: any)
	for modele, info in infos do
		if info.poseur == joueur then
			infos[modele] = nil
			modele:Destroy()
		end
	end
	local avaitEffet = immobileJusqua[joueur] ~= nil or englues[joueur] ~= nil
	restaurerSaut(joueur)
	pretA[joueur] = nil
	protegeJusqua[joueur] = nil
	immobileJusqua[joueur] = nil
	englues[joueur] = nil
	derniereRequete[joueur] = nil
	connus[joueur] = nil
	joueur:SetAttribute("ImmobileJusqua", nil)
	joueur:SetAttribute("Englue", nil)
	joueur:SetAttribute("ProtegePiegeJusqua", nil)
	joueur:SetAttribute("PiegesActifs", nil)
	joueur:SetAttribute("PiegePretA", nil)
	retirerEffets(joueur)
	if avaitEffet then
		Entrainement.appliquerVitesse(joueur)
	end
end

-- Dossier des pièges et boucle serveur.
function Pieges.demarrer()
	Pieges.dossier()
	if demarre then
		return
	end
	demarre = true
	task.spawn(function()
		while true do
			task.wait(reglages.IntervalleBoucle)
			Pieges.pas()
		end
	end)
end

return Pieges
