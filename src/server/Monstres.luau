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
local Bestiaire = require(ReplicatedStorage.Shared.Bestiaire)
local Biomes = require(ReplicatedStorage.Shared.Biomes)
local Monstre = require(ReplicatedStorage.Shared.Monstre)
local Projection = require(ReplicatedStorage.Shared.Projection)
local Bases = require(script.Parent.Bases)
local Modeleur = require(script.Parent.Modeleur)
local Portage = require(script.Parent.Portage)

type Etat = {
	zone: string,
	biome: number,
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

-- Point aléatoire de la bande d'une zone du biome n, au niveau du sol.
local function pointAleatoire(zone: string, biome: number): Vector3
	local zMin, zMax = Monstre.bandeZone(zone, biome)
	local p = Monstre.limiter({
		X = aleatoire:NextNumber(-580, 580),
		Y = hauteurSol(zone),
		Z = aleatoire:NextNumber(zMin, zMax),
	}, zone, biome)
	return Vector3.new(p.X, p.Y, p.Z)
end

-- ----------------------------------------------------------------------------
-- Apparence : une espèce en blocs du Bestiaire (deux par zone), construite
-- autour d'un Corps invisible de la taille de la zone (la portée de coup et la
-- hauteur au sol ne changent pas).

local function appliquerYeux(modele: Model, nuit: boolean)
	for _, objet in modele:GetChildren() do
		if objet:IsA("BasePart") and string.sub(objet.Name, 1, 4) == "Oeil" then
			objet.Material = if nuit then Enum.Material.Neon else Enum.Material.SmoothPlastic
		end
	end
end

local function creerModele(zone: string, position: Vector3, biome: number): Model
	local r = Monstre.reglagesZone(zone)
	local t = r.Taille
	local modele = Instance.new("Model")
	modele.Name = "Monstre"

	-- Construit à l'origine, face vers -Z (LookVector), puis déplacé.
	local corps = Instance.new("Part")
	corps.Name = "Corps"
	corps.Shape = Enum.PartType.Ball
	corps.Size = Vector3.one * t
	corps.Anchored = true
	corps.CanCollide = false
	corps.CanTouch = false
	corps.CFrame = CFrame.new()
	corps.Parent = modele
	modele.PrimaryPart = corps
	local espece = Bestiaire.especeMonstre(zone, aleatoire:NextNumber(), biome)
	Modeleur.construire(modele, corps, espece, t, couleurDe(r.Couleur))

	modele:SetAttribute("Monstre", true)
	modele:SetAttribute("Zone", zone)
	modele:SetAttribute("Biome", biome)
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

-- Onomatopée colorée (« BOING ! », « FIUUUU ! »…) au-dessus du joueur frappé.
local function effetPaf(joueur: any, mot: string, rgb: { number })
	local personnage = joueur.Character
	if typeof(personnage) ~= "Instance" then
		return
	end
	local trouve = (personnage :: Instance):FindFirstChild("Head")
		or (personnage :: Instance):FindFirstChild("HumanoidRootPart")
	if trouve == nil or not trouve:IsA("BasePart") then
		return
	end
	local support = trouve :: BasePart
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
	texte.TextColor3 = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
	texte.Rotation = aleatoire:NextNumber(-14, 14)
	texte.Text = mot
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

-- Ballons colorés accrochés au-dessus de la tête (sans collision ni masse),
-- qui éclatent au bout de `duree` secondes.
local COULEURS_BALLONS = {
	Color3.fromRGB(255, 90, 120),
	Color3.fromRGB(90, 200, 255),
	Color3.fromRGB(255, 220, 60),
}
local function ballons(racine: BasePart, duree: number)
	local grappe = Instance.new("Model")
	grappe.Name = "BallonsMonstre"
	for i, couleur in COULEURS_BALLONS do
		local decalage = Vector3.new((i - 2) * 1.6, 5 + (i % 2) * 0.8, 0)
		local ballon = Instance.new("Part")
		ballon.Name = "Ballon"
		ballon.Shape = Enum.PartType.Ball
		ballon.Size = Vector3.one * 2.2
		ballon.Color = couleur
		ballon.Material = Enum.Material.SmoothPlastic
		ballon.CanCollide = false
		ballon.CanQuery = false
		ballon.CanTouch = false
		ballon.Massless = true
		ballon.CFrame = racine.CFrame + decalage
		ballon.Parent = grappe
		local fil = Instance.new("Part")
		fil.Name = "Fil"
		fil.Size = Vector3.new(0.08, decalage.Y - 1, 0.08)
		fil.Color = Color3.new(1, 1, 1)
		fil.CanCollide = false
		fil.CanQuery = false
		fil.CanTouch = false
		fil.Massless = true
		fil.CFrame = racine.CFrame + Vector3.new(decalage.X / 2, decalage.Y / 2, 0)
		fil.Parent = grappe
		for _, piece in { ballon, fil } do
			local soudure = Instance.new("WeldConstraint")
			soudure.Part0 = racine
			soudure.Part1 = piece
			soudure.Parent = piece
		end
	end
	grappe.Parent = racine.Parent
	task.delay(duree, function()
		if grappe.Parent then
			pouf(grappe:GetPivot().Position)
		end
		grappe:Destroy()
	end)
