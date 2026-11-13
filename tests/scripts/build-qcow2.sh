#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
work=$(mktemp -d)
mkdir -p "$work/store" "$work/empty-store" "$work/out"
ln -s "$repo_dir" "$work/checkout with spaces"
printf '%s\n' 'qcow2-test-image' >"$work/store/nixos-image-vm-image.qcow2"
chmod 0444 "$work/store/nixos-image-vm-image.qcow2"
printf '%s\n' '{ }' >"$work/custom.nix"

cleanup() {
  chmod -R u+w "$work" 2>/dev/null || true
  rm -rf -- "$work"
}
trap cleanup EXIT

export TEST_LOG="$work/calls" STORE_DIR="$work/store" BASH_ENV=/dev/null
unset NIXPKGS_ALLOW_UNFREE
export MAIN_FILE="$repo_dir/main.nix"
export CUSTOM_FILE
CUSTOM_FILE=$(readlink -f -- "$work/custom.nix")

validate_nix_args() {
  local tool=$1
  shift
  if [[ ${NIXPKGS_ALLOW_UNFREE:-} != 1 ]]; then
    printf 'Expected NIXPKGS_ALLOW_UNFREE=1 for %s, got: %s\n' "$tool" "${NIXPKGS_ALLOW_UNFREE:-}" >&2
    return 91
  fi
  if [[ ${NIX_BUILD_HOST:-} != vm-image ]]; then
    printf 'Unexpected NIX_BUILD_HOST for %s: %s\n' "$tool" "${NIX_BUILD_HOST:-}" >&2
    return 92
  fi
  local no_out_link=0
  if [[ ${1:-} == --no-out-link ]]; then
    no_out_link=1
    shift
  fi
  if [[ $# != 14 ||
    $1 != --argstr || $2 != main || ! $3 -ef "$MAIN_FILE" ||
    $4 != --argstr || $5 != extraConfig ||
    $7 != --argstr || $8 != diskSize ||
    ${10} != --argstr || ${11} != bootMode ||
    ${13} != --expr || -z ${14} ]]; then
    printf 'Unexpected %s arguments: %s\n' "$tool" "$*" >&2
    return 93
  fi
  printf '%s no_link=%s extra=%s size=%s boot=%s\n' \
    "$tool" "$no_out_link" "$6" "$9" "${12}" >>"$TEST_LOG"
}

nix-build() {
  validate_nix_args nix-build "$@" || return $?
  if [[ ${FAIL_BUILD:-0} == 1 ]]; then
    printf '%s\n' 'simulated nix-build failure' >&2
    return 29
  fi
  printf '%s\n' "${MOCK_STORE_DIR:-$STORE_DIR}"
}

nix-instantiate() {
  validate_nix_args nix-instantiate "$@" || return $?
  if [[ ${FAIL_INSTANTIATE:-0} == 1 ]]; then
    printf '%s\n' 'simulated nix-instantiate failure' >&2
    return 30
  fi
  printf '%s\n' "$STORE_DIR/nixos-disk-image.drv"
}
export -f validate_nix_args nix-build nix-instantiate

assert_calls() {
  local actual
  actual=$(<"$TEST_LOG")
  if [[ $actual != "$1" ]]; then
    printf 'Unexpected nix calls:\n%s\nExpected:\n%s\n' "$actual" "$1" >&2
    exit 1
  fi
}

expect_failure() {
  local expected=$1 status
  shift
  : >"$TEST_LOG"
  if "$@" >"$work/stdout" 2>"$work/stderr"; then
    printf '%s\n' 'Expected build-qcow2.sh to fail' >&2
    exit 1
  else
    status=$?
  fi
  if [[ $status != "$expected" || ! -s "$work/stderr" ]]; then
    printf 'Expected status %s with a diagnostic, got %s:\n%s\n' \
      "$expected" "$status" "$(<"$work/stderr")" >&2
    exit 1
  fi
}

script="$work/checkout with spaces/scripts/build-qcow2.sh"

# Default build (UEFI, auto disk size, store output)
: >"$TEST_LOG"
out=$(bash "$script")
[[ $out == "$STORE_DIR/nixos-image-vm-image.qcow2" ]] || exit 1
assert_calls 'nix-build no_link=0 extra= size= boot='

# Help output
: >"$TEST_LOG"
help_out=$(bash "$script" --help)
[[ $help_out == *'Usage: build-qcow2.sh'* ]] || exit 1
assert_calls ''

# Dry-run with --legacy and --disk-size
: >"$TEST_LOG"
drv=$(bash "$script" --dry-run --legacy --disk-size 16384)
[[ $drv == "$STORE_DIR/nixos-disk-image.drv" ]] || exit 1
assert_calls 'nix-instantiate no_link=0 extra= size=16384 boot=legacy'

# Build with --efi, --config, --disk-size auto, and --output (copies writable file)
: >"$TEST_LOG"
target="$work/out/nested/vm.qcow2"
out=$(bash "$script" --efi -c "$work/custom.nix" -s auto -o "$target")
[[ $out == "$target" && -f "$target" && -w "$target" ]] || exit 1
[[ $(<"$target") == 'qcow2-test-image' ]] || exit 1
assert_calls "nix-build no_link=1 extra=$CUSTOM_FILE size=auto boot=efi"

# Usage & validation errors
expect_failure 2 bash "$script" --unknown
assert_calls ''
expect_failure 2 bash "$script" unexpected-arg
assert_calls ''
expect_failure 2 bash "$script" --efi --legacy
assert_calls ''
expect_failure 2 bash "$script" --legacy --efi
assert_calls ''
expect_failure 2 bash "$script" --disk-size 0
assert_calls ''
expect_failure 2 bash "$script" --disk-size -1024
assert_calls ''
expect_failure 2 bash "$script" --disk-size 16G
assert_calls ''
expect_failure 2 bash "$script" --disk-size
assert_calls ''
expect_failure 2 bash "$script" --config
assert_calls ''
expect_failure 2 bash "$script" --config ''
assert_calls ''
expect_failure 2 bash "$script" --output
assert_calls ''
expect_failure 2 bash "$script" --output ''
assert_calls ''
expect_failure 2 bash "$script" --dry-run --output "$work/out/bad.qcow2"
assert_calls ''

# Runtime errors: missing config file, output path is directory, build failures, missing .qcow2
expect_failure 1 bash "$script" --config "$work/nonexistent.nix"
assert_calls ''
expect_failure 1 bash "$script" --output "$work/out"
assert_calls ''

export FAIL_BUILD=1
expect_failure 29 bash "$script"
unset FAIL_BUILD

export FAIL_INSTANTIATE=1
expect_failure 30 bash "$script" --dry-run
unset FAIL_INSTANTIATE

export MOCK_STORE_DIR="$work/empty-store"
expect_failure 1 bash "$script"
unset MOCK_STORE_DIR

printf '%s\n' 'scripts/build-qcow2: all checks passed'
