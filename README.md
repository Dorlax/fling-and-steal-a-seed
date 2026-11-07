# Pipeline Roblox Originelle

Modèle de dépôt pour créer des jeux Roblox avec une équipe d'agents Claude.
Tu écris le plan et tes demandes dans Obsidian. Les agents codent, testent et relisent.
Toi, tu vérifies et tu mets en ligne.

## Tes gestes

1. **Demander** : une note dans `Demandes/` (modèle « Demande »), statut `prêt`.
   `taille: petite` pour une retouche simple (mode express, moins de tokens).
2. **Vérifier** : lire le rapport dans la pull request, jouer 2 minutes sur la place de test, cliquer « Merge ».
3. **Mettre en ligne** : onglet Actions, « Mise en ligne », bouton « Approve ».
4. **Vitrine** (quand tu veux) : une note avec le modèle « Vitrine », statut `prêt`.
   Puis production des visuels sur ton PC, choix et publication.

## Le circuit

```
Note « prêt » ─► Architecte (maquette) ─► Testeur (tests) ─► Bâtisseur (code)
                                                               │
   ┌───────────── boucle qualité : tout échec revient ici ◄────┤
   │                                                           ▼
   │   Vérifications (StyLua, Selene, luau-lsp, Lune, Rojo) ─► Tests en jeu (place de test)
   │                                                           ▼
   └──────────────────────────────────────────────── Relecteur (preuve par critère)
                                                               ▼
                         Contexte (mémoire + rapport) ─► TOI : vérifier, Merge
                                                               ▼
                            TOI : Approve ─► Production (archivée) ─► Vitrine
```

## Installation sur ton PC (une seule fois)

| Logiciel | Pourquoi |
|---|---|
| Git for Windows (avec Git LFS) | Envoyer et recevoir le dépôt |
| Rokit | Installe Rojo, Selene, StyLua, Lune et luau-lsp aux versions de `rokit.toml` (`rokit install`) |
| Plugin Rojo pour Roblox Studio | Synchroniser le code du dépôt avec Studio en direct (`rojo serve`) |
| Obsidian + plugin communautaire « Git » | Écrire plan et demandes, synchronisés avec GitHub |
| Claude Code (terminal) | `claude setup-token` et `/install-github-app` |
| OBS Studio (facultatif) | Enregistrer des clips de gameplay pour le trailer |
| VS Code + extensions « Luau Language Server » et « Rojo » (facultatif) | Lire le code confortablement. Pas obligatoire : les agents codent |

Roblox Studio et Blender (avec leurs connexions MCP pour Claude) servent à la phase Vitrine
et au travail visuel (décor, modèles 3D).

## Mise en place du modèle (une seule fois)

1. Créer une organisation GitHub gratuite qui contiendra tous tes jeux.
2. Y pousser ce dépôt sous le nom `pipeline-roblox`, puis Settings, cocher « Template repository ».
3. Générer le token Claude : `claude setup-token`.
4. Créer un jeton GitHub personnel (fine-grained) avec les droits Issues, Contents et Actions en écriture sur l'organisation.
5. Dans l'organisation, Settings, Secrets and variables, Actions : ajouter
   `CLAUDE_CODE_OAUTH_TOKEN` et `AGENTS_TOKEN`. Chaque nouveau jeu en hérite.

## Pour chaque nouveau jeu

1. Sur `pipeline-roblox`, cliquer « Use this template » et nommer le dépôt.
2. Cloner le dépôt, puis lancer `rokit install` dans son dossier.
3. Ouvrir le dossier comme coffre dans Obsidian. Activer le plugin Git :
   « Pull on startup » et synchro automatique toutes les 5 minutes.
4. Remplir `Plan/Vision.md` et `Plan/Règles du jeu.md`. Changer `NomDuJeu` dans `src/shared/Config.luau`.
5. Créer deux expériences sur Roblox : le jeu, et sa version « Test » (privée).
6. Créer une clé Open Cloud (Creator Dashboard, Open Cloud, API Keys) avec
   `universe-places : write` et `universe.place.luau-execution-session : write` sur les deux expériences.
   L'ajouter comme secret `ROBLOX_API_KEY` du dépôt.
7. Installer l'app Claude sur le dépôt : `/install-github-app` dans Claude Code.
8. Settings, Environments : créer `test` et `production`, chacun avec les variables
   `UNIVERSE_ID` et `PLACE_ID` de l'expérience correspondante.
   Sur `production`, cocher « Required reviewers » et te mettre.
9. Onglet Actions, workflow « Installation », Run workflow (crée les labels).
10. Écrire ta première note dans `Demandes/`.

## Le décor et les modèles 3D

Rojo publie uniquement ce qui est dans le dépôt. Le décor construit dans Studio doit être
exporté en `.rbxm` dans `assets/` puis déclaré dans `default.project.json`, par exemple :

```json
"Workspace": {
  "$className": "Workspace",
  "Monde": { "$path": "assets/monde.rbxm" }
}
```

Sans ça, chaque publication remplace le jeu par une carte vide. Vérifier sur la place de test
avant toute mise en production.

## Économiser tes tokens Claude

Tout le reste est gratuit (GitHub Actions : 2 000 min/mois en privé). Ce qui est déjà réglé :

| Levier | Où |
|---|---|
| Modèle adapté à chaque agent : fort (Architecte, Bâtisseur), moyen (Testeur, Relecteur), léger (Contexte, Vitrine) | Variables d'organisation `MODELE_FORT`, `MODELE_MOYEN`, `MODELE_LEGER` (facultatives, valeurs par défaut dans les workflows) |
| Mode express : `taille: petite` saute l'Architecte et le Testeur | Note de demande |
| Limite de tours par agent (`--max-turns`) et 3 corrections maximum | `agents.yml`, fiches des agents |
| Lecture minimale : le Relecteur lit le diff, le Bâtisseur ne reçoit que les lignes d'erreur | `agents.yml`, `relecteur.md` |
| Mémoire courte : `Jeu/État du jeu.md` limité à 60 lignes, détail dans `CHANGELOG.md` (jamais lu) | `contexte.md`, `CLAUDE.md` |
| Demandes groupées : plusieurs retouches dans une note = un seul cycle | Modèle « Demande » |
| Vitrine à la demande seulement | `vitrine.yml` |

Ton abonnement a aussi une limite par fenêtre de 5 heures : étale les demandes plutôt que d'en lancer 10 d'un coup.

## Sécurité

- Ne jamais écrire une clé ou un token dans un fichier : uniquement dans les secrets GitHub.
- La production exige toujours ton approbation.
- Un mauvais déploiement : Actions, « Retour arrière », choisir la version dans l'onglet Releases.