end

-- Traînée arc-en-ciel derrière le joueur projeté.
local function trainee(racine: BasePart, duree: number)
	local haut = Instance.new("Attachment")
	haut.Name = "TraineeHaut"
	haut.Position = Vector3.new(0, 1, 0)
	haut.Parent = racine
	local bas = Instance.new("Attachment")
	bas.Name = "TraineeBas"
	bas.Position = Vector3.new(0, -1, 0)
	bas.Parent = racine
	local trace = Instance.new("Trail")
	trace.Name = "TraineeMonstre"
	trace.Attachment0 = haut
	trace.Attachment1 = bas
	trace.Lifetime = 0.5
	trace.LightEmission = 0.6
	trace.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 90, 90)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 230, 80)),
		ColorSequenceKeypoint.new(0.66, Color3.fromRGB(90, 220, 140)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 150, 255)),
	})
	trace.Transparency = NumberSequence.new(0.2, 1)
	trace.Parent = racine
	task.delay(duree, function()
		trace:Destroy()
		haut:Destroy()
		bas:Destroy()
	end)
end

-- Propulse le joueur loin du monstre et l'étourdit (PlatformStand), avec un
-- style comique tiré au hasard (Shared.Projection) : Boing, Toupie, Fusée ou
-- Ballon. Les forces sont des contraintes créées par le serveur (répliquées
-- au client qui simule son personnage). Renvoie le style.
local etourdis: { [Humanoid]: number } = {}
local function propulser(
	joueur: any,
	racine: BasePart,
	humanoide: Humanoid,
	depuis: Vector3,
	zone: string,
	biome: number
): Projection.Style
	local style = Projection.tirer(aleatoire:NextNumber())
	local baseH, baseV, baseDuree = Monstre.recul(zone, biome)
	local horizontal, vertical = Projection.poussee(style, baseH, baseV)
	local duree = Projection.duree(style, baseDuree)
	local ecart = racine.Position - depuis
	local direction = Vector3.new(ecart.X, 0, ecart.Z)
	direction = if direction.Magnitude > 0.01 then direction.Unit else Vector3.new(0, 0, 1)

	local attache = Instance.new("Attachment")
	attache.Name = "AttachePoussee"
	attache.Parent = racine
	local poussee = Instance.new("LinearVelocity")
	poussee.Name = "PousseeMonstre"
	poussee.Attachment0 = attache
	poussee.RelativeTo = Enum.ActuatorRelativeTo.World
	poussee.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	poussee.MaxForce = math.huge
	poussee.VectorVelocity = direction * horizontal + Vector3.new(0, vertical, 0)
	poussee.Parent = racine
	task.delay(reglages.DureePoussee, function()
		poussee:Destroy()
	end)

	-- Toupie : le joueur tourne sur lui-même pendant tout l'étourdissement.
	if style.Tourne then
		local rotation = Instance.new("AngularVelocity")
		rotation.Name = "ToupieMonstre"
		rotation.Attachment0 = attache
		rotation.RelativeTo = Enum.ActuatorRelativeTo.World
		rotation.MaxTorque = math.huge
		rotation.AngularVelocity = Vector3.new(0, style.Tourne, 0)
		rotation.Parent = racine
		task.delay(duree, function()
			rotation:Destroy()
		end)
	end
	-- Ballon : une force annule presque la gravité, le joueur flotte puis POP.
	if style.Ballon then
		local portance = Instance.new("VectorForce")
		portance.Name = "BallonMonstre"
		portance.Attachment0 = attache
		portance.RelativeTo = Enum.ActuatorRelativeTo.World
		portance.ApplyAtCenterOfMass = true
		portance.Force = Vector3.new(0, racine.AssemblyMass * Workspace.Gravity * 1.08, 0)
		portance.Parent = racine
		ballons(racine, style.Ballon)
		task.delay(style.Ballon, function()
			portance:Destroy()
		end)
	end
	task.delay(duree, function()
		attache:Destroy()
	end)
	trainee(racine, math.min(duree, 1.5))

	local fin = Workspace:GetServerTimeNow() + duree
	etourdis[humanoide] = fin
	humanoide.PlatformStand = true
	joueur:SetAttribute("Projection", style.Id)
	joueur:SetAttribute("EtourdiJusqua", fin)
	task.delay(duree, function()
		if etourdis[humanoide] == fin then
			etourdis[humanoide] = nil
			if humanoide.Parent then
				humanoide.PlatformStand = false
			end
		end
	end)
	return style
