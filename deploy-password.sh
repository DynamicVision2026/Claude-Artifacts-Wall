#!/usr/bin/env bash
# Simple deploy: Cloud Run + username/password. Run in Google Cloud Shell from the repo folder.
# Usage: ./deploy-password.sh PROJECT_ID [USERNAME] [REGION]
set -euo pipefail
PROJECT="${1:?usage: ./deploy-password.sh PROJECT_ID [USERNAME] [REGION]}"
USER_NAME="${2:-brian}"
REGION="${3:-asia-northeast1}"
SERVICE="product-wall"
[ -f site/content/z1/_README.md ] || { echo "site/content/ is missing. Unzip site-content.zip into site/ first."; exit 1; }
read -rsp "Choose a password for the wall (typing is hidden): " PASS; echo
[ "${#PASS}" -ge 8 ] || { echo "Use at least 8 characters."; exit 1; }
case "$PASS" in *,*) echo "Please don't use a comma in the password."; exit 1;; esac
gcloud config set project "$PROJECT"
gcloud run deploy "$SERVICE" --source . --region "$REGION" --allow-unauthenticated \
  --set-env-vars "AUTH_USER=${USER_NAME},AUTH_PASS=${PASS}"
# Turn off the earlier IAP setup (harmless if it was never on)
gcloud run services update "$SERVICE" --region "$REGION" --no-iap || true
gcloud run services describe "$SERVICE" --region "$REGION" --format='value(status.url)'
echo "Open the URL above. Username: ${USER_NAME}  Password: the one you just typed."
