--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Animations = require(script.Parent:WaitForChild("Animations"))
local AnimationsOs = require(script.Parent:WaitForChild("AnimationsOs"))
local AnimationsForge = require(script.Parent:WaitForChild("AnimationsForge"))
local Ambiances = require(script.Parent:WaitForChild("Ambiances"))
local Bandeaux = require(script.Parent:WaitForChild("Bandeaux"))
local EffetsComiques = require(script.Parent:WaitForChild("EffetsComiques"))
local EffetsEspeces = require(script.Parent:WaitForChild("EffetsEspeces"))
local InterfaceBase = require(script.Parent:WaitForChild("InterfaceBase"))
local InterfaceBoutique = require(script.Parent:WaitForChild("InterfaceBoutique"))
local InterfaceCadeaux = require(script.Parent:WaitForChild("InterfaceCadeaux"))
local InterfaceBestiaire = require(script.Parent:WaitForChild("InterfaceBestiaire"))
local InterfaceClassement = require(script.Parent:WaitForChild("InterfaceClassement"))
local InterfaceEvenement = require(script.Parent:WaitForChild("InterfaceEvenement"))
local InterfaceLancer = require(script.Parent:WaitForChild("InterfaceLancer"))
local LancerVisuel = require(script.Parent:WaitForChild("LancerVisuel"))
local InterfacePieges = require(script.Parent:WaitForChild("InterfacePieges"))
local InterfacePieces = require(script.Parent:WaitForChild("InterfacePieces"))
local InterfacePlaquage = require(script.Parent:WaitForChild("InterfacePlaquage"))
local InterfaceRaid = require(script.Parent:WaitForChild("InterfaceRaid"))
local InterfaceStats = require(script.Parent:WaitForChild("InterfaceStats"))
local Panneaux = require(script.Parent:WaitForChild("Panneaux"))
local AmbianceEvenements = require(script.Parent:WaitForChild("AmbianceEvenements"))
local Sons = require(script.Parent:WaitForChild("Sons"))

-- Bandeau de messages et restylage local des panneaux avant les interfaces.
Bandeaux.demarrer()
Panneaux.demarrer()
InterfaceStats.demarrer()
InterfaceLancer.demarrer()
LancerVisuel.demarrer()
InterfacePieces.demarrer()
-- Après InterfaceLancer : l'action « Plaquer » passe en priorité sur la touche
-- partagée et laisse l'appui au lancer quand personne n'est à plaquer.
InterfacePlaquage.demarrer()
InterfaceRaid.demarrer()
InterfacePieges.demarrer()
-- Multijoueur : événement en cours et classements.
InterfaceEvenement.demarrer()
-- Événements : bandeau animé, lumière et effets dans le ciel.
AmbianceEvenements.demarrer()
Sons.demarrerMusique()
InterfaceClassement.demarrer()
InterfaceBestiaire.demarrer()
InterfaceBase.demarrer()
InterfaceBoutique.demarrer()
InterfaceCadeaux.demarrer()
-- Étoiles autour de la tête des joueurs étourdis par un monstre.
EffetsComiques.demarrer()
-- Sautillement des créatures et dandinement des monstres (affichage seulement).
Animations.demarrer()
-- Créatures 3D à squelette (Blender) : idle, marche, course, joie, étourdi, porté.
AnimationsOs.demarrer()
-- Machines de Forge : couleur du mode, soufflets, marteau et étincelles.
AnimationsForge.demarrer()
-- Effets en blocs des espèces (ambiance du biome, signatures, grosses tailles).
EffetsEspeces.demarrer()
-- Ambiance et nom du biome quand le joueur change de biome.
Ambiances.demarrer()

print(`{Config.NomDuJeu} : client démarré`)
