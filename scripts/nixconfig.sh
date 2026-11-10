#!/usr/bin/env bash
###
# File: nixconfig.sh
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 2:38:16 pm
# Last Modified: Thursday, August 18th 2022, 2:40:02 pm
#
# http://www.opensource.org/licenses/MIT
###

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
bash "$script_dir/channel.sh" "$@"

substituters=$(nix --extra-experimental-features nix-command eval --raw \
	--file "$script_dir/../sources.nix" substituters \
	--apply 'builtins.concatStringsSep " "')
mkdir -p "$HOME/.config/nix"
printf 'substituters = %s\n' "$substituters" >"$HOME/.config/nix/nix.conf"

if (($# == 0)); then
	nix-channel --update nixos unstable
else
	nix-channel --update "$1"
fi
