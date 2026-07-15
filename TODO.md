# TODO - Marble Simulation

> **Convention** — Sections below map to kanban columns. Inline source-code tags use the same vocabulary so items stay cross-referenced between this file and the codebase. `KANBAN.canvas` auto-generates from this file and inline tags — do not hand-edit it.
>
> | Column      | Markdown section            | Inline tag  |
> |-------------|-----------------------------|-------------|
> | Backlog     | `## Backlog`                |             |
> | TODO        | `## TODO`                   | `# TODO:`   |
> | In Progress | `## In Progress`            | `# FIXME:`  |
> | Bugs        | `## Bugs`                   | `# BUG:`    |
> | Done        | `- [x]` items / `## Done`   | —           |
>
> `# DEPRECATED:` tags should be tracked as TODO items for removal at the stated version.

## In Progress

- [ ] **Launch Readiness Pass**: Close the final blockers before shipping the single-page PWA
  - [x] Decide what must ship now versus what stays in backlog (everything in Go To Market ships; analytics deferred to Backlog)
  - [ ] [MANUALLY] Verify motion, audio, and mute controls on current iPhone and Android browsers (`make serve` + `make tunnel`, test grant AND deny paths)
  - [ ] [MANUALLY] Confirm the mobile start flow is clear on first load (on-device)

## TODO

### Go To Market

- [ ] **PWA Installability**: Make the app install cleanly from mobile and desktop browsers
  - [x] Add a manifest with name, icons, theme color, and display mode (`manifest.webmanifest`)
  - [x] Add a service worker so the app can load as a PWA (`sw.js`, cache-first shell, VERSION-bump invalidation)
  - [x] Squoosh-style storefront install panel with beforeinstallprompt flow and iOS A2HS fallback
  - [ ] [MANUALLY] Validate install prompts and standalone launch behavior on real devices

- [ ] **Storefront Assets**: Prepare the media needed to share and list the app
  - [x] Create icon exports sized for web app and sharing use (`make icons`)
  - [x] Desktop screenshot + Open Graph card (`make og`, `make screenshot-desktop`)
  - [ ] [MANUALLY] Capture mobile screenshots that show the marble, contour ring, and menu — then update `sizes` in `manifest.webmanifest` to the real dimensions
  - [ ] [MANUALLY] Record a short demo clip with tilt and touch interactions (compress with `make demo CLIP=...`)

- [ ] **Distribution Setup**: Put the app on a stable public URL with launch-safe defaults
  - [x] Choose the production host and canonical URL (Cloudflare Pages, `marble.startr.cloud`)
  - [x] Add basic metadata for title, description, Open Graph, and favicon
  - [x] Launch-safe defaults (debug panel off by default; graceful motion-permission denial)
  - [ ] [MANUALLY] Create the Cloudflare Pages project (preset None, no build command) and attach `marble.startr.cloud`
  - [ ] Smoke test HTTPS, orientation permission flow, and audio unlock on the production URL (`make verify-prod` + on-device checks)

- [ ] **Analytics & Feedback**: Learn what happens after launch without bloating the app
  - [x] Decided — no analytics at launch; measurement stays manual for week one
  - [x] Add a lightweight feedback link (mailto in the About menu section)
  - [ ] Define the success signals for week one after launch

- [ ] **TodoScope Alignment**: Finish aligning repo housekeeping to the board workflow
  - [x] Review `.todoscope-exclude.csv` (added `icons/` and `assets/` generated-media rows)
  - [ ] Run TodoScope and verify the kanban columns map as expected — currently blocked: the `todoscope` CLI is a dangling editable install (source dir `~/bin/repo_scanner/` no longer exists); reinstall from its current home first

## Backlog

### Product Polish

- [ ] **Menu UX Cleanup**: Polish hamburger menu styling, layout, and feel
  - [ ] Improve touch targets on mobile
  - [ ] Visual feedback and overall polish

- [ ] **Launch Follow-Up Ideas**: Queue post-launch improvements without blocking release
  - [ ] Consider a shareable permalink or scoreless replay hook
  - [ ] Explore additional percussion sets beyond the current wood block palette
  - [ ] Evaluate a lightweight onboarding overlay if first-use confusion remains

### Infrastructure

- [ ] **Git-pages service research**: Evaluate a self-hosted rawgit-style service that serves any of our git repos (GitHub and Gitea) as static pages — routing scheme, caching, Content-Type handling, and whether Marble's relative-URL discipline lets it run there unmodified
- [ ] **Prefresh analytics integration**: Wire in the in-house "prefresh" analytics post-launch — page views, install events (appinstalled / beforeinstallprompt outcomes), start-button conversion — keeping the no-dependency footprint

## Bugs

_No known bugs. Use `# BUG:` inline tags to flag defects in source._

## Done

- [x] **Marble Physics & Rendering**: Canvas-based marble with tilt/keyboard controls
- [x] **Wood Block Collision Sounds**: Synthetic pentatonic wood block sounds per wall
  - [x] C major pentatonic: C5 (left), D5 (right), E5 (top), G5 (bottom)
  - [x] Velocity-scaled volume
- [x] **Surface-Bending Gravity**: Gaussian surface warp with pop-on-release
  - [x] Toggleable between surface bend and point attractor
  - [x] Contour ring visualization
- [x] **Real Sample Audio**: Freewavesamples.com woodblock, pitch-shifted per wall
  - [x] Sample loads on init, toggle enables it
  - [x] Synthetic fallback always available
- [x] **Launch Messaging**: Title/tagline on the start overlay, device-specific control instructions shown before start, one-paragraph product description (README + og:description)
- [x] **Launch Automation**: Startr-convention Makefile (`make help`) with icons/og/screenshot/serve/tunnel/demo/verify-prod targets; launch process generalized in `docs/LAUNCH-PLAYBOOK.md`
