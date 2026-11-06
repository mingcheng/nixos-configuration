#!/usr/bin/env bash
set -euo pipefail

usage() {
	printf 'Usage: %s [--hibernate] /dev/DISK\n' "${0##*/}"
	printf '%s\n' \
		'' \
		'Prepare a whole disk for a UEFI NixOS installation. ALL existing data is lost.' \
		'Creates GPT, a 1 GiB FAT32 EFI partition, and an F2FS root partition.' \
		'--hibernate adds swap of at least 1.2 times this machine'\''s RAM, rounded up to MiB.' \
		'Requires at least 1 GiB remaining for root and confirmation of the resolved disk path.' \
		'Does not mount filesystems, activate swap, or install a bootloader.'
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

disk=
hibernate=0
while (($#)); do
	case "$1" in
	--hibernate) hibernate=1 ;;
	-h | --help)
		usage
		exit 0
		;;
	-*) usage_error "Unknown option: $1" ;;
	*)
		[[ -z "$disk" ]] || usage_error 'Specify exactly one disk.'
		disk=$1
		;;
	esac
	shift
done
[[ -n "$disk" ]] || usage_error 'Specify a target disk.'

tools=(id readlink lsblk blockdev wipefs parted udevadm mkfs.fat mkfs.f2fs)
if ((hibernate)); then
	tools+=(awk mkswap)
fi
for tool in "${tools[@]}"; do
	command -v "$tool" >/dev/null || die "Required command not found: $tool"
done
[[ $(id -u) == 0 ]] || die 'Run this script as root.'

disk=$(readlink -f -- "$disk") || die 'Cannot resolve the disk path.'
[[ "$disk" == /dev/* ]] || die 'The target must be a disk device under /dev.'

swap_mib=0
if ((hibernate)); then
	memory_kib=$(awk '/^MemTotal:/ { print $2 }' /proc/meminfo)
	[[ "$memory_kib" =~ ^[1-9][0-9]*$ ]] || die 'Cannot determine RAM from /proc/meminfo.'
	swap_mib=$(((memory_kib * 6 + 5 * 1024 - 1) / (5 * 1024)))
fi
efi_end_mib=1025
root_start_mib=$((efi_end_mib + swap_mib))
# Reserve 1 MiB at the end for GPT metadata, in addition to 1 GiB for root.
minimum_bytes=$(((root_start_mib + 1024 + 1) * 1024 * 1024))

check_disk() {
	local info type read_only tree mountpoints size
	info=$(lsblk --nodeps --noheadings --output TYPE,RO -- "$disk")
	read -r type read_only <<<"$info"
	[[ "$type" == disk ]] || die "Not a whole disk: $disk"
	[[ "$read_only" == 0 ]] || die "Disk is read-only: $disk"

	tree=$(lsblk --noheadings --raw --output TYPE,MOUNTPOINTS -- "$disk")
	while read -r type mountpoints; do
		case "$type" in
		disk | part) ;;
		*) die "Disk has an active device mapping ($type): $disk" ;;
		esac
		[[ -z "$mountpoints" ]] || die "Disk contains mounted filesystems or active swap: $disk"
	done <<<"$tree"

	size=$(blockdev --getsize64 "$disk")
	[[ "$size" =~ ^[1-9][0-9]*$ ]] || die "Cannot determine disk size: $disk"
	((size >= minimum_bytes)) || die 'Disk is too small for this layout and 1 GiB of root space.'
}

check_disk
lsblk --output NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS -- "$disk"
printf '\nNew GPT layout on %s:\n' "$disk"
printf '%s\n' '  EFI:  1024 MiB, FAT32, label EFI'
if ((hibernate)); then
	printf '  Swap: %s MiB, label swap (RAM: %s KiB)\n' "$swap_mib" "$memory_kib"
fi
printf '%s\n' '  Root: remaining space, F2FS, label nixos'
printf '\nWARNING: ALL DATA ON %s WILL BE LOST.\n' "$disk"
printf 'Type %s to erase it: ' "$disk" >&2
confirmation=
if ! IFS= read -r confirmation || [[ "$confirmation" != "$disk" ]]; then
	die 'Confirmation did not match; no changes were made.'
fi

# Recheck after the prompt in case the disk was mounted while waiting.
check_disk
prefix=$disk
if [[ "$disk" =~ [0-9]$ ]]; then
	prefix="${disk}p"
fi
efi="${prefix}1"
partitions=("$efi")
layout=(unit MiB mklabel gpt mkpart EFI fat32 1 "$efi_end_mib" set 1 esp on)
if ((hibernate)); then
	swap="${prefix}2"
	root="${prefix}3"
	partitions+=("$swap")
	layout+=(mkpart swap linux-swap "$efi_end_mib" "$root_start_mib")
else
	root="${prefix}2"
fi
partitions+=("$root")
layout+=(mkpart nixos f2fs "$root_start_mib" '100%')

trap 'printf "%s\n" "Disk initialization failed; completed changes were not rolled back." >&2' ERR
wipefs --all -- "$disk"
parted --script --align optimal "$disk" "${layout[@]}"
blockdev --rereadpt "$disk"
udevadm settle --timeout=30

for partition in "${partitions[@]}"; do
	info=$(lsblk --nodeps --noheadings --output TYPE,PKNAME -- "$partition")
	read -r type parent <<<"$info"
	[[ "$type" == part && "$parent" == "${disk##*/}" ]] ||
		die "Expected a partition of $disk, got: $partition"
done
wipefs --all -- "${partitions[@]}"
mkfs.fat -F 32 -n EFI "$efi"
if ((hibernate)); then
	mkswap -L swap "$swap"
fi
mkfs.f2fs -l nixos "$root"

lsblk --output NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS -- "$disk"
printf '\nDisk initialized. Filesystems are not mounted; swap is not enabled.\n'
