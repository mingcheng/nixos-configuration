#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
TEST_LOG=$(mktemp)
export TEST_LOG BASH_ENV=/dev/null
trap 'rm -f -- "$TEST_LOG" "$TEST_LOG.stderr"' EXIT

mount() {
  printf 'mount %s\n' "$*" >>"$TEST_LOG"
  if [[ ${FAIL_MOUNT:-} == "${@: -1}" ]]; then
    printf 'simulated mount failure: %s\n' "${@: -1}" >&2
    return 26
  fi
}
mkdir() {
  printf 'mkdir %s\n' "$*" >>"$TEST_LOG"
  if [[ ${FAIL_MKDIR:-0} == 1 ]]; then
    printf '%s\n' 'simulated mkdir failure' >&2
    return 27
  fi
}
df() {
  printf 'df %s\n' "$*" >>"$TEST_LOG"
}
swapon() {
  printf 'swapon %s\n' "$*" >>"$TEST_LOG"
  if [[ ${FAIL_SWAPON:-0} == 1 ]]; then
    printf '%s\n' 'simulated swapon failure' >&2
    return 28
  fi
}
test() {
  if [[ "$*" == "-e /dev/disk/by-label/swap" ]]; then
    [[ ${HAS_SWAP:-0} == 1 ]]
    return
  fi
  builtin test "$@"
}
export -f mount mkdir df swapon test

assert_calls() {
  local actual
  actual=$(<"$TEST_LOG")
  if [[ $actual != "$1" ]]; then
    printf 'Unexpected mount calls:\n%s\nExpected:\n%s\n' "$actual" "$1" >&2
    exit 1
  fi
}
expect_failure() {
  local status expected=${1:-26}
  if bash "$repo_dir/scripts/mount.sh" >/dev/null 2>"$TEST_LOG.stderr"; then
    printf '%s\n' 'Expected mounting to fail' >&2
    exit 1
  else
    status=$?
  fi
  if [[ $status != "$expected" || ! -s "$TEST_LOG.stderr" ]]; then
    printf 'Expected mount error %s with a diagnostic, got %s\n' "$expected" "$status" >&2
    exit 1
  fi
}

bash "$repo_dir/scripts/mount.sh"
assert_calls "$(printf '%s\n' \
  'mount /dev/disk/by-label/nixos /mnt' \
  'mkdir -p /mnt/boot' \
  'mount -o umask=0077 /dev/disk/by-label/EFI /mnt/boot' \
  'df -lh /mnt /mnt/boot')"

: >"$TEST_LOG"
export HAS_SWAP=1
bash "$repo_dir/scripts/mount.sh"
assert_calls "$(printf '%s\n' \
  'mount /dev/disk/by-label/nixos /mnt' \
  'mkdir -p /mnt/boot' \
  'mount -o umask=0077 /dev/disk/by-label/EFI /mnt/boot' \
  'swapon /dev/disk/by-label/swap' \
  'df -lh /mnt /mnt/boot')"

: >"$TEST_LOG"
export FAIL_SWAPON=1
expect_failure 28
assert_calls "$(printf '%s\n' \
  'mount /dev/disk/by-label/nixos /mnt' \
  'mkdir -p /mnt/boot' \
  'mount -o umask=0077 /dev/disk/by-label/EFI /mnt/boot' \
  'swapon /dev/disk/by-label/swap')"
unset HAS_SWAP FAIL_SWAPON

: >"$TEST_LOG"
export FAIL_MOUNT=/mnt
expect_failure
assert_calls 'mount /dev/disk/by-label/nixos /mnt'

: >"$TEST_LOG"
export FAIL_MOUNT=/mnt/boot
expect_failure
assert_calls "$(printf '%s\n' \
  'mount /dev/disk/by-label/nixos /mnt' \
  'mkdir -p /mnt/boot' \
  'mount -o umask=0077 /dev/disk/by-label/EFI /mnt/boot')"

: >"$TEST_LOG"
unset FAIL_MOUNT
export FAIL_MKDIR=1
expect_failure 27
assert_calls "$(printf '%s\n' \
  'mount /dev/disk/by-label/nixos /mnt' \
  'mkdir -p /mnt/boot')"

printf '%s\n' 'scripts/mount: all checks passed'
