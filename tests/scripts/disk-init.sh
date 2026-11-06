#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
bash_path=$(command -v bash)
work=$(mktemp -d)
cleanup() {
  rm -f -- "$work/calls" "$work/checks" "$work/stdout" "$work/stderr"
  rmdir -- "$work"
}
trap cleanup EXIT
export TEST_LOG="$work/calls" TEST_CHECKS="$work/checks" TEST_DISK=/dev/sda BASH_ENV=/dev/null

record() {
  printf '%s\n' "$*" >>"$TEST_LOG"
  if [[ "$*" == "${FAIL_CALL:-}" ]]; then
    printf 'simulated failure: %s\n' "$*" >&2
    return 31
  fi
}
id() {
  [[ "$*" == -u ]] || return 90
  printf '%s\n' "${TEST_UID:-0}"
}
readlink() {
  [[ $# == 3 && $1 == -f && $2 == -- ]] || return 90
  printf '%s\n' "${CANONICAL_DISK:-$3}"
}
awk() {
  [[ $# == 2 && $2 == /proc/meminfo ]] || return 90
  printf '%s\n' "${RAM_KIB-8388608}"
}
lsblk() {
  case "$*" in
  "--nodeps --noheadings --output TYPE,RO -- $TEST_DISK")
    printf '%s\n' "$(($(<"$TEST_CHECKS") + 1))" >"$TEST_CHECKS"
    printf '%s %s\n' "${DEVICE_TYPE:-disk}" "${READ_ONLY:-0}"
    ;;
  "--noheadings --raw --output TYPE,MOUNTPOINTS -- $TEST_DISK")
    if [[ ${BUSY_ON_RECHECK:-0} == 1 && $(<"$TEST_CHECKS") == 2 ]]; then
      printf 'disk\npart /mnt\n'
    else
      printf '%s\n' "${DEVICE_TREE:-disk}"
    fi
    ;;
  "--nodeps --noheadings --output TYPE,PKNAME -- "*)
    printf '%s %s\n' "${PARTITION_TYPE:-part}" "${PARTITION_PARENT:-${TEST_DISK##*/}}"
    ;;
  "--output NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS -- $TEST_DISK" | \
    "--output NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS -- $TEST_DISK")
    printf '%s\n' "$TEST_DISK"
    ;;
  *)
    printf 'not a test disk or unexpected lsblk arguments: %s\n' "$*" >&2
    return 32
    ;;
  esac
}
blockdev() {
  if [[ "$*" == "--getsize64 $TEST_DISK" ]]; then
    printf '%s\n' "${DISK_BYTES:-137438953472}"
  else
    record blockdev "$@"
  fi
}
wipefs() { record wipefs "$@"; }
parted() { record parted "$@"; }
udevadm() { record udevadm "$@"; }
mkfs.fat() { record mkfs.fat "$@"; }
mkfs.f2fs() { record mkfs.f2fs "$@"; }
mkswap() { record mkswap "$@"; }
export -f record id readlink awk lsblk blockdev wipefs parted udevadm mkfs.fat mkfs.f2fs mkswap

run_script() {
  # An empty PATH prevents any unmocked disk tool from reaching real devices.
  PATH="$work/no-executables" "$bash_path" "$repo_dir/scripts/disk-init.sh" "$@"
}
reset_calls() {
  : >"$TEST_LOG"
  printf '0\n' >"$TEST_CHECKS"
}
assert_calls() {
  local actual
  actual=$(<"$TEST_LOG")
  if [[ "$actual" != "$1" ]]; then
    printf 'Unexpected disk calls:\n%s\nExpected:\n%s\n' "$actual" "$1" >&2
    exit 1
  fi
}
expect_failure() {
  local expected=$1 status
  shift
  reset_calls
  if run_script "$@" >"$work/stdout" 2>"$work/stderr"; then
    printf '%s\n' 'Expected disk initialization to fail' >&2
    exit 1
  else
    status=$?
  fi
  if [[ "$status" != "$expected" || ! -s "$work/stderr" ]]; then
    printf 'Expected status %s with a diagnostic, got %s:\n%s\n' \
      "$expected" "$status" "$(<"$work/stderr")" >&2
    exit 1
  fi
}
run_confirmed() {
  reset_calls
  if ! printf '%s\n' "$TEST_DISK" | run_script "$@" >"$work/stdout" 2>"$work/stderr"; then
    printf 'Disk initialization failed unexpectedly:\n%s\n' "$(<"$work/stderr")" >&2
    exit 1
  fi
}
expected_layout() {
  local prefix=$1 swap_mib=$2 root_start=$3 root layout partitions
  layout="unit MiB mklabel gpt mkpart EFI fat32 1 1025 set 1 esp on"
  partitions="${prefix}1"
  if ((swap_mib)); then
    layout+=" mkpart swap linux-swap 1025 $root_start"
    partitions+=" ${prefix}2"
    root="${prefix}3"
  else
    root="${prefix}2"
  fi
  partitions+=" $root"
  layout+=" mkpart nixos f2fs $root_start 100%"
  printf '%s\n' \
    "wipefs --all -- $TEST_DISK" \
    "parted --script --align optimal $TEST_DISK $layout" \
    "blockdev --rereadpt $TEST_DISK" \
    'udevadm settle --timeout=30' \
    "wipefs --all -- $partitions" \
    "mkfs.fat -F 32 -n EFI ${prefix}1"
  if ((swap_mib)); then
    printf 'mkswap -L swap %s2\n' "$prefix"
  fi
  printf 'mkfs.f2fs -l nixos %s\n' "$root"
}

