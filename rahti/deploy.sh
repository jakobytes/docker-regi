#!/bin/bash
set -e

# Usage: ./deploy.sh [--rebuild]
#   --rebuild   trigger a new image build before rolling out

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Ensure we're logged in
oc whoami &>/dev/null || { echo "Not logged in to Rahti. Run: oc login https://api.2.rahti.csc.fi:6443"; exit 1; }

# Create secret from .env (idempotent)
echo "Applying DB secret..."
oc create secret generic volkslieder-db \
  --from-env-file="$REPO_ROOT/.env" \
  --dry-run=client -o yaml | oc apply -f -

# Apply manifests
echo "Applying manifests..."
oc apply -f "$SCRIPT_DIR/imagestream.yaml"
oc apply -f "$SCRIPT_DIR/buildconfig.yaml"
oc apply -f "$SCRIPT_DIR/deployment.yaml"
oc apply -f "$SCRIPT_DIR/services.yaml"
oc apply -f "$SCRIPT_DIR/routes.yaml"

# Optionally trigger a build
if [[ "$1" == "--rebuild" ]]; then
  echo "Starting image build from local source..."
  oc start-build volkslieder --from-dir="$REPO_ROOT" --follow
fi

echo ""
echo "Routes:"
oc get routes volkslieder-runoregi volkslieder-shiny \
  -o custom-columns='NAME:.metadata.name,HOST:.spec.host'
