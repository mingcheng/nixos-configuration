# AGENTS.md

Personal NixOS 26.05 (x86_64-linux) config, channel-based — there is **no** `flake.nix`; `<nixpkgs>` / `<unstable>` resolve from `NIX_PATH`/channels. Usage is in `README.md`, script parameters in `scripts/README.md`. No CI or pre-commit config; `make check` is the full verification.

## Commands

- `NIX_BUILD_HOST` (`x1-carbon-8th` | `surface-laptop-3` | `ryzen-4750g` | `vm-image` | `usb-boot-stick`, discovered from `hosts/*/default.nix`) is mandatory — `main.nix` throws without it. `sudo` strips env vars, so use `sudo env NIX_BUILD_HOST=<host> nixos-rebuild switch` (same for `build`, `nixos-install`, and `make check-local`).
- `make` alone runs `make check` (= `check-syntax` → `check-modules` → `check-hosts` → `check-scripts`). `make check-syntax` combines `check-nix-syntax` (Nix parsing, no channels) and `check-shell-syntax` (Bash parsing, no Nix).
- Full `make check` takes minutes (14+ separate Nix evaluations). Iterate with auto-discovered focused targets instead: `make check-module-<name>`, `make check-host-<name>`, `make check-script-<name>`, where `<name>` is the filename stem under `tests/{modules,hosts,scripts}/`.
- `make check-local` evaluates the machine-local config; set `NIX_BUILD_HOST`, plus `LOCAL_CONFIG=/etc/nixos/configuration.nix` when not using the repo's `configuration.nix`.
- `make fmt` runs `nixfmt` via `nix-shell -p nixfmt` over `NIX_SOURCES` only (`main.nix`, `sources.nix`, `hosts`, `packages`, `profiles`, `services`, `system`, `tests`) — never the root `configuration.nix` / `hardware-configuration.nix`.
- Tests need `<nixpkgs>` resolvable via `NIX_PATH`/channels; full and GUI checks also need `<unstable>`. `NIX_EVAL` in the `Makefile` unsets `NIXPKGS_ALLOW_UNFREE` and `tests/lib.nix` forces `allowUnfree = false`, so exporting it changes nothing.

## Architecture

- `main.nix` is the sole entrypoint: imports `hosts/<host>/default.nix`, sets `networking.hostName` via `mkDefault` and `environment.variables.NIX_BUILD_HOST`, which `system/autoupgrade.nix` forwards into the `nixos-upgrade` service.
- Profiles layer `base.nix` → `desktop.nix` → `workstation.nix` → `laptop.nix`, with `develop.nix` providing the reusable development toolchain (`nix-ld`, `direnv`, compilers, Nix/CLI dev tools). `surface-laptop-3` imports `laptop`; `x1-carbon-8th` imports `laptop` + `develop`; `ryzen-4750g` imports `workstation` + `develop`; `vm-image` and `usb-boot-stick` import `base`. Keep accounts, proxy, `trusted-users`, kernel and hardware policy in `hosts/<host>/`, and keep software package selections in `profiles/` and `packages/`.
- `workstation.users` / `workstation.userPackages` are custom options from `packages/user-packages.nix`: shared apps are assigned to named users, not `environment.systemPackages`. `packages/gui.nix` and `packages/vscode.nix` gate GUI/VS Code packages on `workstation.users` and `hasGui`.
- `sources.nix` is the single source for channel URLs, substituters, Flathub and dev mirrors — imported by Nix modules and evaluated by `scripts/channel.sh` / `nixconfig.sh`. Changing a channel URL also requires re-running `nix-channel --add` on the machine.
- `<unstable>` may only be imported lazily by `packages/vscode.nix`. Headless checks pass `-I unstable=tests/fixtures/no-unstable.nix` (a `throw`) via the `Makefile`'s hardcoded `HEADLESS_CHECKS` list, so headless hosts must not require it.

## Tests

- Pure NixOS module evaluation via `tests/lib.nix` (`eval-config.nix`) — never builds or switches. It injects fake `/`, `/boot`, `/efi` mounts, one fake swap device, `system.stateVersion = "26.05"`, and disables GRUB, so the real hardware config is unused.
- Module/host tests import `../lib.nix` and must evaluate to a JSON attrset from `t.check "<suite>" { name = bool; }`; `t.check` throws on any false. Helpers: `t.eval`, `t.validSystem`, `t.hasPackages`.
- `tests/hosts/*.nix` filenames must equal host directory names, since `make check-host-<name>` sets `NIX_BUILD_HOST=$*` from the target name.
- `tests/scripts/*.sh` are standalone Bash scripts run directly without Nix; they stub `nix`, `nix-channel`, `lsblk`, etc. and never touch real channels or disks.
- **Adding a host** needs `hosts/<name>/default.nix` and `tests/hosts/<name>.nix`; discovery and selection coverage are automatic. If it must not need `<unstable>`, also add its target to `HEADLESS_CHECKS` in the `Makefile`. New module/script tests need no Makefile change.
- `system/swap.nix` throws unless X1 has exactly one `/dev/` swap device without random encryption; zram does not satisfy it.

## Gotchas

- Root `configuration.nix` and `hardware-configuration.nix` are gitignored, machine-local, and present but untracked. Never commit them or copy their disk UUIDs between hosts; `nixos-generate-config` owns the latter.
- `.nix` uses 2-space indent / `nixfmt`. `scripts/*.sh` indent with tabs, but `tests/scripts/*.sh` use 2 spaces; all use `set -euo pipefail`. Commits use Conventional Commits with scope (`feat(nixos):`, `fix(scripts):`, `test:`, `docs:`).
