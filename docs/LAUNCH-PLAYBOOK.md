# PWA Launch Playbook

A repeatable process for shipping a static, no-build-step web app as an installable PWA on a custom domain. Extracted from the Marble launch ([WEB-music-marble](https://github.com/opencoca/WEB-music-marble)) — that repo is the reference implementation; copy its `Makefile`, `sw.js`, `manifest.webmanifest`, and `_headers` as starting points.

Every step is labelled **[WE]** (run from the CLI in-session, automated as a Makefile target where possible) or **[MANUALLY]** (dashboard clicks, physical devices, git pushes, DNS). The standing convention: **any [WE] step that can be scripted gets a Makefile target** — one command, reproducible by anyone on the team.

## Fill-in parameters

Collect these before starting:

| Parameter | Marble's value | Yours |
| --------- | -------------- | ----- |
| Canonical URL | `https://marble.startr.cloud/` | |
| App name / short name | Marble | |
| Tagline | Every bounce is a note. | |
| Theme + background color | `#1a1a1a` | |
| Host | Cloudflare Pages | |
| GitHub/Gitea repo | `opencoca/WEB-music-marble` | |
| Feedback address | mailto link | |

## Standard Makefile targets

`make help` lists these. Copy the recipes from Marble's Makefile and adjust paths:

- `icons` — rasterize all launcher icons from two SVG sources (rsvg-convert)
- `og` — render the 1200×630 Open Graph card from `assets/og.html` (headless Chrome)
- `screenshot-desktop` — capture the wide-form-factor manifest screenshot
- `serve` — local static server on port 8787
- `tunnel` — cloudflared HTTPS tunnel for on-device testing (iOS needs HTTPS for sensor permissions)
- `demo CLIP=...` — compress a raw screen recording to a shareable mp4 (ffmpeg)
- `verify-prod` — curl the deployed sw.js / manifest headers

## Phase A — Build the PWA locally (all [WE])

1. **Icons.** Author `icons/icon.svg` (rounded-square background + app motif; doubles as SVG favicon) and `icons/maskable.svg` (motif inside the inner 80% safe-zone circle, background full-bleed). `make icons` produces: `icon-192.png`, `icon-512.png`, `maskable-192.png`, `maskable-512.png`, `apple-touch-icon.png` (180, from the maskable source so iOS gets an opaque tile), `favicon-32.png`. No `.ico` needed.
2. **Manifest** (`manifest.webmanifest`): `name`, `short_name`, `id: "./"`, `start_url: "./"`, `scope: "./"`, `display: standalone`, theme/background colors, the four icons (plain + maskable), and `screenshots` with `form_factor` narrow/wide — screenshots give Android Chrome the app-store-style install sheet. The manifest can ship before screenshots exist; Chrome ignores 404 screenshots for installability.
3. **Service worker** (`sw.js`, ~40 lines, hand-written): cache-first over an explicit `SHELL` list, cache name derived from a `VERSION` constant, `skipWaiting` + `clients.claim`, old caches deleted on activate, navigations fall back to the cached shell when offline. Keep all SHELL paths **relative** so the app works from any origin or subpath. Do not precache marketing `assets/`. **Release rule: every content change bumps `VERSION`; users update on second load.**
4. **Head metadata** in `index.html`: description, `theme-color`, canonical link, manifest link, SVG + PNG favicons, apple-touch-icon, full Open Graph set (`og:image` 1200×630 as an absolute URL — OG and canonical are the *only* absolute URLs), `twitter:card`. Register the SW at the end of the main script.
5. **Storefront install panel** (Squoosh-inspired): two quiet entry points (a menu item + a pre-start ghost chip), both hidden by default; a full-screen panel with icon, tagline, blurb, lazy-loaded screenshot strip, feature facts line, and an Install button. State machine: already-standalone → everything stays hidden; Chromium → `beforeinstallprompt` stashed and re-fired from the panel button; iOS Safari → entry points always shown, Install button swapped for Share → Add to Home Screen steps; other browsers → no dead-end UI. Hide everything on `appinstalled`. Give screenshot `<img>`s `onerror="this.remove()"` so the strip degrades before captures exist.
6. **Launch-safe defaults**: no debug overlays on first load; permission denials degrade to in-copy guidance (never `alert()`), and the app still starts with whatever inputs remain.
7. **OG card**: `assets/og.html`, a deterministic 1200×630 static composition reusing the app's palette; `make og` renders it. Beats live screenshots for text legibility.
8. **Host cache config** (`_headers`, works on Cloudflare Pages and Netlify): `no-cache` on `/`, `/index.html`, `/sw.js`, and the manifest (this is what makes VERSION-bumping reliable); long max-age on icons/samples; a day on assets. Nginx equivalent if self-hosting, plus the `application/manifest+json` MIME type.
9. **Local smoke test**: `make serve`; check every SHELL URL returns 200, manifest parses (`python3 -m json.tool`), JS parses (`node --check`), and DevTools › Application shows the SW installed and an install prompt available. Offline reload must work.

## Phase B — Device validation pre-deploy

1. **[MANUALLY]** `make serve` + `make tunnel`; on a physical iPhone test the full start flow including permission **grant and deny** paths, audio unlock on the start gesture, and the iOS install instructions. On Android confirm the install chip appears and the panel installs to a standalone launch.

## Phase C — Storefront media

1. **[MANUALLY]** Capture 2 phone screenshots of the app's best moments; note exact pixel dimensions.
2. **[WE]** Normalize (`sips`), drop into `assets/`, correct the manifest `sizes` fields to reality.
3. **[MANUALLY]** Record a 15–30s demo clip on-device.
4. **[WE]** `make demo CLIP=<raw>` → compressed mp4 for social/listings.

## Phase D — Deploy and DNS

1. **[MANUALLY]** Commit and push (co-author trailer via `~/bin/ai-coauthor`).
2. **[MANUALLY]** Create the Pages/hosting project: framework preset None, no build command, output dir `/`.
3. **[MANUALLY]** Attach the custom domain. If the zone's DNS is already on Cloudflare, Pages auto-creates CNAME + TLS. Netlify/Vercel need a grey-cloud CNAME added by hand; Vercel also needs `vercel.json` for headers.
4. **[WE]** `make verify-prod` — confirm `Cache-Control: no-cache` on sw.js and the manifest Content-Type.

## Phase E — Production verification

1. **[WE]** Lighthouse against the production URL: installable, no manifest/SW errors.
2. **[MANUALLY]** Android: install via the in-app panel; native sheet shows icon + screenshots; maskable icon uncropped; standalone launch.
3. **[MANUALLY]** iOS: Add to Home Screen; standalone launch; sensor permission prompts still work inside standalone mode; audio unlocks on first gesture.
4. **[MANUALLY]** Offline: airplane mode, relaunch — full app including audio assets loads from cache.
5. **[MANUALLY]** Update path: bump `VERSION`, deploy, confirm clients update on second load.
6. **[WE]** Share-preview check of the OG card (e.g. opengraph.xyz).
7. **[WE]** Close out the repo's TODO.md and regenerate the kanban board.

## Post-launch backlog (standard items)

- Wire in in-house analytics (page views, `appinstalled` / `beforeinstallprompt` outcomes, start conversion) without adding dependencies.
- Define week-one success signals before the launch post goes out.
