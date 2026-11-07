# Instructions pour les agents

Ce dépôt est un jeu Roblox créé depuis le modèle « Pipeline Roblox Originelle ».
Code en Luau, synchronisé avec Rojo. Le jeu lui-même est décrit dans Plan/.

## Règles communes à tous les jeux
- Les règles propres à ce jeu sont dans Plan/Règles du jeu.md : toujours les respecter.
- Tout est original : aucun nom, personnage ou univers sous copyright.
- Ne modifier que ce que la demande demande.
- Toute logique importante (argent, dégâts, sauvegarde) tourne côté serveur.
- Le serveur ne fait jamais confiance aux données envoyées par le client.

## Contexte (coffre Obsidian)
- Plan/ : vision du jeu écrite par le propriétaire. Lecture seule.
- Demandes/ : une note par demande. Seul le champ « statut » se modifie.
- Maquettes/ : une maquette par demande, écrite par l'Architecte.
- Jeu/État du jeu.md : ce qui existe déjà dans le jeu.
- Vitrine/ : textes, miniatures et trailer, préparés par l'agent Vitrine.
- Utiliser les liens Obsidian [[Nom de la note]] entre notes.

## Économie de lecture
- Ne lire que les fichiers nécessaires à la tâche.
- Ne jamais lire CHANGELOG.md ni Vitrine/ (sauf l'agent Vitrine).
- Jeu/État du jeu.md est le résumé à jour du jeu : le lire plutôt que tout src/.

## Organisation du code
- src/server  -> ServerScriptService.Server
- src/client  -> StarterPlayer.StarterPlayerScripts.Client
- src/shared  -> ReplicatedStorage.Shared (modules purs, testables avec Lune)
- tests/unitaires -> tests Lune (logique pure, sans Roblox)
- tests/en-jeu    -> ServerScriptService.Tests (tests dans un vrai serveur)
- assets/     -> modèles .rbxm exportés de Studio (ne pas éditer à la main)

## Format des tests
Chaque fichier de test renvoie une table :
  return { ["C1 description du critère"] = function() assert(...) end }
Le préfixe C1, C2… reprend le numéro du critère de la maquette.

## Avant de terminer
1. `stylua src` puis `selene src` sans erreur.
2. `lune run tests/lanceur` réussit.
3. `rojo build default.project.json -o build/jeu.rbxl` réussit.
4. Ajouter une section datée dans CHANGELOG.md.
