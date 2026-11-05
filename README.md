# Claude Artifacts Wall

A "Product Wall" of 142 Claude artifacts and documents, sorted into 15 product channels and 6 teams. Each card opens its full content on a detail page. The site is a static page served by nginx on **Google Cloud Run**, locked behind a **Google login** (Identity-Aware Proxy).

```
site/index.html      the wall (cards, team filter, search, "check placement")
site/view.html       detail page: renders .md, shows .html in a frame, tabs when a card has 2+ files
site/data.json       card list: [id, title, channel, team, date, guessed?, files[]]
site/vendor/         marked.min.js (markdown renderer, bundled)
site/content/        the exported documents  <-- NOT in this repo, see below
Dockerfile, nginx.conf.template, deploy.sh
```

## Why `site/content/` is not in GitHub

This repo is public. The documents hold pricing, launch plans and other business detail, so they are git-ignored and travel separately as `site-content.zip`. The wall itself (titles and structure) is in the repo. If you make the repo private, delete the `site/content/` line in `.gitignore` and commit the folder.

## Deploy (Google Cloud Shell, about 10 minutes)

1. Open https://shell.cloud.google.com and pick or create a Google Cloud project that has billing on.
2. In Cloud Shell: `git clone https://github.com/DynamicVision2026/Claude-Artifacts-Wall && cd Claude-Artifacts-Wall`
3. Upload `site-content.zip` (Cloud Shell menu ⋮ → Upload), then: `unzip ~/site-content.zip -d site/`
4. `./deploy.sh YOUR_PROJECT_ID you@gmail.com asia-northeast1`

The script deploys a private Cloud Run service, turns on IAP directly on it, lets IAP call it, and allows your Google account. Open the printed URL and sign in.

First-time notes (from Google's Cloud Run IAP guide):
- Without a Google Workspace organization, IAP needs an OAuth consent screen and a Web-application OAuth client. Easiest: once, open the service in Cloud Console and switch on Identity-Aware Proxy there, which creates them for you.
- If enabling IAP the first time fails with "Setting IAM permissions failed", run the `--iap` step again.
- To add someone: `gcloud iap web add-iam-policy-binding --member=user:EMAIL --role=roles/iap.httpsResourceAccessor --region=REGION --resource-type=cloud-run --service=product-wall`

## What the content is

Three exports from the Claude account: Oct 5–23, a first export through Oct 6, and Oct 24 – Nov 1. Known limits:
- Design canvases (Beyond Culture Necklace, Ops dashboard preview, and similar) were exported as source only. The detail page shows the source and a link to the original.
- Some documents were rebuilt from text, so they can differ by a few bytes from the original.
- 14 cards are placed by guess (dashed border on the wall). Two are unsorted.
