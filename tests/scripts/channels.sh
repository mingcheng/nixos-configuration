#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
export SOURCE_FILE="$repo_dir/sources.nix"
export STABLE_URL="https://channels.example.test/stable"
export UNSTABLE_URL="https://channels.example.test/unstable"

work=$(mktemp -d)
mkdir -p "$work/home/.config/nix"
ln -s "$repo_dir" "$work/checkout with spaces"
cleanup() {
  rm -f -- "$work/calls" "$work/stderr" "$work/checkout with spaces" "$work/home/.config/nix/nix.conf"
  rmdir -- "$work/home/.config/nix" "$work/home/.config" "$work/home" "$work"
}
trap cleanup EXIT
export HOME="$work/home" TEST_LOG="$work/calls" BASH_ENV=/dev/null
printf '%s\n' 'keep-existing-config = true' >"$HOME/.config/nix/nix.conf"

nix() {
  if [[ ${FAIL_NIX:-0} == 1 ]]; then
    printf '%s\n' 'simulated evaluation failure' >&2
    return 23
  fi
  if [[ $# != 7 || $1 != --extra-experimental-features || $2 != nix-command ||
    $3 != eval || $4 != --raw || $5 != --file || ! $6 -ef "$SOURCE_FILE" ]]; then
    printf '%s\n' 'unexpected Nix evaluation arguments' >&2
    return 1
  fi
  case "$7" in
  channels.nixos) printf '%s' "$STABLE_URL" ;;
  channels.unstable) printf '%s' "$UNSTABLE_URL" ;;
  *) return 1 ;;
  esac
}
nix-channel() {
  printf '%s\n' "$*" >>"$TEST_LOG"
  if [[ ${FAIL_ADD:-0} == 1 && $1 == --add ]]; then
    printf '%s\n' 'simulated channel registration failure' >&2
    return 24
  fi
  if [[ ${FAIL_UPDATE:-0} == 1 && $1 == --update ]]; then
    printf '%s\n' 'simulated channel update failure' >&2
    return 25
  fi
}
export -f nix nix-channel

assert_calls() {
  local actual
  actual=$(<"$TEST_LOG")
  if [[ $actual != "$1" ]]; then
    printf 'Unexpected channel calls:\n%s\nExpected:\n%s\n' "$actual" "$1" >&2
    exit 1
  fi
  if [[ $(<"$HOME/.config/nix/nix.conf") != 'keep-existing-config = true' ]]; then
    printf '%s\n' 'Existing user Nix configuration was overwritten' >&2
    exit 1
  fi
}
expect_failure() {
  local expected=$1 status
  shift
  if "$@" >/dev/null 2>"$work/stderr"; then
    printf '%s\n' 'Expected the script to fail' >&2
    exit 1
  else
    status=$?
  fi
  if [[ $status != "$expected" || ! -s "$work/stderr" ]]; then
    printf 'Expected status %s with a diagnostic, got %s\n' "$expected" "$status" >&2
    exit 1
  fi
}

cd "$work"
channel="$work/checkout with spaces/scripts/channel.sh"
setup="$work/checkout with spaces/scripts/nixconfig.sh"

: >"$TEST_LOG"
bash "$channel"
assert_calls "--add $STABLE_URL nixos"

: >"$TEST_LOG"
bash "$channel" unstable
assert_calls "--add $UNSTABLE_URL unstable"

: >"$TEST_LOG"
bash "$setup"
assert_calls "$(printf '%s\n' "--add $STABLE_URL nixos" '--update nixos')"

: >"$TEST_LOG"
bash "$setup" unstable
assert_calls "$(printf '%s\n' "--add $UNSTABLE_URL unstable" '--update unstable')"

for script in "$channel" "$setup"; do
  : >"$TEST_LOG"
  expect_failure 2 bash "$script" unsupported
  assert_calls ""
  expect_failure 2 bash "$script" ""
  assert_calls ""
  expect_failure 2 bash "$script" nixos extra
  assert_calls ""
done

: >"$TEST_LOG"
export FAIL_NIX=1
expect_failure 23 bash "$setup"
unset FAIL_NIX
assert_calls ""

: >"$TEST_LOG"
export FAIL_ADD=1
expect_failure 24 bash "$setup"
unset FAIL_ADD
assert_calls "--add $STABLE_URL nixos"

: >"$TEST_LOG"
export FAIL_UPDATE=1
expect_failure 25 bash "$setup"
unset FAIL_UPDATE
assert_calls "$(printf '%s\n' "--add $STABLE_URL nixos" '--update nixos')"

printf '%s\n' 'scripts/channels: all checks passed'
