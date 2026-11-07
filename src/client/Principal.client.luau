--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local InterfaceStats = require(script.Parent:WaitForChild("InterfaceStats"))

InterfaceStats.demarrer()

print(`{Config.NomDuJeu} : client démarré`)
