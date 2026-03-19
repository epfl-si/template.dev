-include .env

-include .make.vars

# Auto-detected variables (computed once and stored until "make clean")
.make.vars:
	@echo _GITHUB_BASE = $(if $(shell ssh -T git@github.com 2>&1|grep 'successful'),git@github.com:,https://github.com/) >> $@

.PHONY: checkout
checkout: barcode-frontend barcode-backend

.PHONY: git-pull
git-pull: ## Walk down the directory to find repositories to update (with rebase!)
	@set -e; for dir in `$(_find_git_depots)`; do (cd $$dir; echo "$$(tput bold)$$dir$$(tput sgr0)"; git pull --rebase --autostash; echo); done


########################### Clone sub-repositories #############################
_git_clone = devscripts/ensure-git-clone.sh $(_GITHUB_BASE)$(strip $(1)) $@ $(2); touch $@

barcode-frontend:
	$(call _git_clone, epfl-si/barcode.frontend, main)

barcode-backend:
	$(call _git_clone, epfl-si/barcode.backend, main)
