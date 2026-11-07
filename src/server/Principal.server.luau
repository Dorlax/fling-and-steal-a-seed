--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

print(`{Config.NomDuJeu} {Config.Version} : serveur démarré`)