reset_calls
run_script --help >"$work/stdout"
assert_calls ""
expect_failure 2
assert_calls ""
expect_failure 2 --unknown
assert_calls ""
expect_failure 2 "$TEST_DISK" /dev/sdb
assert_calls ""
expect_failure 1 /tmp/not-a-device
assert_calls ""
expect_failure 32 /dev/not-a-device
assert_calls ""

export TEST_UID=1000
expect_failure 1 "$TEST_DISK"
assert_calls ""
unset TEST_UID

export -n -f parted
expect_failure 1 "$TEST_DISK"
assert_calls ""
export -f parted

export -n -f mkfs.f2fs
expect_failure 1 "$TEST_DISK"
assert_calls ""
export -f mkfs.f2fs

export -n -f awk mkswap
run_confirmed "$TEST_DISK"
assert_calls "$(expected_layout /dev/sda 0 1025)"
expect_failure 1 --hibernate "$TEST_DISK"
assert_calls ""
export -f awk mkswap

for DEVICE_TYPE in part loop lvm; do
  export DEVICE_TYPE
  expect_failure 1 "$TEST_DISK"
  assert_calls ""
done
unset DEVICE_TYPE
export READ_ONLY=1
expect_failure 1 "$TEST_DISK"
assert_calls ""
unset READ_ONLY

for DEVICE_TREE in 'disk /' $'disk\npart /mnt' $'disk\npart [SWAP]' \
  $'disk\npart\ncrypt' $'disk\npart\nlvm' $'disk\npart\nraid1'; do
  export DEVICE_TREE
  expect_failure 1 "$TEST_DISK"
  assert_calls ""
done
unset DEVICE_TREE

for RAM_KIB in '' invalid 0; do
  export RAM_KIB
  expect_failure 1 --hibernate "$TEST_DISK"
  assert_calls ""
done
unset RAM_KIB
for DISK_BYTES in invalid 0 2149580799; do
  export DISK_BYTES
  expect_failure 1 "$TEST_DISK"
  assert_calls ""
done
export DISK_BYTES=8589934592
expect_failure 1 --hibernate "$TEST_DISK"
assert_calls ""
export DISK_BYTES=2149580800
run_confirmed "$TEST_DISK"
assert_calls "$(expected_layout /dev/sda 0 1025)"
unset DISK_BYTES

expect_failure 1 "$TEST_DISK" </dev/null
assert_calls ""
for answer in yes /dev/sdb ''; do
  printf '%s\n' "$answer" | expect_failure 1 "$TEST_DISK"
  assert_calls ""
done
export BUSY_ON_RECHECK=1
printf '%s\n' "$TEST_DISK" | expect_failure 1 "$TEST_DISK"
assert_calls ""
unset BUSY_ON_RECHECK

for TEST_DISK in /dev/sda /dev/vda /dev/nvme0n1 /dev/mmcblk0; do
  export TEST_DISK
  case "$TEST_DISK" in
  /dev/sda | /dev/vda) prefix=$TEST_DISK ;;
  *) prefix="${TEST_DISK}p" ;;
  esac
  run_confirmed "$TEST_DISK"
  assert_calls "$(expected_layout "$prefix" 0 1025)"
  run_confirmed --hibernate "$TEST_DISK"
  assert_calls "$(expected_layout "$prefix" 9831 10856)"
done

export TEST_DISK=/dev/nvme0n1 CANONICAL_DISK=/dev/nvme0n1
run_confirmed --hibernate '/dev/disk/by-id/test disk'
assert_calls "$(expected_layout /dev/nvme0n1p 9831 10856)"
unset CANONICAL_DISK
export RAM_KIB=5242880
run_confirmed "$TEST_DISK" --hibernate
assert_calls "$(expected_layout /dev/nvme0n1p 6144 7169)"
export RAM_KIB=5242881
run_confirmed --hibernate "$TEST_DISK"
assert_calls "$(expected_layout /dev/nvme0n1p 6145 7170)"
unset RAM_KIB

full_layout=$(expected_layout /dev/nvme0n1p 9831 10856)
expected_prefix=
while IFS= read -r FAIL_CALL; do
  export FAIL_CALL
  expected_prefix+="${expected_prefix:+$'\n'}$FAIL_CALL"
  printf '%s\n' "$TEST_DISK" | expect_failure 31 --hibernate "$TEST_DISK"
  assert_calls "$expected_prefix"
done <<<"$full_layout"
unset FAIL_CALL

export PARTITION_PARENT=sdb
printf '%s\n' "$TEST_DISK" | expect_failure 1 --hibernate "$TEST_DISK"
assert_calls "$(printf '%s\n' \
  "wipefs --all -- $TEST_DISK" \
  'parted --script --align optimal /dev/nvme0n1 unit MiB mklabel gpt mkpart EFI fat32 1 1025 set 1 esp on mkpart swap linux-swap 1025 10856 mkpart nixos f2fs 10856 100%' \
  "blockdev --rereadpt $TEST_DISK" \
  'udevadm settle --timeout=30')"

printf '%s\n' 'scripts/disk-init: all checks passed'