end

-- ----------------------------------------------------------------------------
-- Apparition et disparition

local function apparaitre(zone: string, biome: number): Model
	local position = pointAleatoire(zone, biome)
	local modele = creerModele(zone, position, biome)
	etats[modele] = {
		zone = zone,
		biome = biome,
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

-- Monstres vivants d'une zone d'un biome (oublie ceux détruits ailleurs).
local function monstresDe(zone: string, biome: number): { Model }
	local dossier = Monstres.dossier()
	local liste = {}
	for modele, etat in etats do
		if modele.Parent ~= dossier then
			etats[modele] = nil
		elseif etat.zone == zone and etat.biome == biome then
			table.insert(liste, modele)
		end
	end
	return liste
end

-- Biomes « actifs » : le premier (toujours) et ceux où se trouve au moins un
-- joueur. Les autres n'ont aucun monstre (anti-lag).
local function biomesActifs(): { [number]: boolean }
	local actifs = { [1] = true }
	for _, joueur in Players:GetPlayers() do
		local racine = racineEtHumanoide(joueur)
		if racine then
			local p = racine.Position
			actifs[Monstre.biomeDe({ X = p.X, Y = p.Y, Z = p.Z })] = true
		end
	end
	return actifs
end

-- Complète (ou réduit) chaque zone de chaque biome actif jusqu'au nombre voulu
-- pour la phase de `maintenant` : NombreJour le jour, NombreNuit la nuit
-- (vague). Les biomes sans joueur sont vidés.
function Monstres.completer(maintenant: number?)
	local nuit = Monstre.phase(instantDe(maintenant)) == "Nuit"
	local actifs = biomesActifs()
	for biome = 1, Biomes.nombre() do
		for _, z in Config.Lancer.Zones do
			local zone = z.Nom
			local liste = monstresDe(zone, biome)
			local voulu = if actifs[biome] then Monstre.nombreVoulu(zone, nuit) else 0
			for _ = #liste + 1, voulu do
				apparaitre(zone, biome)
			end
			for i = #liste, voulu + 1, -1 do
				retirer(liste[i])
			end
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

	-- Aucun dégât : la créature tombe, puis le joueur est propulsé et étourdi.
	local creature: Model? = nil
	if Portage.porte(joueur) then
		creature = Portage.lacher(joueur, position, instant)
	end
	local style = propulser(
		joueur,
		racine :: BasePart,
		humanoide :: Humanoid,
		position,
		etat.zone,
		etat.biome
	)

	protection[joueur] = instant + reglages.DureeProtection
	joueur:SetAttribute("ProtegeMonstreJusqua", instant + reglages.DureeProtection)
	etat.pretA = instant + Monstre.reglagesZone(etat.zone).Recharge

	effetPaf(joueur, Projection.mot(style, aleatoire:NextNumber()), style.Couleur)
	-- Pour l'animation de coup côté client (affichage seulement).
	if typeof(monstre) == "Instance" then
		monstre:SetAttribute("FrappeA", Workspace:GetServerTimeNow())
	end
	if creature then
		envoyerMessage(joueur, style.Message .. " Tu as lâché ta créature !")
	else
		envoyerMessage(joueur, style.Message)
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
	local vitesse = Monstre.vitesse(etat.zone, etat.biome)
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
			destination = pointAleatoire(etat.zone, etat.biome)
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
	local p = Monstre.limiter({ X = suivant.X, Y = hauteur, Z = suivant.Z }, etat.zone, etat.biome)
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
		local dernierControle = 0
		local derniersBiomes = "1"
		while true do
			task.wait(reglages.IntervalleIA)
			local instant = Workspace:GetServerTimeNow()
			Monstres.pas(instant)
			-- Tombée de la nuit (vague), lever du jour (« pouf »), puis
			-- complément régulier toutes les IntervalleVague secondes.
			-- Un joueur change de biome : on peuple le nouveau, on vide l'ancien.
			local phase = Monstre.phase(instant)
			local cle = ""
			if instant - dernierControle >= 2 then
				dernierControle = instant
				local liste = {}
				for biome in biomesActifs() do
					table.insert(liste, biome)
				end
				table.sort(liste)
				cle = table.concat(liste, ",")
			end
			local biomesChanges = cle ~= "" and cle ~= derniersBiomes
			if biomesChanges then
				derniersBiomes = cle
			end
			if
				phase ~= dernierePhase
				or biomesChanges
				or instant - derniereVague >= reglages.IntervalleVague
			then
				dernierePhase = phase
				derniereVague = instant
				Monstres.completer(instant)
			end
		end
	end)
end

return Monstres
