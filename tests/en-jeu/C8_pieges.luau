local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Forge = require(ReplicatedStorage.Shared.Forge)

-- API serveur selon la maquette issue-13 :
--   Pieges.poser(joueur, type, maintenant?) -> Model? ; Pieges.declencherFausse(joueur, piege, maintenant?) -> boolean
--   Pieges.pas(maintenant?) ; Pieges.traiterRequete(joueur, type, ...) ; Pieges.actifsDe(joueur)
--   Pieges.dossier() -> Workspace.Pieges ; Pieges.nettoyer(joueur)
--   Attributs piège : Type, PoseA, PoseurId ; joueur : Pieces, PiegePretA, PiegesActifs,
--   ImmobileJusqua, Englue, ProtegePiegeJusqua, Porte
local function module(nom: string): any
	local dossier = ServerScriptService:WaitForChild("Server", 5)
	assert(dossier, "dossier Server introuvable")
	local m = dossier:FindFirstChild(nom)
	assert(m and m:IsA("ModuleScript"), "module serveur manquant : " .. nom)
	return require(m)
end

local PIEGES = Config.Pieges
local PRIX = PIEGES.Types
local prochainId = -900

local function fauxJoueur(pieces: number?): any
	prochainId -= 1
	local attributs: { [string]: any } = {
		Force = 0,
		Vitesse = 0,
		ModeForge = "Force",
		SurForge = false,
		Pieces = pieces or 10000,
	}
	local perso = Instance.new("Model")
	perso.Name = "FauxPerso" .. prochainId
	local racine = Instance.new("Part")
	racine.Name = "HumanoidRootPart"
	racine.Size = Vector3.new(2, 2, 1)
	racine.Anchored = true
	racine.Parent = perso
	local tete = Instance.new("Part")
	tete.Name = "Head"
	tete.Size = Vector3.new(2, 1, 1)
	tete.Anchored = true
	tete.Position = racine.Position + Vector3.new(0, 1.5, 0)
	tete.Parent = perso
	local humanoide = Instance.new("Humanoid")
	humanoide.WalkSpeed = Forge.walkSpeedPour(0)
	humanoide.Parent = perso
	perso.PrimaryPart = racine
	perso.Parent = Workspace
	return {
		Name = perso.Name,
		UserId = prochainId,
		Character = perso,
		GetAttribute = function(_, nom: string)
			return attributs[nom]
		end,
		SetAttribute = function(_, nom: string, valeur: any)
			attributs[nom] = valeur
		end,
		GetNetworkPing = function()
			return 0
		end,
	}
end

local function placer(joueur: any, position: Vector3)
	joueur.Character.HumanoidRootPart.CFrame = CFrame.new(position)
end

local function vitesse(joueur: any): number
	return joueur.Character.Humanoid.WalkSpeed
end

local function pose(piege: Model): Vector3
	return piege:GetPivot().Position
end

local function nettoyer(...: any)
	for _, joueur in { ... } do
		module("Pieges").nettoyer(joueur)
		module("Plaquages").nettoyer(joueur)
		for _, c in module("TerresSauvages").dossierCreatures():GetChildren() do
			if c:GetAttribute("Proprietaire") == joueur.UserId then
				c:Destroy()
			end
		end
		module("Bases").liberer(joueur)
		if joueur.Character then
			joueur.Character:Destroy()
		end
	end
end

local function piegesDe(joueur: any): { Instance }
	local liste = {}
	for _, p in module("Pieges").dossier():GetChildren() do
		if p:GetAttribute("PoseurId") == joueur.UserId then
			table.insert(liste, p)
		end
	end
	return liste
end

local ZONE = Vector3.new(0, 10, 500)
local ECART = PIEGES.EcartMin + 4

-- Poseur placé dans les Terres Sauvages (hors de toute base).
local function poseur(pieces: number?): any
	local a = fauxJoueur(pieces)
	module("Bases").creer(a)
	placer(a, ZONE)
	return a
end

local function maintenant(): number
	return Workspace:GetServerTimeNow()
end

-- Pose un piège de type donné à `decalage` studs de ZONE (sur Z), sans délai.
local function poserEn(a: any, typePiege: string, decalage: number, t: number): Model
	placer(a, ZONE + Vector3.new(0, 0, decalage))
	a:SetAttribute("PiegePretA", nil)
	local p = module("Pieges").poser(a, typePiege, t)
	assert(p ~= nil, "pose attendue : " .. typePiege)
	return p
