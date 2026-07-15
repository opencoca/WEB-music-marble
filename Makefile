# 1. help (default target — must come first)
help:
	@echo "================================================"
	@echo "       $(OWNER)/$(PROJECT_NAME) by Startr.Cloud"
	@echo "================================================"
	@echo "This is the default make command."
	@echo "This command lists available make commands."
	@echo ""
	@echo "Usage example:"
	@echo "    make serve"
	@echo ""
	@echo "Available make commands:"
	@echo ""
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | \
		awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ { \
		if ($$1 !~ "^[#.]") {print $$1}}' | \
		sort | \
		grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'
	@echo ""

# 2. Dynamic variable extraction (mirrors startr.sh)
PROJECTPATH := $(shell git rev-parse --show-toplevel)
PROJECT     := $(shell echo $$(basename $(PROJECTPATH)) | tr '[:upper:]' '[:lower:]')
# Use symbolic-ref (clean failure on empty repos) → short SHA (detached HEAD) → develop fallback.
# Do NOT use `git rev-parse --abbrev-ref HEAD` — it prints "HEAD" to stdout AND fails on a
# no-commits repo, producing a corrupted "HEAD develop" value.
FULL_BRANCH := $(shell git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo "develop")
BRANCH      := $(shell echo $(FULL_BRANCH) | sed 's/.*\///' | tr '[:upper:]' '[:lower:]')
TAG         := $(shell git describe --always --tag 2>/dev/null || echo "v0.0.0")

# Owner and project name extracted from git remote URL
REMOTE_URL   := $(shell git config --get remote.origin.url 2>/dev/null || echo "unknown/unknown")
OWNER        := $(shell echo $(REMOTE_URL) | sed -E 's|.*[:/]([^/]+)/[^/]+(.git)?$$|\1|')
PROJECT_NAME := $(shell echo $(REMOTE_URL) | sed -E 's|.*[:/][^/]+/([^/]+)(.git)?$$|\1|' | sed 's/\.git$$//')

# Container name (used by Docker block if present)
CONTAINER := $(PROJECT)-$(BRANCH)

# 3. Load environment overrides from .env if present
-include .env

# 4. Project-specific launch automation (see docs/LAUNCH-PLAYBOOK.md)
CHROME   := /Applications/Google Chrome.app/Contents/MacOS/Google Chrome
PORT     := 8787
PROD_URL := https://marble.startr.cloud

ICON_PNGS := icons/icon-192.png icons/icon-512.png \
	icons/maskable-192.png icons/maskable-512.png \
	icons/apple-touch-icon.png icons/favicon-32.png

icons: $(ICON_PNGS)
	@echo "OK: all launcher icons rendered."

icons/icon-%.png: icons/icon.svg
	rsvg-convert -w $* -h $* $< -o $@

icons/maskable-%.png: icons/maskable.svg
	rsvg-convert -w $* -h $* $< -o $@

icons/apple-touch-icon.png: icons/maskable.svg
	rsvg-convert -w 180 -h 180 $< -o $@

icons/favicon-32.png: icons/icon.svg
	rsvg-convert -w 32 -h 32 $< -o $@

og: assets/og-image.png

assets/og-image.png: assets/og.html
	"$(CHROME)" --headless --screenshot=$@ --window-size=1200,630 \
		--hide-scrollbars "file://$(PROJECTPATH)/assets/og.html"

screenshot-desktop:
	@python3 -m http.server $(PORT) --directory $(PROJECTPATH) >/dev/null 2>&1 & \
	SERVER_PID=$$!; \
	sleep 1; \
	"$(CHROME)" --headless --screenshot=assets/screenshot-desktop-1.png \
		--window-size=1280,800 --hide-scrollbars --virtual-time-budget=3000 \
		"http://localhost:$(PORT)/"; \
	kill $$SERVER_PID

# In-app captures. Gameplay shots load capture-tmp.html — a throwaway copy of
# index.html with assets/capture.js appended, which auto-starts the sim and
# holds a gravity well so the marble orbits. The start-screen shot is plain
# index.html. Phone shots render at 390x844 @3x = 1170x2532 physical px,
# matching the manifest's narrow-form-factor sizes.
IPHONE_UA := Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1

screenshots:
	@python3 -m http.server $(PORT) --directory $(PROJECTPATH) >/dev/null 2>&1 & \
	SERVER_PID=$$!; \
	sleep 1; \
	sed 's|</body>|<script src="assets/capture.js"></script></body>|' index.html > capture-tmp.html; \
	"$(CHROME)" --headless --screenshot=assets/screenshot-phone-1.png \
		--window-size=390,844 --force-device-scale-factor=3 --hide-scrollbars \
		--user-agent="$(IPHONE_UA)" --virtual-time-budget=6000 \
		"http://localhost:$(PORT)/capture-tmp.html#play"; \
	"$(CHROME)" --headless --screenshot=assets/screenshot-phone-2.png \
		--window-size=390,844 --force-device-scale-factor=3 --hide-scrollbars \
		--user-agent="$(IPHONE_UA)" --virtual-time-budget=3000 \
		"http://localhost:$(PORT)/"; \
	"$(CHROME)" --headless --screenshot=assets/screenshot-desktop-1.png \
		--window-size=1280,800 --hide-scrollbars --virtual-time-budget=6000 \
		"http://localhost:$(PORT)/capture-tmp.html#play"; \
	rm -f capture-tmp.html; \
	kill $$SERVER_PID

