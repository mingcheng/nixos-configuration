###
# File: Makefile
# Author: Ming Cheng<mingcheng@outlook.com>
# 
# Created Date: Wednesday, August 17th 2022, 10:14:18 am
# Last Modified: Wednesday, August 17th 2022, 10:14:58 am
# 
# http://www.opensource.org/licenses/MIT
###


SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := check

NIX_EVAL = env -u NIXPKGS_ALLOW_UNFREE nix-instantiate --eval --strict --option allow-import-from-derivation false
LOCAL_CONFIG ?= $(CURDIR)/configuration.nix
NIX_SOURCES := main.nix sources.nix hosts packages profiles services system tests
MODULE_CHECKS := $(patsubst tests/modules/%.nix,check-module-%,$(wildcard tests/modules/*.nix))
HOSTS := $(patsubst hosts/%/default.nix,%,$(wildcard hosts/*/default.nix))
HOST_CHECKS := $(patsubst tests/hosts/%.nix,check-host-%,$(wildcard tests/hosts/*.nix))
SCRIPT_CHECKS := $(patsubst tests/scripts/%.sh,check-script-%,$(wildcard tests/scripts/*.sh))
HEADLESS_CHECKS := check-module-gui-headless check-host-vm-image check-host-usb-boot-stick

.PHONY: fmt check check-syntax check-nix-syntax check-shell-syntax \
	check-modules check-hosts check-host-selection check-scripts check-local \
	$(MODULE_CHECKS) $(HOST_CHECKS) $(SCRIPT_CHECKS) \
	check-docker-config check-git-config check-gui-packages check-x1-carbon-8th

fmt:
	@nix-shell -p nixfmt --run "find $(NIX_SOURCES) -type f -name '*.nix' ! -path 'hosts/vm-image/local.nix' -exec nixfmt {} +"

check: check-syntax check-modules check-hosts check-scripts

check-syntax: check-nix-syntax check-shell-syntax

check-nix-syntax:
	@find $(NIX_SOURCES) -type f -name '*.nix' -print0 | xargs -0 -n1 nix-instantiate --parse > /dev/null

check-shell-syntax:
	@for script in scripts/*.sh tests/scripts/*.sh; do bash -n "$$script" || exit; done

check-modules: $(MODULE_CHECKS)

check-hosts: check-host-selection $(HOST_CHECKS)

$(HEADLESS_CHECKS): CHANNEL_FLAGS = -I unstable="$(CURDIR)/tests/fixtures/no-unstable.nix"

$(MODULE_CHECKS): check-module-%: tests/modules/%.nix
	@$(NIX_EVAL) $(CHANNEL_FLAGS) --json $<

$(HOST_CHECKS): check-host-%: tests/hosts/%.nix
	@NIX_BUILD_HOST=$* $(NIX_EVAL) $(CHANNEL_FLAGS) --json $<

check-host-selection:
	@env -u NIX_BUILD_HOST $(NIX_EVAL) --json tests/selection.nix
	@for host in "" unknown-host "x1-carbon-8th/../x1-carbon-8th" $(HOSTS); do \
		NIX_BUILD_HOST="$$host" $(NIX_EVAL) --json tests/selection.nix || exit; \
	done

check-scripts: $(SCRIPT_CHECKS)

$(SCRIPT_CHECKS): check-script-%: tests/scripts/%.sh
	@bash $<

check-local:
	@$(NIX_EVAL) --json tests/local.nix --argstr configuration "$(abspath $(LOCAL_CONFIG))"

check-docker-config: check-module-docker
check-git-config: check-module-packages
check-gui-packages: check-module-gui check-module-gui-headless
check-x1-carbon-8th: check-host-selection check-host-x1-carbon-8th
