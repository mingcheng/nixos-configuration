###
# File: Makefile
# Author: Ming Cheng<mingcheng@outlook.com>
# 
# Created Date: Wednesday, August 17th 2022, 10:14:18 am
# Last Modified: Wednesday, August 17th 2022, 10:14:58 am
# 
# http://www.opensource.org/licenses/MIT
###


.PHONY: fmt check check-docker-config check-git-config check-gui-packages check-x1-carbon-8th check-autopartten

NIX_EVAL = nix-instantiate --eval --strict --option allow-import-from-derivation false

fmt:
	@nix-shell -p nixfmt --run "find . -type f -iname '*.nix' -exec nixfmt {} +"

check: check-docker-config check-git-config check-gui-packages check-x1-carbon-8th check-autopartten
	@bash -n scripts/channel.sh scripts/nixconfig.sh

check-autopartten:
	@bash -n scripts/autopartten.sh
	@bash tests/autopartten.sh

check-docker-config:
	@$(NIX_EVAL) --json tests/docker-config.nix

check-git-config:
	@$(NIX_EVAL) --json tests/git-config.nix

check-gui-packages:
	@$(NIX_EVAL) --json tests/gui-packages.nix

check-x1-carbon-8th:
	@NIX_BUILD_HOST= $(NIX_EVAL) --expr 'assert !(builtins.tryEval (import ./main.nix)).success; "Empty host rejected"'
	@NIX_BUILD_HOST=unknown-host $(NIX_EVAL) --expr 'assert !(builtins.tryEval (import ./main.nix)).success; "Unknown host rejected"'
	@NIX_BUILD_HOST=x1-carbon-8th $(NIX_EVAL) --json tests/x1-carbon-8th.nix
