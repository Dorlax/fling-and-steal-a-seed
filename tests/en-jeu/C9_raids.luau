local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Forge = require(ReplicatedStorage.Shared.Forge)

-- API serveur selon la maquette issue-11 :
--   Raids.voler(voleur, proprietaire, numero, maintenant?) -> boolean
--   Raids.verrouiller(proprietaire, declencheur, maintenant?) -> boolean
--   Raids.pas(maintenant?) ; Raids.nettoyer(joueur)
--   Bases.estDansBaseDe(joueur, proprietaire) -> boolean ; Bases.modeleDe/solDe
--   Sauvegarde.ajouterCreature / creaturesDe ; Portage.recolter / porte
--   Attributs joueur : Porte, Pieces, RevenuParSeconde, VerrouJusqua, VerrouPretA
--   Créature exposée : attribut Emplacement + ProximityPrompt « Voler » ; base : Porte, BoutonVerrou, Bouclier
local RAID = (Config :: any).Raid

local function module(nom: string): any
	local dossier = ServerScriptService:WaitForChild("Server", 5)
	assert(dossier, "dossier Server introuvable")
	local m = dossier:FindFirstChild(nom)
	assert(m and m:IsA("ModuleScript"), "module serveur manquant : " .. nom)
	return require(m)
end

local prochainId = -900

-- Faux joueur avec un vrai personnage (Humanoid + HumanoidRootPart).
local function fauxJoueur(): any
	prochainId -= 1
	local attributs: { [string]: any } =
		{ Force = 0, Vitesse = 0, ModeForge = "Force", SurForge = false, Pieces = 0 }
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

local function nettoyer(...: any)
	for _, joueur in { ... } do
		module("Raids").nettoyer(joueur)
		module("Plaquages").nettoyer(joueur)
		module("Monstres").nettoyer(joueur)
		module("Portage").nettoyer(joueur)
		module("Bases").liberer(joueur)
		if joueur.Character then
			joueur.Character:Destroy()
		end
	end
	for _, c in module("TerresSauvages").dossierCreatures():GetChildren() do
		if c:GetAttribute("Libre") == true or c:GetAttribute("Volee") == true then
			c:Destroy()
		end
	end
end

local function creatureExposee(proprietaire: any, numero: number): Model?
	local base = module("Bases").modeleDe(proprietaire)
	local dossier = base and base:FindFirstChild("CreaturesBase")
	if dossier == nil then
		return nil
	end
	for _, c in dossier:GetChildren() do
		if c:GetAttribute("Emplacement") == numero then
			return c :: Model
		end
	end
	return nil
end

local function ajouter(joueur: any, ...: string)
	local Sauvegarde, Bases = module("Sauvegarde"), module("Bases")
	for _, rarete in { ... } do
		assert(
			Sauvegarde.ajouterCreature(joueur, rarete) == true,
			"ajout de " .. rarete .. " attendu"
		)
	end
	Bases.afficherCreatures(joueur, Sauvegarde.creaturesDe(joueur))
end

-- Victime A avec 3 créatures exposées ; voleur B placé à côté de la créature n°2, dans la base de A.
local function scenario(): (any, any)
	local Bases = module("Bases")
	local a, b = fauxJoueur(), fauxJoueur()
	Bases.creer(a)
	Bases.creer(b)
	ajouter(a, "Commune", "Rare", "Epique")
	local c = creatureExposee(a, 2)
	assert(c, "créature exposée n°2 attendue")
	placer(b, c:GetPivot().Position + Vector3.new(0, 0, 3))
	return a, b
end

local function dansLeDossier(creature: Instance): boolean
	return creature.Parent == module("TerresSauvages").dossierCreatures()
end

-- Cherche la créature portée par un joueur (volée).
local function creaturePortee(joueur: any): Instance?
	for _, d in joueur.Character:GetDescendants() do
		if d:IsA("Model") and d:GetAttribute("Volee") == true then
			return d
		end
	end
	return nil
end

