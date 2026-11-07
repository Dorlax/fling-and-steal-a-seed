#!/usr/bin/env bash
# Publie le build sur la place de test, puis lance les tests de tests/en-jeu
# dans un vrai serveur Roblox via Open Cloud (Luau Execution).
# Variables attendues : ROBLOX_API_KEY, UNIVERSE_ID, PLACE_ID.
set -euo pipefail
API="https://apis.roblox.com"
FICHIER="$1"

# 1. Publier et récupérer le numéro de version
VERSION=$(curl -sSf -X POST \
  "$API/universes/v1/$UNIVERSE_ID/places/$PLACE_ID/versions?versionType=Published" \
  -H "x-api-key: $ROBLOX_API_KEY" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @"$FICHIER" | jq -r .versionNumber)
echo "Place de test publiée : version $VERSION"

# 2. Lancer le lanceur de tests dans cette version
TACHE=$(curl -sSf -X POST \
  "$API/cloud/v2/universes/$UNIVERSE_ID/places/$PLACE_ID/versions/$VERSION/luau-execution-session-tasks" \
  -H "x-api-key: $ROBLOX_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"script": "return require(game.ServerScriptService.Tests.Lanceur)()"}' | jq -r .path)

# 3. Attendre le résultat (5 minutes maximum)
for _ in $(seq 1 60); do
  REP=$(curl -sSf "$API/cloud/v2/$TACHE" -H "x-api-key: $ROBLOX_API_KEY")
  case "$(echo "$REP" | jq -r .state)" in
    COMPLETE)         echo "$REP" | jq -r '.output.results[]'; exit 0 ;;
    FAILED|CANCELLED) echo "$REP" | jq -r '.error.message';    exit 1 ;;
  esac
  sleep 5
done
echo "Tests en jeu : délai dépassé"
exit 1
