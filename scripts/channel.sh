#!/usr/bin/env bash
###
# File: channel.sh
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Tuesday, August 16th 2022, 12:38:55 am
# Last Modified: Friday, December 2nd 2022, 4:51:40 pm
#
# http://www.opensource.org/licenses/MIT
###

set -euo pipefail

if (($# == 0)); then
	channels=(nixos unstable)
elif (($# == 1)) && [[ "$1" == nixos || "$1" == unstable ]]; then
	channels=("$1")
else
	printf 'Usage: %s [nixos|unstable]\n' "${0##*/}" >&2
	exit 2
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
for channel in "${channels[@]}"; do
	url=$(nix --extra-experimental-features nix-command eval --raw \
		--file "$script_dir/../sources.nix" "channels.$channel")
	nix-channel --add "$url" "$channel"
done
