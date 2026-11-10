--!strict
-- Sons du jeu (côté client, joués pour le joueur local seulement).
-- Les identifiants sont dans Shared.Config.Sons : par défaut des sons
-- intégrés à Roblox (rbxasset://sounds/…), à remplacer par des sons de la
-- bibliothèque Roblox. Un « jingle » est une suite de notes jouées avec le
-- même son à des hauteurs différentes.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local Sons = {}

local dernier: { [string]: number } = {}
local cache: { [string]: Sound } = {}

local function modele(nom: string): Sound?
	local infos = (Config.Sons.Effets :: any)[nom]
	if infos == nil or infos.Id == "" then
		return nil
	end
	local existant = cache[nom]
	if existant then
		return existant
	end
	local nouveau = Instance.new("Sound")
	nouveau.Name = "Son" .. nom
	nouveau.SoundId = infos.Id
	nouveau.Volume = infos.Volume or 0.5
	nouveau.Parent = SoundService
	cache[nom] = nouveau
	return nouveau
end

-- Joue l'effet `nom` (Config.Sons.Effets), au plus une fois toutes les
-- `Intervalle` secondes, hauteur `hauteur` (1 = normale) légèrement variée.
function Sons.jouer(nom: string, hauteur: number?)
	local infos = (Config.Sons.Effets :: any)[nom]
	local son = modele(nom)
	if son == nil or infos == nil then
		return
	end
	local maintenant = os.clock()
	if maintenant - (dernier[nom] or -math.huge) < (infos.Intervalle or 0.05) then
		return
	end
	dernier[nom] = maintenant
	local copie = (son :: Sound):Clone() :: Sound
	copie.PlaybackSpeed = (hauteur or 1) * (1 + (math.random() - 0.5) * (infos.Variation or 0.08))
	copie.Parent = SoundService
	copie:Play()
	copie.Ended:Once(function()
		copie:Destroy()
	end)
end

-- Joue un jingle de Config.Sons.Jingles (notes = hauteurs successives).
function Sons.jingle(nom: string)
	local j = (Config.Sons.Jingles :: any)[nom]
	if j == nil then
		return
	end
	task.spawn(function()
		for _, note in j.Notes do
			local son = modele(j.Son)
			if son then
				local copie = (son :: Sound):Clone() :: Sound
				copie.PlaybackSpeed = note
				copie.Parent = SoundService
				copie:Play()
				copie.Ended:Once(function()
					copie:Destroy()
				end)
			end
			task.wait(j.Tempo)
		end
	end)
end

-- Musique de fond en boucle (si Config.Sons.Musique.Id est renseigné).
function Sons.demarrerMusique()
	local m = Config.Sons.Musique
	if m.Id == "" then
		return
	end
	local musique = Instance.new("Sound")
	musique.Name = "Musique"
	musique.SoundId = m.Id
	musique.Volume = m.Volume
	musique.Looped = true
	musique.Parent = SoundService
	musique:Play()
end

return Sons