end

local function placerSur(victime: any, piege: Model)
	placer(victime, pose(piege) + Vector3.new(0, 3, 0))
end

local function creatureAuSol(joueur: any, position: Vector3): Model
	local Lancers = module("Lancers")
	Lancers.demarrer(joueur, 0)
	assert(Lancers.lacher(joueur, 0.8, 0) ~= nil, "lancer attendu")
	task.wait(Config.Lancer.DureeVolGraine + 1)
	for _, c in module("TerresSauvages").dossierCreatures():GetChildren() do
		if c:GetAttribute("Proprietaire") == joueur.UserId then
			(c :: Model):PivotTo(CFrame.new(position))
			return c :: Model
		end
	end
	error("créature introuvable après le lancer")
end

-- Victime qui porte une créature, placée loin.
-- Victime suivie par le serveur (comme porteur()) : Pieges.pas doit pouvoir la retrouver.
local function victime(): any
	local b = fauxJoueur()
	module("Bases").creer(b)
	return b
end

local function porteur(): any
	local b = fauxJoueur()
	module("Bases").creer(b)
	local c = creatureAuSol(b, ZONE + Vector3.new(200, 0, 0))
	placer(b, ZONE + Vector3.new(200, 0, 0))
	assert(module("Portage").recolter(b, c) == true, "récolte de B attendue")
	return b
end

local function testPorte(typePiege: string)
	local P = module("Pieges")
	local a, b = poseur(), porteur()
	local avant = b:GetAttribute("Porte")
	local t = maintenant()
	local piege = poserEn(a, typePiege, 0, t)
	placerSur(b, piege)
	if typePiege == "FausseGraine" then
		P.declencherFausse(b, piege, t + 0.1)
	end
	P.pas(t + 0.2)
	local pendant = b:GetAttribute("Porte")
	P.pas(t + 60)
	local apres = b:GetAttribute("Porte")
	nettoyer(a, b)
	assert(avant ~= nil, "B doit porter une créature au départ")
	assert(pendant == avant, "Porte inchangé pendant l'effet")
	assert(apres == avant, "Porte inchangé après l'effet")
end