return {
	["C9 créatures exposées : Emplacement et ProximityPrompt Voler ; base : Porte, BoutonVerrou, Bouclier"] = function()
		local Bases = module("Bases")
		local a = fauxJoueur()
		Bases.creer(a)
		ajouter(a, "Commune", "Rare")
		local base = Bases.modeleDe(a)
		assert(base, "base attendue")
		local resultats: { string } = {}
		for numero = 1, 2 do
			local c = creatureExposee(a, numero)
			if c == nil then
				table.insert(resultats, "créature exposée " .. numero .. " sans Emplacement")
			else
				local prompt = c:FindFirstChild("Voler", true)
				if prompt == nil or not prompt:IsA("ProximityPrompt") then
					table.insert(resultats, "prompt Voler manquant " .. numero)
				else
					if prompt.ActionText ~= "Voler" then
						table.insert(resultats, "ActionText doit être Voler")
					end
					if prompt.MaxActivationDistance ~= RAID.DistanceVol then
						table.insert(resultats, "MaxActivationDistance doit valoir DistanceVol")
					end
				end
			end
		end
		local porte = base:FindFirstChild("Porte")
		local bouton = base:FindFirstChild("BoutonVerrou")
		local verrou = bouton and bouton:FindFirstChild("Verrouiller", true)
		local bouclier = base:FindFirstChild("Bouclier")
		nettoyer(a)
		assert(#resultats == 0, table.concat(resultats, " ; "))
		assert(porte ~= nil, "Porte attendue")
		assert(bouton ~= nil, "BoutonVerrou attendu")
		assert(
			verrou and verrou:IsA("ProximityPrompt"),
			"prompt Verrouiller attendu sur BoutonVerrou"
		)
		assert(bouclier and bouclier:IsA("BasePart"), "Bouclier attendu")
		assert((bouclier :: BasePart).CanCollide == false, "Bouclier.CanCollide doit être false")
	end,

	["C10 vol réussi : la victime perd la créature, le voleur la porte"] = function()
		local Raids, Sauvegarde = module("Raids"), module("Sauvegarde")
		local a, b = scenario()
		local revenuAvant = a:GetAttribute("RevenuParSeconde")
		local ok = Raids.voler(b, a, 2, Workspace:GetServerTimeNow())
		local liste = Sauvegarde.creaturesDe(a)
		local revenuApres = a:GetAttribute("RevenuParSeconde")
		local porte = b:GetAttribute("Porte")
		local expo3 = creatureExposee(a, 3)
		local expo2 = creatureExposee(a, 2)
		local corps2 = expo2 and expo2:FindFirstChild("Corps")
		nettoyer(a, b)
		assert(ok == true, "le vol doit réussir")
		assert(
			#liste == 2 and liste[1] == "Commune" and liste[2] == "Epique",
			"la victime doit perdre la Rare"
		)
		assert(revenuApres < revenuAvant, "RevenuParSeconde doit baisser")
		assert(porte == "Rare", "Porte du voleur attendu : Rare, obtenu " .. tostring(porte))
		assert(expo3 == nil, "il ne doit rester que 2 créatures exposées")
		assert(expo2 ~= nil and corps2 ~= nil, "créatures réaffichées")
	end,

	["C11 vol refusé sans changement : voleur hors de la base visitée"] = function()
		local Raids, Sauvegarde = module("Raids"), module("Sauvegarde")
		local a, b = scenario()
		placer(b, Vector3.new(0, 10, 500))
		local ok = Raids.voler(b, a, 2, Workspace:GetServerTimeNow())
		local n = #Sauvegarde.creaturesDe(a)
		local porte = b:GetAttribute("Porte")
		nettoyer(a, b)
		assert(ok == false, "vol refusé attendu")
		assert(n == 3 and porte == nil, "rien ne doit changer")
	end,

	["C11 vol refusé sans changement : voleur = propriétaire"] = function()
		local Raids, Sauvegarde = module("Raids"), module("Sauvegarde")
		local a, b = scenario()
		local c = creatureExposee(a, 2) :: Model
		placer(a, c:GetPivot().Position + Vector3.new(0, 0, 3))
		local ok = Raids.voler(a, a, 2, Workspace:GetServerTimeNow())
		local n = #Sauvegarde.creaturesDe(a)
		local porte = a:GetAttribute("Porte")
		nettoyer(a, b)
		assert(ok == false, "vol refusé attendu")
		assert(n == 3 and porte == nil, "rien ne doit changer")
	end,

	["C11 vol refusé sans changement : emplacement vide ou inexistant"] = function()
		local Raids, Sauvegarde = module("Raids"), module("Sauvegarde")
		local a, b = scenario()
		local r4 = Raids.voler(b, a, 4, Workspace:GetServerTimeNow())
		local r0 = Raids.voler(b, a, 0, Workspace:GetServerTimeNow())
		local rNil = Raids.voler(b, a, nil, Workspace:GetServerTimeNow())
		local n = #Sauvegarde.creaturesDe(a)
		local porte = b:GetAttribute("Porte")
		nettoyer(a, b)
		assert(r4 == false and r0 == false and rNil == false, "vols refusés attendus")
		assert(n == 3 and porte == nil, "rien ne doit changer")
	end,

	["C11 vol refusé sans changement : voleur trop loin de la créature"] = function()
		local Raids, Sauvegarde, Bases = module("Raids"), module("Sauvegarde"), module("Bases")
		local a, b = scenario()
		local c = creatureExposee(a, 2) :: Model
		placer(b, c:GetPivot().Position + Vector3.new(0, 0, RAID.DistanceVol + 5))
		-- Reste éventuellement dans la base : la distance seule doit faire échouer le vol.
		local dedans = Bases.estDansBaseDe(b, a)
		local ok = Raids.voler(b, a, 2, Workspace:GetServerTimeNow())
		local n = #Sauvegarde.creaturesDe(a)
		local porte = b:GetAttribute("Porte")
		nettoyer(a, b)
		assert(dedans ~= nil)
		assert(ok == false, "vol refusé attendu")
		assert(n == 3 and porte == nil, "rien ne doit changer")
	end,

	["C12 un voleur qui porte déjà une créature ne peut pas en voler une autre"] = function()
		local Raids, Sauvegarde = module("Raids"), module("Sauvegarde")
		local a, b = scenario()
		assert(Raids.voler(b, a, 2, Workspace:GetServerTimeNow()) == true, "premier vol attendu")
		local portee = creaturePortee(b)
		local c = creatureExposee(a, 2) :: Model -- ex-n°3 (Epique) remontée en n°2
		placer(b, c:GetPivot().Position + Vector3.new(0, 0, 3))
		local ok = Raids.voler(b, a, 2, Workspace:GetServerTimeNow())
		local liste = Sauvegarde.creaturesDe(a)
		local porte = b:GetAttribute("Porte")
		local encorePortee = creaturePortee(b)
		nettoyer(a, b)
		assert(ok == false, "second vol refusé attendu")
		assert(#liste == 2, "la base de la victime doit rester à 2 créatures")
		assert(porte == "Rare", "la créature portée doit rester la Rare")
		assert(
			portee ~= nil and encorePortee == portee,
			"la créature portée doit être inchangée"
		)
	end,

	["C13 le voleur dépose la créature volée dans sa propre base"] = function()
		local Raids, Sauvegarde, Portage, Bases =
			module("Raids"), module("Sauvegarde"), module("Portage"), module("Bases")
		local a, b = scenario()
		assert(Raids.voler(b, a, 2, Workspace:GetServerTimeNow()) == true, "vol attendu")
		local sol = Bases.solDe(b) :: BasePart
		placer(b, sol.Position + Vector3.new(0, 4, 0))
		Portage.verifierDepot(b)
		local liste = Sauvegarde.creaturesDe(b)
		local porte = b:GetAttribute("Porte")
		nettoyer(a, b)
		assert(table.find(liste, "Rare") ~= nil, "la base du voleur doit contenir la Rare")
		assert(porte == nil, "Porte doit redevenir nil")
	end,

	["C14 un voleur plaqué lâche la créature volée, libre"] = function()
		local Raids, Plaquages = module("Raids"), module("Plaquages")
		local a, b = scenario()
		assert(Raids.voler(b, a, 2, Workspace:GetServerTimeNow()) == true, "vol attendu")
		local volee = creaturePortee(b)
		local plaqueur = fauxJoueur()
		module("Bases").creer(plaqueur)
		-- Hors de toute base, dans les Terres Sauvages.
		local POSITION = Vector3.new(0, 10, 500)
		placer(b, POSITION)
		placer(plaqueur, POSITION + Vector3.new(0, 0, 5))
		local cible = Plaquages.plaquer(plaqueur, { b }, Workspace:GetServerTimeNow())
		local porte = b:GetAttribute("Porte")
		local libre = volee ~= nil and volee:GetAttribute("Libre")
		local dans = volee ~= nil and dansLeDossier(volee)
		nettoyer(a, b, plaqueur)
		assert(volee ~= nil, "créature volée portée attendue avant le plaquage")
		assert(cible == b, "plaquage attendu")
		assert(porte == nil, "Porte doit être nil")
		assert(dans, "la créature doit être dans le dossier des créatures")
		assert(libre == true, "Libre = true attendu")
	end,

	["C14 un voleur frappé par un monstre lâche la créature volée, libre"] = function()
		local Raids, Monstres = module("Raids"), module("Monstres")
		local a, b = scenario()
		assert(Raids.voler(b, a, 2, Workspace:GetServerTimeNow()) == true, "vol attendu")
		local volee = creaturePortee(b)
		local POSITION = Vector3.new(0, 10, 500)
		placer(b, POSITION)
		local monstre: Model? = nil
		for _, m in Workspace:WaitForChild("Monstres", 5):GetChildren() do
			if m:GetAttribute("Zone") == "Proche" then
				monstre = m :: Model
				break
			end
		end
		assert(monstre, "monstre de la zone Proche introuvable")
		monstre:PivotTo(CFrame.new(POSITION + Vector3.new(0, 0, 2)))
		-- Instant futur : le monstre peut être en recharge à cause d'un autre test.
		local ok = Monstres.frapper(monstre, b, Workspace:GetServerTimeNow() + 1000)
		local porte = b:GetAttribute("Porte")
		local libre = volee ~= nil and volee:GetAttribute("Libre")
		local dans = volee ~= nil and dansLeDossier(volee)
		nettoyer(a, b)
		assert(volee ~= nil, "créature volée portée attendue avant le coup")
		assert(ok == true, "le coup doit réussir")
		assert(porte == nil, "Porte doit être nil")
		assert(dans, "la créature doit être dans le dossier des créatures")
		assert(libre == true, "Libre = true attendu")
	end,

	["C15 après un vol, billboard VOLÉ ! au-dessus du voleur et RemoteEvent AlerteVol"] = function()
		local Raids = module("Raids")
		local a, b = scenario()
		local remote = ReplicatedStorage:FindFirstChild("AlerteVol")
		local ok = Raids.voler(b, a, 2, Workspace:GetServerTimeNow())
		local trouve = false
		for _, d in b.Character:GetDescendants() do
			if d:IsA("BillboardGui") then
				for _, t in d:GetDescendants() do
					if
						t:IsA("TextLabel") and string.find((t :: TextLabel).Text, "VOLÉ", 1, true)
					then
						trouve = true
					end
				end
			end
		end
		nettoyer(a, b)
		assert(
			remote and remote:IsA("RemoteEvent"),
			"RemoteEvent AlerteVol attendu dans ReplicatedStorage"
		)
		assert(ok == true, "vol attendu")
		assert(trouve, "billboard « VOLÉ ! » attendu au-dessus du voleur")
	end,

	["C16 verrou acheté : pièces retirées, attributs fixés, bouclier visible"] = function()
		local Raids, Bases = module("Raids"), module("Bases")
		local a = fauxJoueur()
		Bases.creer(a)
		a:SetAttribute("Pieces", RAID.PrixVerrou + 50)
		local bouton = (Bases.modeleDe(a) :: Model):FindFirstChild("BoutonVerrou") :: BasePart
		assert(bouton, "BoutonVerrou attendu")
		placer(a, bouton.Position + Vector3.new(0, 3, 0))
		local t = Workspace:GetServerTimeNow()
		local ok = Raids.verrouiller(a, a, t)
		local pieces = a:GetAttribute("Pieces")
		local jusqua = a:GetAttribute("VerrouJusqua")
		local pret = a:GetAttribute("VerrouPretA")
		local bouclier = (Bases.modeleDe(a) :: Model):FindFirstChild("Bouclier") :: BasePart
		local transparence = bouclier.Transparency
		nettoyer(a)
		assert(ok == true, "verrouillage attendu")
		assert(pieces == 50, "exactement PrixVerrou pièces retirées, reste " .. tostring(pieces))
		assert(
			type(jusqua) == "number" and math.abs(jusqua - (t + 60)) < 0.01,
			"VerrouJusqua = t + 60"
		)
		assert(
			type(pret) == "number" and math.abs(pret - (t + 120)) < 0.01,
			"VerrouPretA = t + 120"
		)
		assert(transparence < 1, "Bouclier doit être visible")
	end,

	["C17 verrou refusé sans changement : déclencheur ≠ propriétaire"] = function()
		local Raids, Bases = module("Raids"), module("Bases")
		local a, b = fauxJoueur(), fauxJoueur()
		Bases.creer(a)
		Bases.creer(b)
		a:SetAttribute("Pieces", 500)
		b:SetAttribute("Pieces", 500)
		local bouton = (Bases.modeleDe(a) :: Model):FindFirstChild("BoutonVerrou") :: BasePart
		placer(b, bouton.Position + Vector3.new(0, 3, 0))
		local ok = Raids.verrouiller(a, b, Workspace:GetServerTimeNow())
		local pa, pb, jusqua =
			a:GetAttribute("Pieces"), b:GetAttribute("Pieces"), a:GetAttribute("VerrouJusqua")
		nettoyer(a, b)
		assert(ok == false, "refus attendu")
		assert(pa == 500 and pb == 500 and jusqua == nil, "rien ne doit changer")
	end,

	["C17 verrou refusé sans changement : pas assez de pièces"] = function()
		local Raids, Bases = module("Raids"), module("Bases")
		local a = fauxJoueur()
		Bases.creer(a)
		a:SetAttribute("Pieces", RAID.PrixVerrou - 1)
		local bouton = (Bases.modeleDe(a) :: Model):FindFirstChild("BoutonVerrou") :: BasePart
		placer(a, bouton.Position + Vector3.new(0, 3, 0))
		local ok = Raids.verrouiller(a, a, Workspace:GetServerTimeNow())
		local pieces, jusqua = a:GetAttribute("Pieces"), a:GetAttribute("VerrouJusqua")
		nettoyer(a)
		assert(ok == false, "refus attendu")
		assert(pieces == RAID.PrixVerrou - 1 and jusqua == nil, "rien ne doit changer")
	end,

	["C17 verrou refusé sans changement : verrou déjà actif, puis en recharge"] = function()
		local Raids, Bases = module("Raids"), module("Bases")
		local a = fauxJoueur()
		Bases.creer(a)
		a:SetAttribute("Pieces", 1000)
		local bouton = (Bases.modeleDe(a) :: Model):FindFirstChild("BoutonVerrou") :: BasePart
		placer(a, bouton.Position + Vector3.new(0, 3, 0))
		local t = Workspace:GetServerTimeNow()
		assert(Raids.verrouiller(a, a, t) == true, "premier achat attendu")
		local piecesApres = a:GetAttribute("Pieces")
		local actif = Raids.verrouiller(a, a, t + 10)
		local piecesActif = a:GetAttribute("Pieces")
		local recharge = Raids.verrouiller(a, a, t + RAID.DureeVerrou + 10)
		local piecesRecharge = a:GetAttribute("Pieces")
		local jusqua = a:GetAttribute("VerrouJusqua")
		nettoyer(a)
		assert(
			actif == false and piecesActif == piecesApres,
			"verrou actif : refus sans changement"
		)
		assert(
			recharge == false and piecesRecharge == piecesApres,
			"recharge : refus sans changement"
		)
		assert(math.abs(jusqua - (t + RAID.DureeVerrou)) < 0.01, "VerrouJusqua inchangé")
	end,

	["C18 pendant le verrou, l'intrus est expulsé, le propriétaire reste ; après DureeVerrou, plus d'expulsion"] = function()
		local Raids, Bases = module("Raids"), module("Bases")
		local a, b = fauxJoueur(), fauxJoueur()
		Bases.creer(a)
		Bases.creer(b)
		a:SetAttribute("Pieces", 500)
		local bouton = (Bases.modeleDe(a) :: Model):FindFirstChild("BoutonVerrou") :: BasePart
		local sol = Bases.solDe(a) :: BasePart
		placer(a, bouton.Position + Vector3.new(0, 3, 0))
		placer(b, sol.Position + Vector3.new(0, 4, 0))
		assert(Bases.estDansBaseDe(b, a), "B doit être dans la base de A au départ")
		local t = Workspace:GetServerTimeNow()
		assert(Raids.verrouiller(a, a, t) == true, "verrouillage attendu")
		-- L'achat expulse déjà les intrus ; on les remet de force pour tester Raids.pas.
		placer(b, sol.Position + Vector3.new(0, 4, 0))
		Raids.pas(t + 1)
		local intrusDedans = Bases.estDansBaseDe(b, a)
		-- Après la fin du verrou.
		placer(b, sol.Position + Vector3.new(0, 4, 0))
		Raids.pas(t + RAID.DureeVerrou + 1)
		local intrusApres = Bases.estDansBaseDe(b, a)
		local bouclier = (Bases.modeleDe(a) :: Model):FindFirstChild("Bouclier") :: BasePart
		local transparence = bouclier.Transparency
		nettoyer(a, b)
		assert(intrusDedans == false, "l'intrus doit être expulsé pendant le verrou")
		assert(intrusApres == true, "l'intrus ne doit plus être expulsé après le verrou")
		assert(transparence == 1, "Bouclier doit être invisible après le verrou")
	end,

	["C18 le propriétaire reste en place pendant le verrou"] = function()
		local Raids, Bases = module("Raids"), module("Bases")
		local a = fauxJoueur()
		Bases.creer(a)
		a:SetAttribute("Pieces", 500)
		local bouton = (Bases.modeleDe(a) :: Model):FindFirstChild("BoutonVerrou") :: BasePart
		local sol = Bases.solDe(a) :: BasePart
		placer(a, bouton.Position + Vector3.new(0, 3, 0))
		local t = Workspace:GetServerTimeNow()
		assert(Raids.verrouiller(a, a, t) == true, "verrouillage attendu")
		local avant = a.Character.HumanoidRootPart.Position
		Raids.pas(t + 1)
		local apres = a.Character.HumanoidRootPart.Position
		local dedans = Bases.estDansBaseDe(a, a)
		nettoyer(a)
		assert(sol ~= nil)
		assert((apres - avant).Magnitude < 0.01, "le propriétaire ne doit pas bouger")
		assert(dedans, "le propriétaire doit rester dans sa base")
	end,

	["C19 pendant le verrou, voler est refusé même si le voleur est placé de force"] = function()
		local Raids, Sauvegarde, Bases = module("Raids"), module("Sauvegarde"), module("Bases")
		local a, b = scenario()
		a:SetAttribute("Pieces", 500)
		local bouton = (Bases.modeleDe(a) :: Model):FindFirstChild("BoutonVerrou") :: BasePart
		placer(a, bouton.Position + Vector3.new(0, 3, 0))
		local t = Workspace:GetServerTimeNow()
		assert(Raids.verrouiller(a, a, t) == true, "verrouillage attendu")
		local c = creatureExposee(a, 2) :: Model
		placer(b, c:GetPivot().Position + Vector3.new(0, 0, 3))
		local ok = Raids.voler(b, a, 2, t + 1)
		local n = #Sauvegarde.creaturesDe(a)
		local porte = b:GetAttribute("Porte")
		nettoyer(a, b)
		assert(ok == false, "vol refusé pendant le verrou")
		assert(n == 3 and porte == nil, "rien ne doit changer")
	end,
}
