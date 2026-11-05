#!/usr/bin/env bash
# Deploy the Product Wall to Cloud Run behind Google login (Identity-Aware Proxy).
# Run in Google Cloud Shell from the repo folder, after unzipping site-content.zip into site/content/.
# Usage: ./deploy.sh PROJECT_ID you@gmail.com [REGION]
set -euo pipefail
PROJECT="${1:?usage: ./deploy.sh PROJECT_ID EMAIL [REGION]}"
EMAIL="${2:?usage: ./deploy.sh PROJECT_ID EMAIL [REGION]}"
REGION="${3:-asia-northeast1}"
SERVICE="product-wall"

[ -f site/content/z1/_README.md ] || { echo "site/content/ is missing. Unzip site-content.zip into site/ first."; exit 1; }

gcloud config set project "$PROJECT"
gcloud services enable run.googleapis.com iap.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com

# 1. Deploy (private: no public access)
gcloud run deploy "$SERVICE" --source . --region "$REGION" --no-allow-unauthenticated

# 2. Turn on IAP directly on the Cloud Run service
gcloud run services update "$SERVICE" --region "$REGION" --iap

# 3. Let IAP call the service
PROJECT_NUMBER="$(gcloud projects describe "$PROJECT" --format='value(projectNumber)')"
gcloud run services add-iam-policy-binding "$SERVICE" --region "$REGION" \
  --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-iap.iam.gserviceaccount.com" \
  --role="roles/run.invoker"

# 4. Allow your Google account through the login
gcloud iap web add-iam-policy-binding \
  --member="user:${EMAIL}" --role="roles/iap.httpsResourceAccessor" \
  --region="$REGION" --resource-type=cloud-run --service="$SERVICE"

gcloud run services describe "$SERVICE" --region "$REGION" --format='value(status.url)'
echo "Open the URL above. You will be asked to sign in with ${EMAIL}."