return {
	["C8 pose valide : débit, modèle, attributs, compteurs"] = function()
		local P = module("Pieges")
		local a = poseur(1000)
		local t = maintenant()
		local piege = P.poser(a, "Filet", t)
		local pieces = a:GetAttribute("Pieces")
		local nombre = #piegesDe(a)
		local ok = piege ~= nil
		local dansDossier = ok and piege.Parent == P.dossier()
		local typeAttr = ok and piege:GetAttribute("Type")
		local poseurId = ok and piege:GetAttribute("PoseurId")
		local poseA = ok and piege:GetAttribute("PoseA")
		local actifs = a:GetAttribute("PiegesActifs")
		local pret = a:GetAttribute("PiegePretA")
		local pos = ok and pose(piege) or Vector3.zero
		local racine = a.Character.HumanoidRootPart.Position
		nettoyer(a)
		assert(ok, "la pose doit réussir")
		assert(dansDossier, "le piège doit être dans Workspace.Pieges")
		assert(
			P.dossier().Name == "Pieges" and P.dossier().Parent == Workspace,
			"dossier Workspace.Pieges"
		)
		assert(pieces == 1000 - PRIX.Filet.Prix, "prix débité, pièces = " .. tostring(pieces))
		assert(nombre == 1, "un seul modèle attendu")
		assert(typeAttr == "Filet", "attribut Type")
		assert(poseurId == a.UserId, "attribut PoseurId")
		assert(type(poseA) == "number", "attribut PoseA")
		assert(actifs == 1, "PiegesActifs = 1, obtenu " .. tostring(actifs))
		assert(
			type(pret) == "number" and math.abs(pret - (t + PIEGES.DelaiPose)) < 0.01,
			"PiegePretA = maintenant + DelaiPose"
		)
		assert(
			math.abs(pos.X - racine.X) < 1 and math.abs(pos.Z - racine.Z) < 1,
			"piège sous le poseur"
		)
	end,

	["C8 chaque type peut être posé et débite son prix"] = function()
		local P = module("Pieges")
		local a = poseur(1000)
		local t = maintenant()
		local depense = 0
		for i, nom in PIEGES.Ordre do
			local p = poserEn(a, nom, (i - 1) * ECART, t + (i - 1) * PIEGES.DelaiPose)
			depense += PRIX[nom].Prix
			assert(p:GetAttribute("Type") == nom, "Type attendu " .. nom)
		end
		local pieces = a:GetAttribute("Pieces")
		local actifs = P.actifsDe(a)
		nettoyer(a)
		assert(pieces == 1000 - depense, "total débité attendu")
		assert(actifs == #PIEGES.Ordre, "actifsDe doit compter les trois pièges")
	end,

	["C8 la fausse graine a un ProximityPrompt sans mot « fausse »"] = function()
		local P = module("Pieges")
		local a = poseur()
		local piege = poserEn(a, "FausseGraine", 0, maintenant())
		local prompt = piege:FindFirstChildWhichIsA("ProximityPrompt", true)
		local nom = string.lower(piege.Name)
		local texte = prompt and string.lower(prompt.ActionText .. prompt.ObjectText) or ""
		local ancres = true
		for _, d in piege:GetDescendants() do
			if d:IsA("BasePart") and (not d.Anchored or d.CanCollide) then
				ancres = false
			end
		end
		nettoyer(a)
		assert(P ~= nil)
		assert(prompt ~= nil, "ProximityPrompt attendu")
		assert(prompt.MaxActivationDistance == PIEGES.DistanceRecolteFausse, "distance du prompt")
		assert(prompt.HoldDuration == Config.Creatures.DureeRecolte, "durée de maintien du prompt")
		assert(not string.find(nom, "fausse", 1, true), "le nom ne doit pas dire « fausse »")
		assert(not string.find(texte, "fausse", 1, true), "le texte ne doit pas dire « fausse »")
		assert(ancres, "toutes les pièces Anchored et sans collision")
	end,

	["C9 pose refusée dans une base"] = function()
		local P = module("Pieges")
		local a = poseur(1000)
		local sol = module("Bases").solDe(a) :: BasePart
		placer(a, sol.Position + Vector3.new(0, 4, 0))
		local p = P.poser(a, "Filet", maintenant())
		local pieces = a:GetAttribute("Pieces")
		local n = #piegesDe(a)
		nettoyer(a)
		assert(p == nil, "pose en base refusée")
		assert(pieces == 1000, "aucun débit")
		assert(n == 0, "aucun modèle")
	end,

	["C9 pose refusée avec trop peu de pièces"] = function()
		local P = module("Pieges")
		local a = poseur(PRIX.Filet.Prix - 1)
		local p = P.poser(a, "Filet", maintenant())
		local pieces = a:GetAttribute("Pieces")
		local n = #piegesDe(a)
		nettoyer(a)
		assert(p == nil, "pose refusée")
		assert(pieces == PRIX.Filet.Prix - 1, "aucun débit")
		assert(n == 0, "aucun modèle")
	end,

	["C9 pose refusée pendant le délai"] = function()
		local P = module("Pieges")
		local a = poseur(1000)
		local t = maintenant()
		assert(P.poser(a, "Filet", t) ~= nil, "première pose attendue")
		placer(a, ZONE + Vector3.new(0, 0, ECART))
		local trop_tot = P.poser(a, "Glu", t + PIEGES.DelaiPose - 0.5)
		local pieces = a:GetAttribute("Pieces")
		local n = #piegesDe(a)
		local ok = P.poser(a, "Glu", t + PIEGES.DelaiPose + 0.1)
		nettoyer(a)
		assert(trop_tot == nil, "pose pendant le délai refusée")
		assert(pieces == 1000 - PRIX.Filet.Prix, "aucun second débit")
		assert(n == 1, "un seul modèle")
		assert(ok ~= nil, "pose permise après le délai")
	end,

	["C9 pose refusée au-delà de MaxParJoueur"] = function()
		local P = module("Pieges")
		local a = poseur(100000)
		local t = maintenant()
		for i = 1, PIEGES.MaxParJoueur do
			poserEn(a, "Filet", (i - 1) * ECART, t + (i - 1) * PIEGES.DelaiPose)
		end
		local avant = a:GetAttribute("Pieces")
		placer(a, ZONE + Vector3.new(0, 0, PIEGES.MaxParJoueur * ECART))
		local p = P.poser(a, "Filet", t + PIEGES.MaxParJoueur * PIEGES.DelaiPose)
		local apres = a:GetAttribute("Pieces")
		local n = #piegesDe(a)
		nettoyer(a)
		assert(p == nil, "pose au-delà de la limite refusée")
		assert(avant == apres, "aucun débit")
		assert(n == PIEGES.MaxParJoueur, "pas de modèle supplémentaire")
	end,

	["C9 pose refusée avec un type invalide"] = function()
		local P = module("Pieges")
		local a = poseur(1000)
		local t = maintenant()
		for _, invalide in { 123, {}, "Bombe", true } do
			assert(P.poser(a, invalide, t) == nil, "type invalide refusé : " .. tostring(invalide))
		end
		local pieces = a:GetAttribute("Pieces")
		local n = #piegesDe(a)
		nettoyer(a)
		assert(pieces == 1000, "aucun débit")
		assert(n == 0, "aucun modèle")
	end,

	["C9 pose refusée trop près d'un autre piège"] = function()
		local P = module("Pieges")
		local a = poseur(1000)
		local t = maintenant()
		poserEn(a, "Filet", 0, t)
		placer(a, ZONE + Vector3.new(0, 0, PIEGES.EcartMin - 2))
		local p = P.poser(a, "Glu", t + PIEGES.DelaiPose + 1)
		local n = #piegesDe(a)
		nettoyer(a)
		assert(p == nil, "pose trop proche refusée")
		assert(n == 1, "un seul modèle")
	end,

	["C10 traiterRequete ignore les arguments en plus du type"] = function()
		local P = module("Pieges")
		local a = poseur(1000)
		local loin = Vector3.new(300, 0, 300)
		P.traiterRequete(a, "Filet", loin, CFrame.new(loin), { X = 300 }, 0)
		local liste = piegesDe(a)
		local pos = if #liste == 1 then pose(liste[1] :: Model) else Vector3.zero
		local racine = a.Character.HumanoidRootPart.Position
		nettoyer(a)
		assert(#liste == 1, "un piège attendu")
		assert(
			math.abs(pos.X - racine.X) < 1 and math.abs(pos.Z - racine.Z) < 1,
			"piège sous le poseur, pas à la position client"
		)
	end,

	["C10 traiterRequete refuse un type invalide"] = function()
		local P = module("Pieges")
		local a = poseur(1000)
		P.traiterRequete(a, { Type = "Filet" })
		P.traiterRequete(a, 42)
		P.traiterRequete(a, nil)
		local n = #piegesDe(a)
		local pieces = a:GetAttribute("Pieces")
		nettoyer(a)
		assert(n == 0 and pieces == 1000, "rien ne doit être posé ni débité")
	end,

	["C11 filet : la victime est immobilisée puis libérée, le filet détruit"] = function()
		local P = module("Pieges")
		local a, b = poseur(), victime()
		local t = maintenant()
		local normal = vitesse(b)
		local filet = poserEn(a, "Filet", 0, t)
		placer(b, pose(filet) + Vector3.new(PIEGES.RayonDeclenchement - 1, 3, 0))
		P.pas(t + 0.1)
		local immo = b:GetAttribute("ImmobileJusqua")
		local vite = vitesse(b)
		local detruit = filet.Parent == nil
		P.pas(t + 0.2 + PRIX.Filet.Duree)
		local immoApres = b:GetAttribute("ImmobileJusqua")
		local viteApres = vitesse(b)
		nettoyer(a, b)
		assert(type(immo) == "number", "ImmobileJusqua posé")
		assert(vite == 0, "WalkSpeed = 0 pendant le filet")
		assert(detruit, "le filet doit être détruit")
		assert(immoApres == nil, "ImmobileJusqua retiré")
		assert(viteApres == normal, "WalkSpeed restauré, obtenu " .. tostring(viteApres))
	end,

	["C11 filet : une victime hors de portée n'est pas affectée"] = function()
		local P = module("Pieges")
		local a, b = poseur(), fauxJoueur()
		local t = maintenant()
		local filet = poserEn(a, "Filet", 0, t)
		placer(b, pose(filet) + Vector3.new(PIEGES.RayonDeclenchement + 3, 3, 0))
		P.pas(t + 0.1)
		local immo = b:GetAttribute("ImmobileJusqua")
		local intact = filet.Parent ~= nil
		nettoyer(a, b)
		assert(immo == nil, "pas d'immobilisation hors de portée")
		assert(intact, "le filet reste en place")
	end,

	["C12 glu : ralentie tant que dedans, restaurée en sortant, glu conservée"] = function()
		local P = module("Pieges")
		local a, b = poseur(), victime()
		local t = maintenant()
		local normal = vitesse(b)
		local glu = poserEn(a, "Glu", 0, t)
		placer(b, pose(glu) + Vector3.new(PRIX.Glu.Rayon - 1, 3, 0))
		P.pas(t + 0.1)
		local dedans = vitesse(b)
		local englue = b:GetAttribute("Englue")
		placer(b, pose(glu) + Vector3.new(PRIX.Glu.Rayon + 10, 3, 0))
		P.pas(t + 0.2)
		local dehors = vitesse(b)
		local englueApres = b:GetAttribute("Englue")
		local reste = glu.Parent ~= nil
		nettoyer(a, b)
		assert(englue == true, "Englue = true dans la glu")
		assert(
			math.abs(dedans - normal * PRIX.Glu.Multiplicateur) < 0.01,
			"vitesse × Multiplicateur, obtenu " .. dedans
		)
		assert(englueApres == nil, "Englue retiré à la sortie")
		assert(dehors == normal, "vitesse restaurée")
		assert(reste, "la glu n'est pas consommée")
	end,

	["C13 fausse graine : récoltée à portée, immobilise et disparaît"] = function()
		local P = module("Pieges")
		local a, b = poseur(), fauxJoueur()
		local t = maintenant()
		local normal = vitesse(b)
		local fausse = poserEn(a, "FausseGraine", 0, t)
		placer(b, pose(fausse) + Vector3.new(PIEGES.DistanceRecolteFausse - 2, 3, 0))
		local ok = P.declencherFausse(b, fausse, t + 0.1)
		local immo = b:GetAttribute("ImmobileJusqua")
		local vite = vitesse(b)
		local detruit = fausse.Parent == nil
		P.pas(t + 0.2 + PRIX.FausseGraine.Duree)
		local viteApres = vitesse(b)
		nettoyer(a, b)
		assert(ok == true, "déclenchement accepté")
		assert(
			type(immo) == "number" and math.abs(immo - (t + 0.1 + PRIX.FausseGraine.Duree)) < 0.01,
			"ImmobileJusqua = maintenant + Duree"
		)
		assert(vite == 0, "WalkSpeed = 0")
		assert(detruit, "fausse graine détruite")
		assert(viteApres == normal, "WalkSpeed restauré")
	end,

	["C13 fausse graine : hors de portée, refus et piège intact"] = function()
		local P = module("Pieges")
		local a, b = poseur(), fauxJoueur()
		local t = maintenant()
		local fausse = poserEn(a, "FausseGraine", 0, t)
		placer(b, pose(fausse) + Vector3.new(PIEGES.DistanceRecolteFausse + 5, 3, 0))
		local ok = P.declencherFausse(b, fausse, t + 0.1)
		local immo = b:GetAttribute("ImmobileJusqua")
		local intact = fausse.Parent ~= nil
		nettoyer(a, b)
		assert(ok == false, "déclenchement refusé")
		assert(immo == nil, "pas d'immobilisation")
		assert(intact, "piège intact")
	end,

	["C14 le poseur n'est affecté par aucun de ses pièges"] = function()
		local P = module("Pieges")
		local a = poseur()
		local t = maintenant()
		local normal = vitesse(a)
		local filet = poserEn(a, "Filet", 0, t)
		local glu = poserEn(a, "Glu", ECART + PRIX.Glu.Rayon, t + PIEGES.DelaiPose)
		local fausse =
			poserEn(a, "FausseGraine", 2 * (ECART + PRIX.Glu.Rayon), t + 2 * PIEGES.DelaiPose)
		placerSur(a, filet)
		P.pas(t + 0.1)
		placerSur(a, glu)
		P.pas(t + 0.2)
		local vitesseGlu = vitesse(a)
		local englue = a:GetAttribute("Englue")
		placerSur(a, fausse)
		local ok = P.declencherFausse(a, fausse, t + 0.3)
		P.pas(t + 0.4)
		local immo = a:GetAttribute("ImmobileJusqua")
		local restent = filet.Parent ~= nil and glu.Parent ~= nil and fausse.Parent ~= nil
		nettoyer(a)
		assert(immo == nil, "poseur jamais immobilisé")
		assert(englue == nil and vitesseGlu == normal, "poseur jamais englué")
		assert(ok == false, "sa propre fausse graine ne le touche pas")
		assert(restent, "ses pièges restent en place")
	end,

	["C15 protection : second filet sans effet juste après, actif ensuite"] = function()
		local P = module("Pieges")
		local a, b = poseur(), victime()
		local t = maintenant()
		local f1 = poserEn(a, "Filet", 0, t)
		local f2 = poserEn(a, "Filet", ECART, t + PIEGES.DelaiPose)
		local fin = t + 0.1 + PRIX.Filet.Duree + 0.1
		placerSur(b, f1)
		P.pas(t + 0.1)
		P.pas(fin) -- fin de l'immobilisation
		local libre = b:GetAttribute("ImmobileJusqua") == nil
		placerSur(b, f2)
		P.pas(fin + 0.1)
		local protegee = b:GetAttribute("ImmobileJusqua") == nil
		local f2Intact = f2.Parent ~= nil
		P.pas(fin + PIEGES.DureeProtection + 1)
		local immo = b:GetAttribute("ImmobileJusqua")
		nettoyer(a, b)
		assert(libre, "B doit être libérée avant le second filet")
		assert(protegee and f2Intact, "protégée juste après l'effet : second filet sans effet")
		assert(type(immo) == "number", "après DureeProtection, B est de nouveau prise")
	end,

	["C16 filet : la créature portée est gardée"] = function()
		testPorte("Filet")
	end,

	["C16 glu : la créature portée est gardée"] = function()
		testPorte("Glu")
	end,

	["C16 fausse graine : la créature portée est gardée"] = function()
		testPorte("FausseGraine")
	end,

	["C17 un piège non déclenché disparaît après DureeVie"] = function()
		local P = module("Pieges")
		local a = poseur()
		local t = maintenant()
		local piege = poserEn(a, "Filet", 0, t)
		local avant = a:GetAttribute("PiegesActifs")
		P.pas(t + PIEGES.DureeVie - 1)
		local encore = piege.Parent ~= nil
		P.pas(t + PIEGES.DureeVie + 1)
		local detruit = piege.Parent == nil
		local apres = a:GetAttribute("PiegesActifs") or 0
		local compte = P.actifsDe(a)
		nettoyer(a)
		assert(avant == 1, "PiegesActifs = 1 après la pose")
		assert(encore, "le piège existe encore avant DureeVie")
		assert(detruit, "le piège disparaît après DureeVie")
		assert(apres == 0 and compte == 0, "PiegesActifs diminue")
	end,

	["C18 nettoyer détruit les pièges du joueur"] = function()
		local P = module("Pieges")
		local a = poseur()
		local t = maintenant()
		poserEn(a, "Filet", 0, t)
		poserEn(a, "Glu", ECART + PRIX.Glu.Rayon, t + PIEGES.DelaiPose)
		local avant = #piegesDe(a)
		P.nettoyer(a)
		local apres = #piegesDe(a)
		local compte = P.actifsDe(a)
		nettoyer(a)
		assert(avant == 2, "deux pièges avant")
		assert(apres == 0 and compte == 0, "aucun piège après nettoyer")
	end,

	["C18 nettoyer efface les effets de la victime"] = function()
		local P = module("Pieges")
		local a, b = poseur(), victime()
		local t = maintenant()
		local glu = poserEn(a, "Glu", 0, t)
		local filet = poserEn(a, "Filet", PRIX.Glu.Rayon + ECART, t + PIEGES.DelaiPose)
		placerSur(b, glu)
		P.pas(t + 0.1)
		local englue = b:GetAttribute("Englue")
		placerSur(b, filet)
		P.pas(t + 0.2)
		local immo = b:GetAttribute("ImmobileJusqua")
		P.nettoyer(b)
		local immoApres = b:GetAttribute("ImmobileJusqua")
		local englueApres = b:GetAttribute("Englue")
		nettoyer(a, b)
		assert(englue == true or immo ~= nil, "au moins un effet actif avant nettoyer")
		assert(immoApres == nil, "ImmobileJusqua effacé")
		assert(englueApres == nil, "Englue effacé")
	end,

	["C19 le RemoteEvent PoserPiege est déclaré"] = function()
		local remote = ReplicatedStorage:WaitForChild("PoserPiege", 5)
		assert(
			remote and remote:IsA("RemoteEvent"),
			"RemoteEvent PoserPiege attendu dans ReplicatedStorage"
		)
	end,

	["C19 le module client InterfacePieges est présent"] = function()
		local scripts = StarterPlayer:FindFirstChild("StarterPlayerScripts")
		local client = scripts and scripts:FindFirstChild("Client")
		assert(client, "StarterPlayerScripts.Client introuvable")
		local m = client:FindFirstChild("InterfacePieges")
		assert(m and m:IsA("ModuleScript"), "module client InterfacePieges manquant")
	end,
}
