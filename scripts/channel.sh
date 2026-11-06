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

channel=${1-nixos}
if (($# > 1)) || [[ "$channel" != nixos && "$channel" != unstable ]]; then
  printf 'Usage: %s [nixos|unstable]\n' "${0##*/}" >&2
  exit 2
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
url=$(nix --extra-experimental-features nix-command eval --raw \
  --file "$script_dir/../sources.nix" "channels.$channel")
nix-channel --add "$url" "$channel"
