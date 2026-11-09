--!strict
-- Effets des espèces en petits blocs (affichage seulement, dans le style du
-- jeu) : ambiance de leur biome (pollen, flocons, braises, bulles…) et effets
-- signature (flammes, vapeur, notes, Zzz…), décrits dans Shared.Effets.
-- Les grosses tailles émettent plus, plus gros ; les Géantes et plus ont une
-- onde au sol, et une Colossale ou une Titan fait une onde de choc en sortant
-- de terre.
-- Économie : seuls les modèles les plus proches de la caméra émettent, avec
-- un plafond de particules à l'écran.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Biomes = require(Shared:WaitForChild("Biomes"))
local Effets = require(Shared:WaitForChild("Effets"))
local Style = require(Shared:WaitForChild("Style"))

local EffetsEspeces = {}

local DISTANCE_MAX = 80 -- studs
local MODELES_MAX = 14 -- modèles qui émettent en même temps
local PARTICULES_MAX = 180
local TAILLES_ONDE = { Geante = true, Colossale = true, Titan = true }
local TAILLES_CHOC = { Colossale = true, Titan = true }
local INTERVALLE_ONDE = 3 -- secondes entre deux ondes au sol

type Emission = { signature: any, famille: any, prochaine: number, source: BasePart? }
type Suivi = {
	modele: Model,
	echelle: number, -- studs par unité du modèle
	taille: string,
	emissions: { Emission },
	prochaineOnde: number,
	couleur: Color3,
}

local suivis: { [Model]: Suivi } = {}
local actifs = 0
local hasard = Random.new()
local dossier: Folder? = nil

local function dossierEffets(): Folder
	if dossier and dossier.Parent then
		return dossier
	end
	local f = Instance.new("Folder")
	f.Name = "EffetsLocaux"
	f.Parent = Workspace
	dossier = f
	return f
end

local function couleur(rgb: { number }): Color3
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

local function hasardEntre(a: number, b: number): number
	return a + (b - a) * hasard:NextNumber()
end

