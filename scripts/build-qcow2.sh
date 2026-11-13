#!/usr/bin/env bash
###
# File: build-qcow2.sh
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Friday, November 13th 2026, 11:30:00 am
# Last Modified: Friday, November 13th 2026, 11:30:00 am
#
# http://www.opensource.org/licenses/MIT
###

set -euo pipefail

usage() {
	printf 'Usage: %s [--efi|--legacy] [-s|--disk-size auto|MIB] [-c|--config FILE] [-o|--output FILE | -n|--dry-run]\n' "${0##*/}"
	printf '%s\n' \
		'' \
		'Build the vm-image host configuration into a bootable QEMU qcow2 disk image.' \
		'Automatically loads hosts/vm-image/local.nix when present.' \
		'' \
		'Options:' \
		'  -c, --config FILE          Import an additional NixOS module file.' \
		'  -s, --disk-size auto|MIB   Set virtualisation.diskSize in MiB or auto (default: auto).' \
		'      --efi                  Build a UEFI (systemd-boot) image (default).' \
		'      --legacy               Build a Legacy BIOS (GRUB on /dev/vda) image.' \
		'  -o, --output FILE          Copy the built .qcow2 image to FILE with mode 0644.' \
		'  -n, --dry-run              Instantiate the image derivation without building.' \
		'  -h, --help                 Show this help message.'
}

die() {
	printf 'Error: %s\n' "$*" >&2
	exit 1
}

usage_error() {
	printf 'Error: %s\n' "$*" >&2
	usage >&2
	exit 2
}

extra_config=
disk_size=
boot_mode=
output=
dry_run=0

while (($#)); do
	case "$1" in
	-c | --config)
		(($# >= 2)) || usage_error "Missing argument for $1."
		[[ -n "$2" ]] || usage_error 'Configuration file path must not be empty.'
		extra_config=$2
		shift
		;;
	-s | --disk-size)
		(($# >= 2)) || usage_error "Missing argument for $1."
		[[ "$2" == auto || "$2" =~ ^[1-9][0-9]*$ ]] ||
			usage_error "Invalid disk size '$2': expected 'auto' or a positive integer in MiB."
		disk_size=$2
		shift
		;;
	--efi)
		[[ -z "$boot_mode" || "$boot_mode" == efi ]] ||
			usage_error 'Cannot combine --efi and --legacy.'
		boot_mode=efi
		;;
	--legacy)
		[[ -z "$boot_mode" || "$boot_mode" == legacy ]] ||
			usage_error 'Cannot combine --efi and --legacy.'
		boot_mode=legacy
		;;
	-o | --output)
		(($# >= 2)) || usage_error "Missing argument for $1."
		[[ -n "$2" ]] || usage_error 'Output path must not be empty.'
		output=$2
		shift
		;;
	-n | --dry-run)
		dry_run=1
		;;
	-h | --help)
		usage
		exit 0
		;;
	-*)
		usage_error "Unknown option: $1"
		;;
	*)
		usage_error "Unexpected argument: $1"
		;;
	esac
	shift
done

if ((dry_run)) && [[ -n "$output" ]]; then
	usage_error 'Cannot combine --dry-run with --output.'
fi

tools=(readlink)
if ((dry_run)); then
	tools+=(nix-instantiate)
else
	tools+=(nix-build)
fi
if [[ -n "$output" ]]; then
	tools+=(dirname mkdir install)
fi
for tool in "${tools[@]}"; do
	command -v "$tool" >/dev/null || die "Required command not found: $tool"
done

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(cd -- "$script_dir/.." && pwd)
main_file="$repo_dir/main.nix"
[[ -f "$main_file" ]] || die "Entrypoint not found: $main_file"

if [[ -n "$extra_config" ]]; then
	extra_config=$(readlink -f -- "$extra_config") || die "Cannot resolve config path: $extra_config"
	[[ -f "$extra_config" ]] || die "Configuration file not found: $extra_config"
fi

if [[ -n "$output" ]]; then
	[[ ! -d "$output" ]] || die "Output path is a directory: $output"
fi

export NIXPKGS_ALLOW_UNFREE=1
export NIX_BUILD_HOST=vm-image

nix_expr='{ main, extraConfig, diskSize, bootMode }:
let
  nixos = import <nixpkgs/nixos> {
    system = "x86_64-linux";
    configuration = { lib, ... }: {
      imports = [ (builtins.toPath main) ]
        ++ lib.optional (extraConfig != "") (builtins.toPath extraConfig);
      image.efiSupport = lib.mkIf (bootMode != "") (bootMode == "efi");
      virtualisation.diskSize = lib.mkIf (diskSize != "") (
        if diskSize == "auto" then "auto" else builtins.fromJSON diskSize
      );
    };
  };
in nixos.config.system.build.image'

nix_args=(
	--argstr main "$main_file"
	--argstr extraConfig "$extra_config"
	--argstr diskSize "$disk_size"
	--argstr bootMode "$boot_mode"
	--expr "$nix_expr"
)

if ((dry_run)); then
	nix-instantiate "${nix_args[@]}"
	exit 0
fi

build_flags=()
if [[ -n "$output" ]]; then
	build_flags+=(--no-out-link)
fi

store_dir=$(nix-build "${build_flags[@]}" "${nix_args[@]}")
[[ -n "$store_dir" ]] || die 'nix-build did not return a store path.'

shopt -s nullglob
images=("$store_dir"/*.qcow2)
shopt -u nullglob
((${#images[@]} == 1)) || die "Expected one .qcow2 image in $store_dir, found ${#images[@]}."

if [[ -n "$output" ]]; then
	mkdir -p -- "$(dirname -- "$output")"
	install -m 0644 -- "${images[0]}" "$output"
	printf '%s\n' "$output"
else
	printf '%s\n' "${images[0]}"
fi
