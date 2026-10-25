#!/bin/bash
set -e

# Usage: [ENV_FILE=path] ./deploy.sh [--rebuild]
#   --rebuild   trigger a new image build before rolling out
#   ENV_FILE    env file for the DB secret (default: .env in the repo root)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="${ENV_FILE:-$REPO_ROOT/.env}"

# Ensure we're logged in
oc whoami &>/dev/null || { echo "Not logged in to Rahti. Run: oc login https://api.2.rahti.csc.fi:6443"; exit 1; }
echo "Deploying to project: $(oc project -q) (DB secret from $ENV_FILE)"

# Create secret from .env (idempotent)
echo "Applying DB secret..."
oc create secret generic volkslieder-db \
  --from-env-file="$ENV_FILE" \
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
  # Upload only what the image needs (keeps .env* files off the cluster)
  BUILD_DIR="$(mktemp -d)"
  trap 'rm -rf "$BUILD_DIR"' EXIT
  cp "$REPO_ROOT/Dockerfile" "$REPO_ROOT/.dockerignore" "$BUILD_DIR/"
  cp -R "$REPO_ROOT/runoregi" "$BUILD_DIR/"
  oc start-build volkslieder --from-dir="$BUILD_DIR" --follow
fi

echo ""
echo "Routes:"
oc get route volkslieder-runoregi \
  -o custom-columns='NAME:.metadata.name,HOST:.spec.host'