-- Première pièce dont le nom commence par `prefixe` (hors bandes d'ombrage).
local function piece(modele: Model, prefixeOuNil: string?): BasePart?
	if prefixeOuNil == nil then
		return nil
	end
	local prefixe = prefixeOuNil :: string
	for _, p in modele:GetChildren() do
		if
			p:IsA("BasePart")
			and string.sub(p.Name, 1, #prefixe) == prefixe
			and not string.find(p.Name, "Ombre$")
			and not string.find(p.Name, "Lumiere$")
		then
			return p
		end
	end
	return nil
end

local function biomeDe(nom: string): string?
	local numero = Biomes.indexEspece(nom)
	return if numero then Biomes.Liste[numero].Id else nil
end

local function suivre(objet: Instance)
	if not objet:IsA("Model") or suivis[objet] ~= nil then
		return
	end
	local attribut = objet:GetAttribute("Espece")
	if type(attribut) ~= "string" then
		return
	end
	local nom = attribut :: string
	local modele = objet :: Model
	local _, dimensions = modele:GetBoundingBox()
	local tailleAttr = modele:GetAttribute("Taille")
	local taille = if type(tailleAttr) == "string" then tailleAttr else "Normale"
	local rarete = modele:GetAttribute("Rarete")
	local emissions: { Emission } = {}
	local maintenant = os.clock()
	for _, s in Effets.de(nom, biomeDe(nom)) do
		local famille = (Effets.Familles :: any)[s.Famille]
		if famille then
			table.insert(emissions, {
				signature = s,
				famille = famille,
				prochaine = maintenant + hasard:NextNumber() * famille.Intervalle,
				source = piece(modele, s.Source),
			})
		end
	end
	local suivi: Suivi = {
		modele = modele,
		echelle = math.max(dimensions.Y, 1),
		taille = taille,
		emissions = emissions,
		prochaineOnde = maintenant + hasard:NextNumber() * INTERVALLE_ONDE,
		couleur = if type(rarete) == "string"
			then couleur(Style.couleurRarete(rarete))
			else Color3.fromRGB(255, 255, 255),
	}
	suivis[modele] = suivi
	modele.Destroying:Connect(function()
		suivis[modele] = nil
	end)
	-- Arrivée fracassante des très grosses créatures, quand elles sortent de
	-- terre dans les Terres Sauvages (pas à chaque réaffichage d'une base).
	local parent = modele.Parent
	local sauvage = parent ~= nil and parent.Name == "Creatures"
	if TAILLES_CHOC[taille] and sauvage and modele:GetAttribute("Monstre") ~= true then
		task.delay(0.1, function()
			if modele.Parent then
				EffetsEspeces.choc(modele, suivi)
			end
		end)
	end
end

local function lancer(p: BasePart, cible: CFrame, duree: number, fin: { [string]: any })
	actifs += 1
	local info = TweenInfo.new(duree, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local proprietes: { [string]: any } = { CFrame = cible }
	for cle, valeur in fin do
		proprietes[cle] = valeur
	end
	TweenService:Create(p, info, proprietes):Play()
	task.delay(duree, function()
		p:Destroy()
		actifs -= 1
	end)
end

local function particule(s: Suivi, e: Emission)
	if actifs >= PARTICULES_MAX then
		return
	end
	local f = e.famille
	local facteur = (Effets.ParTaille :: any)[s.taille] or 1
	local u = s.echelle -- studs par unité
	local depart: Vector3
	local cadre, dimensions = s.modele:GetBoundingBox()
	if e.source and e.source.Parent then
		depart = (e.source :: BasePart).Position
	elseif f.AuSol then
		depart = cadre.Position - Vector3.new(0, dimensions.Y / 2 - 0.1, 0)
	else
		depart = cadre.Position + Vector3.new(0, dimensions.Y / 2 + (f.AuDessus or 0) * u, 0)
	end
	local ecart = Vector3.new(hasardEntre(-0.3, 0.3), 0, hasardEntre(-0.3, 0.3)) * dimensions.X
	if e.source then
		ecart *= 0.15
	end
	depart += ecart
	local derive = Vector3.new(hasardEntre(-1, 1), 0, hasardEntre(-1, 1)) * f.Derive
	local vitesse = Vector3.new(f.Vitesse[1], f.Vitesse[2], f.Vitesse[3]) + derive
	local arrivee = depart + vitesse * f.Duree * u
	local cote = hasardEntre(f.Taille[1], f.Taille[2]) * u * math.sqrt(facteur)
	local teinte = couleur(f.Couleurs[hasard:NextInteger(1, #f.Couleurs)])

	local p = Instance.new("Part")
	p.Name = "Particule"
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Color = teinte
	p.Material = if f.Neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
	p.Transparency = f.Transparence or 0
	if f.Forme == "Boule" then
		p.Shape = Enum.PartType.Ball
		p.Size = Vector3.one * cote
	elseif f.Forme == "Plat" then
		p.Size = Vector3.new(cote, cote * 0.25, cote * 0.7)
	elseif f.Forme == "Texte" then
		p.Size = Vector3.one * 0.1
		p.Transparency = 1
		local panneau = Instance.new("BillboardGui")
		panneau.Size = UDim2.fromScale(cote * 2, cote * 2)
		panneau.LightInfluence = 0
		panneau.Parent = p
		local texte = Instance.new("TextLabel")
		texte.Size = UDim2.fromScale(1, 1)
		texte.BackgroundTransparency = 1
		texte.Text = f.Texte or "?"
		texte.TextScaled = true
		texte.TextColor3 = teinte
		texte.TextStrokeTransparency = 0.3
		texte.Font = Enum.Font.FredokaOne
		texte.Parent = panneau
		TweenService
			:Create(
				texte,
				TweenInfo.new(f.Duree),
				{ TextTransparency = 1, TextStrokeTransparency = 1 }
			)
			:Play()
	else
		p.Size = Vector3.one * cote
	end
	local rotation = if f.Tourne
		then CFrame.Angles(hasardEntre(0, 6), hasardEntre(0, 6), hasardEntre(0, 6))
		else CFrame.new()
	p.CFrame = CFrame.new(depart) * rotation
	p.Parent = dossierEffets()
	local fin: { [string]: any } = {}
	if f.Forme ~= "Texte" then
		fin.Transparency = 1
		fin.Size = p.Size * (f.Grossit or 0.4)
	end
	local tourne = if f.Tourne
		then CFrame.Angles(hasardEntre(-3, 3), hasardEntre(-3, 3), 0)
		else CFrame.new()
	lancer(p, CFrame.new(arrivee) * rotation * tourne, f.Duree, fin)
end

-- Onde au sol (anneau plat qui s'élargit), à la couleur de la rareté.
local function onde(s: Suivi, force: number)
	if actifs >= PARTICULES_MAX then
		return
	end
	local cadre, dimensions = s.modele:GetBoundingBox()
	local sol = cadre.Position - Vector3.new(0, dimensions.Y / 2 - 0.05, 0)
	local anneau = Instance.new("Part")
	anneau.Name = "Onde"
	anneau.Shape = Enum.PartType.Cylinder
	anneau.Anchored = true
	anneau.CanCollide = false
	anneau.CanQuery = false
	anneau.CanTouch = false
	anneau.CastShadow = false
	anneau.Material = Enum.Material.Neon
	anneau.Color = s.couleur
	anneau.Transparency = 0.35
	local largeur = math.max(dimensions.X, dimensions.Z)
	anneau.Size = Vector3.new(0.12, largeur * 0.6, largeur * 0.6)
	anneau.CFrame = CFrame.new(sol) * CFrame.Angles(0, 0, math.rad(90))
	anneau.Parent = dossierEffets()
	lancer(anneau, anneau.CFrame, 0.9, {
		Size = Vector3.new(0.05, largeur * force, largeur * force),
		Transparency = 1,
	})
end

-- Onde de choc d'arrivée : anneau large et gerbe de poussière.
function EffetsEspeces.choc(modele: Model, s: Suivi)
	local force = if s.taille == "Titan" then 4 else 3
	onde(s, force)
	local cadre, dimensions = modele:GetBoundingBox()
	local sol = cadre.Position - Vector3.new(0, dimensions.Y / 2 - 0.1, 0)
	local poussiere = (Effets.Familles :: any).Poussiere
	for _ = 1, if s.taille == "Titan" then 16 else 10 do
		if actifs >= PARTICULES_MAX then
			break
		end
		local p = Instance.new("Part")
		p.Name = "Poussiere"
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Color = couleur(poussiere.Couleurs[hasard:NextInteger(1, #poussiere.Couleurs)])
		p.Size = Vector3.one * hasardEntre(0.3, 0.7)
		p.CFrame = CFrame.new(sol)
		p.Parent = dossierEffets()
		local angle = hasardEntre(0, math.pi * 2)
		local portee = math.max(dimensions.X, dimensions.Z) * hasardEntre(0.8, 1.6)
		local cible = sol
			+ Vector3.new(math.cos(angle) * portee, hasardEntre(0.5, 2), math.sin(angle) * portee)
		lancer(p, CFrame.new(cible) * CFrame.Angles(hasardEntre(0, 6), hasardEntre(0, 6), 0), 0.8, {
			Transparency = 1,
			Size = p.Size * 0.3,
		})
	end
end

local function pas()
	local camera = Workspace.CurrentCamera
	if camera == nil then
		return
	end
	local oeil = camera.CFrame.Position
	local maintenant = os.clock()
	local proches: { { s: Suivi, d: number } } = {}
	for modele, s in suivis do
		if modele.Parent == nil then
			suivis[modele] = nil
			continue
		end
		local corpsOuNil = modele.PrimaryPart
		if corpsOuNil == nil or not (corpsOuNil :: BasePart).Anchored then
			continue -- portée par un joueur : pas d'effets
		end
		local d = ((corpsOuNil :: BasePart).Position - oeil).Magnitude
		if d <= DISTANCE_MAX then
			table.insert(proches, { s = s, d = d })
		end
	end
	table.sort(proches, function(a, b)
		return a.d < b.d
	end)
	for i = 1, math.min(#proches, MODELES_MAX) do
		local s = proches[i].s
		for _, e in s.emissions do
			if maintenant >= e.prochaine then
				e.prochaine = maintenant
					+ Effets.intervalle(e.signature, s.taille) * hasardEntre(0.7, 1.3)
				particule(s, e)
			end
		end
		if TAILLES_ONDE[s.taille] and maintenant >= s.prochaineOnde then
			s.prochaineOnde = maintenant + INTERVALLE_ONDE
			onde(s, if s.taille == "Titan" then 2.6 else 1.8)
		end
	end
end

function EffetsEspeces.demarrer()
	for _, objet in Workspace:GetDescendants() do
		suivre(objet)
	end
	Workspace.DescendantAdded:Connect(function(objet)
		if objet:IsA("Model") then
			-- Attendre les attributs et la fin de la pousse.
			task.delay(0.3, function()
				if objet.Parent == nil then
					return
				end
				if objet:GetAttribute("EnCroissance") == true then
					local connexion: RBXScriptConnection
					connexion = objet:GetAttributeChangedSignal("EnCroissance"):Connect(function()
						if objet:GetAttribute("EnCroissance") ~= true then
							connexion:Disconnect()
							suivre(objet)
						end
					end)
				else
					suivre(objet)
				end
			end)
		end
	end)
	RunService.Heartbeat:Connect(pas)
end

return EffetsEspeces