serve:
	python3 -m http.server $(PORT) --directory $(PROJECTPATH)

tunnel:
	cloudflared tunnel --url http://localhost:$(PORT)

# Usage: make demo CLIP=path/to/raw-clip.mov
demo:
	@test -n "$(CLIP)" || { echo "Usage: make demo CLIP=path/to/raw-clip.mov"; exit 1; }
	ffmpeg -i "$(CLIP)" -vf "scale=-2:720" -c:v libx264 -crf 28 -preset slow \
		-c:a aac -b:a 96k -movflags +faststart assets/demo.mp4

verify-prod:
	@echo "== sw.js (expect Cache-Control: no-cache) =="
	@curl -sI $(PROD_URL)/sw.js | grep -iE '^HTTP|cache-control'
	@echo "== manifest.webmanifest (expect manifest Content-Type + no-cache) =="
	@curl -sI $(PROD_URL)/manifest.webmanifest | grep -iE '^HTTP|cache-control|content-type'
	@echo "== index (expect 200) =="
	@curl -s -o /dev/null -w "%{http_code}\n" $(PROD_URL)/

# 8. show_vars + verify (debug / one-shot self-check)
show_vars:
	@echo "=== Dynamic Variables ==="
	@echo "PROJECTPATH=$(PROJECTPATH)"
	@echo "PROJECT=$(PROJECT)"
	@echo "OWNER=$(OWNER)"
	@echo "PROJECT_NAME=$(PROJECT_NAME)"
	@echo "FULL_BRANCH=$(FULL_BRANCH)"
	@echo "BRANCH=$(BRANCH)"
	@echo "TAG=$(TAG)"
	@echo "CONTAINER=$(CONTAINER)"
	@echo "REMOTE_URL=$(REMOTE_URL)"
	@echo ""

# One-shot scaffold self-check. Bundles every read-only verification into a
# single make invocation so post-scaffold testing isn't N separate processes.
verify: show_vars require_gitflow_next
	@echo "=== Targets defined in this Makefile ==="
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | \
		awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ { \
		if ($$1 !~ "^[#.]") {print "  " $$1}}' | \
		sort -u | \
		grep -E -v -e '^  [^[:alnum:]]'
	@echo ""
	@echo "OK: Makefile scaffold verified."

# 9. Git-flow-next release/hotfix flow
require_gitflow_next:
	@if ! git flow version 2>/dev/null | grep -q 'git-flow-next'; then \
		echo "Error: git-flow-next required (Go rewrite). Install: brew install git-flow-next"; \
		exit 1; \
	fi

minor_release: require_gitflow_next
	# Start a minor release with incremented minor version
	git flow release start $$(git tag --sort=-v:refname | sed 's/^v//' | head -n 1 | awk -F'.' '{print $$1"."$$2+1".0"}') && echo "or use 'make release_finish' to finish the release"

patch_release: require_gitflow_next
	# Start a patch release with incremented patch version
	git flow release start $$(git tag --sort=-v:refname | sed 's/^v//' | head -n 1 | awk -F'.' '{print $$1"."$$2"."$$3+1}') && echo "or use 'make release_finish' to finish the release"

major_release: require_gitflow_next
	# Start a major release with incremented major version
	git flow release start $$(git tag --sort=-v:refname | sed 's/^v//' | head -n 1 | awk -F'.' '{print $$1+1".0.0"}') && echo "or use 'make release_finish' to finish the release"

hotfix: require_gitflow_next
	# Start a hotfix with incremented n.n.n.n version (incrementing the fourth number)
	git flow hotfix start $$(git tag --sort=-v:refname | sed 's/^v//' | head -n 1 | awk -F'.' '{print $$1"."$$2"."$$3"."$$4+1}') && echo "or use 'make hotfix_finish' to finish the hotfix"

release_finish: require_gitflow_next
	git flow release finish && git push origin develop && git push origin master && git push --tags && git checkout develop

hotfix_finish: require_gitflow_next
	git flow hotfix finish && git push origin develop && git push origin master && git push --tags && git checkout master

# 10. things_clean
things_clean:
	git clean --exclude='!.env*' -Xdf

# 11. .PHONY declarations
.PHONY: help show_vars verify require_gitflow_next \
	minor_release patch_release major_release hotfix \
	release_finish hotfix_finish things_clean \
	icons og screenshot-desktop screenshots serve tunnel demo verify-prod
