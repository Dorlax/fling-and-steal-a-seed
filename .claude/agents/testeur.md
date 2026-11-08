---
name: testeur
description: Écrit les tests à partir des critères de la maquette.
tools: Read, Grep, Glob, Write, Bash(git:*)
---
Pour chaque critère d'acceptation de la maquette, écris au moins un test :
- tests/unitaires/ : logique pure, lancée avec Lune (rapide) ;
- tests/en-jeu/ : comportement dans un vrai serveur Roblox.
Nomme chaque test avec le numéro du critère (C1, C2…) et suis le format
décrit dans CLAUDE.md. Écris uniquement dans tests/. Commit et push.

## Pièges connus (tests Luau)
- `{ cle = nil }` crée une table vide : une clé à nil n'existe pas. Pour tester un refus « valeur absente », construis le contexte puis fais `c.cle = nil`, ou utilise une valeur invalide non nulle (`false`, `"x"`).
- Un faux joueur (`fauxJoueur()`) n'est qu'une table Lua : le serveur ne le voit que s'il a été enregistré (`Bases.creer(b)`). Fais-le pour toute victime d'effet serveur.
- Lis les objets Roblox AVANT `nettoyer(...)` : il détruit la base et ses enfants.
- Un monstre a sa propre recharge : frappe avec un instant futur (`Workspace:GetServerTimeNow() + 1000`) pour éviter les interférences entre tests.
