-include .env

-include .make.vars

# Auto-detected variables (computed once and stored until "make clean")
.make.vars:
	@echo _GITHUB_BASE = $(if $(shell ssh -T git@github.com 2>&1|grep 'successful'),git@github.com:,https://github.com/) >> $@

.PHONY: help
help:
	@echo "Main:"
	@echo "  make help                 — Display this help"
	@echo "  make print-env            — Print environment variables"
	@echo "Sub-Repositories:"
	@echo "  make checkout             — Clone all sub-repositories if not already cloned"
	@echo "  make git-pull             — Update all sub-repositories with git pull --rebase"
	@echo "Setup:"
	@echo "  make install-backend      — Install the backend dependencies"
	@echo "  make install              — Install all dependencies"
	@echo "App:"
	@echo "  make start-db             — Start the database with Docker Compose"
	@echo "  make stop-db              — Stop the database with Docker Compose"
	@echo "  make start-backend        — Start the backend development server"

# To add all variable to your shell, use
# export $(xargs < /keybase/team/epfl_lil/frontend/env);
check-env:
ifeq ($(wildcard /keybase/team/epfl_lil/frontend/local/env),)
	@echo "Be sure to have access to /keybase/team/epfl_lil/frontend/local/env"
	@exit 1
else
include /keybase/team/epfl_lil/frontend/local/env
export
endif

.PHONY: print-env
print-env: check-env
	@echo "LIL_REACT_APP_AUTH_SERVER_URL=${LIL_REACT_APP_AUTH_SERVER_URL}"
	@echo "LIL_REACT_APP_HOMEPAGE_URL=${LIL_REACT_APP_HOMEPAGE_URL}"
	@echo "LIL_REACT_APP_GRAPHQL_ENDPOINT_URL=${LIL_REACT_APP_GRAPHQL_ENDPOINT_URL}"
	@echo "LIL_REACT_APP_ENDPOINT_URL=${LIL_REACT_APP_ENDPOINT_URL}"
	@echo "LIL_OIDC_SCOPE=${LIL_OIDC_SCOPE}"
	@echo "LIL_OIDC_CLIENT_ID=${LIL_OIDC_CLIENT_ID}"

######## Sub-Repositories

_git_clone = devscripts/ensure-git-clone.sh $(_GITHUB_BASE)$(strip $(1)) $@ $(2); touch $@

barcode-frontend:
	$(call _git_clone, epfl-si/barcode.frontend, main)

barcode-backend:
	$(call _git_clone, epfl-si/barcode.backend, main)

.PHONY: checkout
checkout: barcode-frontend barcode-backend

_find_git_depots := find . \( -path ./volumes -prune -false \) -o -name .git -prune |xargs -n 1 dirname|grep -v 'ansible-deps-cache'
.PHONY: git-pull
git-pull: ## Walk down the directory to find repositories to update (with rebase!)
	@set -e; for dir in `$(_find_git_depots)`; do (cd $$dir; echo "$$(tput bold)$$dir$$(tput sgr0)"; git pull --rebase --autostash; echo); done

######## Setup

.PHONY: install-backend
install-backend: barcode-backend
	cd barcode-backend && npm install && npx prisma generate

.PHONY: install
install: install-backend

######## App

.PHONY: start-db
start-db:
	@docker compose up

.PHONY: stop-db
stop-db:
	@docker compose down

.PHONY: start-backend
start-backend: barcode-backend
	cd barcode-backend && npm run dev
