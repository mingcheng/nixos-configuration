---
name: nixos-config-audit
description: "Use when auditing, checking for errors, scanning for sensitive information or secrets, or optimizing this NixOS configuration repository. Enforces syntax and formatting validation, sensitive data and UUID leak detection, NixOS module option hygiene (mkDefault and mkIf), test synchronization, and full evaluation checks."
argument-hint: "[optional scope: all | syntax | secrets | optimize | modules | hosts | scripts]"
user-invocable: true
---

# NixOS Configuration Audit, Secret Scan & Optimization

## When to Use

- Performing an overall health check, error diagnosis, or regression audit across [main.nix](../../../main.nix), [sources.nix](../../../sources.nix), [hosts/](../../../hosts), [profiles/](../../../profiles), [services/](../../../services), [system/](../../../system), [packages/](../../../packages), [scripts/](../../../scripts), and [tests/](../../../tests).
- Scanning tracked files, recent commits, and untracked machine-local files (`configuration.nix`, `hardware-configuration.nix`) for leaked secrets, credentials, private mirror URLs, or hardware disk UUIDs.
- Optimizing NixOS module definitions (conditional side effects with `lib.mkIf`, overridable defaults with `lib.mkDefault`, package routing via `workstation.userPackages`) and keeping tests and documentation in sync.

## Core Invariants

1. **Machine-Local Isolation**: Root `configuration.nix`, `hardware-configuration.nix`, and `.vscode/*.log` are gitignored and machine-specific. Never stage, commit (`git add -f`), format (`make fmt`), or copy their disk UUIDs or private mirror URLs into tracked files.
2. **Lazy `<unstable>` Boundary**: Only [packages/vscode.nix](../../../packages/vscode.nix) may import `<unstable>`. Headless targets (`HEADLESS_CHECKS` in [Makefile](../../../Makefile): `check-module-gui-headless`, `check-host-vm-image`, `check-host-usb-boot-stick`) pass `-I unstable=tests/fixtures/no-unstable.nix` and must never evaluate `<unstable>`.
3. **User Package Routing**: Shared GUI and development applications must be assigned to `workstation.userPackages` (routed to accounts listed in `workstation.users` via [packages/user-packages.nix](../../../packages/user-packages.nix)), never globally to `environment.systemPackages`.
4. **Single Sources of Truth**:
   - [sources.nix](../../../sources.nix) owns channel URLs, binary cache `substituters`, Flathub URLs, remote `hosts`, and language package mirrors.
   - `networking.proxy` (configured in [services/mihomo.nix](../../../services/mihomo.nix) when enabled) is the sole proxy source; NixOS propagates `networking.proxy.envVars` to login sessions and `nix-daemon`.

## Step-by-Step Procedure

### 1. Repository State, Syntax & Formatting Check

1. **Inspect working tree, ignored files, and recent commits**:
   ```bash
   git status --ignored
   git --no-pager log -n 10 --oneline
   git --no-pager diff
   ```
2. **Run fast syntax checks** (no Nix channel evaluation required):
   ```bash
   make check-syntax
   ```
3. **Audit common Nix module syntax & import pitfalls**:
   - **Module argument scoping**: Verify every module that references `pkgs` (`with pkgs;`), `lib`, `config`, or `modulesPath` declares them in its top-level function header (`{ config, lib, pkgs, ... }:`).
   - **Relative import depth**:
     - Files under `hosts/<host>/*.nix` must use `../../profiles/...`, `../../system/...`, `../../services/...`, `../../packages/...` (2 levels up).
     - Files under `profiles/*.nix`, `services/*.nix`, `system/*.nix`, `packages/*.nix` must use `../...` (1 level up).
   - **Attribute organization**: Keep `imports = [ ... ];` at the top of the module attribute set.
4. **Format Nix sources and verify Shell script formatting**:
   ```bash
   make fmt
   shfmt -d scripts/*.sh && shfmt -i 2 -d tests/scripts/*.sh
   ```
   - `.nix` files use 2-space indentation (`nixfmt` over `NIX_SOURCES` only).
   - `scripts/*.sh` use tabs; `tests/scripts/*.sh` use 2 spaces; all scripts require `set -euo pipefail`.

### 2. Sensitive Information & Privacy Audit

1. **Verify `.gitignore` protection**:
   ```bash
   git ls-files configuration.nix hardware-configuration.nix .vscode/*.log
   ```
   Confirm the output is empty.
2. **Scan tracked files for secrets, credentials, and hardware identifiers**:
   - Search tracked files (`main.nix`, `sources.nix`, `hosts/`, `packages/`, `profiles/`, `services/`, `system/`, `scripts/`, `tests/`, `README.md`, `AGENTS.md`) for sensitive patterns:
     - Credentials & keys: `password`, `passwd`, `secret`, `token`, `api_key`, `apikey`, `BEGIN .* PRIVATE KEY`, `ssh-rsa`, `ssh-ed25519`, `ghp_`, `sk-`
     - Private mirror tokens or URLs (e.g., `1ms.run` or personal subscription endpoints)
     - Machine-specific disk UUIDs (`/dev/disk/by-uuid/...`; tracked configs and [system/fs.nix](../../../system/fs.nix) / [scripts/mount.sh](../../../scripts/mount.sh) must only use `/dev/disk/by-label/...`)
3. **Verify service security & credential isolation**:
   - [packages/git.nix](../../../packages/git.nix): `credential.helper = "store"` must remain disabled (`!(git ? credential)`).
   - [services/mihomo.nix](../../../services/mihomo.nix): `/etc/mihomo.yaml` must use `mode = "0600"` in `systemd.tmpfiles.settings.mihomo` and contain only a minimal local `DIRECT` placeholder in tracked code; the systemd unit must load it via `LoadCredential` rather than copying secrets into `/nix/store`.
   - [services/adguard.nix](../../../services/adguard.nix), [services/mihomo.nix](../../../services/mihomo.nix), [services/syncthing.nix](../../../services/syncthing.nix), [services/docker.nix](../../../services/docker.nix), [system/security.nix](../../../system/security.nix): Admin UIs, local proxies, and Docker port bindings must bind to `127.0.0.1`, and `networking.firewall` must keep `allowedTCPPorts = []` and `allowedUDPPorts = []`.
   - [services/sshd.nix](../../../services/sshd.nix): Enforce `PasswordAuthentication = false`, `KbdInteractiveAuthentication = false`, `AuthenticationMethods = "publickey"`, `PermitRootLogin = "no"`, and `openFirewall = lib.mkDefault false`.
4. **Warn on machine-local `/nix/store` exposure**:
   - If the untracked root `configuration.nix` contains personal registry mirror URLs or tokens in Nix options (such as `virtualisation.docker.daemon.settings`), remind the user not to force-add it to Git and note that NixOS writes generated daemon configs to world-readable `/nix/store` on multi-user systems.

### 3. Configuration Optimization & Module Hygiene

1. **Gate companion side effects on `lib.mkIf cfg.enable`**:
   - When a service module sets companion system options, gate all side effects on `lib.mkIf cfg.enable` so setting `services.<name>.enable = false;` in `configuration.nix` cleanly reverts everything:
     - [services/adguard.nix](../../../services/adguard.nix): Gate `networking.nameservers`, `networking.networkmanager.insertNameservers`, and `services.resolved.settings.Resolve.DNS` on `lib.mkIf cfg.enable`.
     - [services/mihomo.nix](../../../services/mihomo.nix): Gate `networking.proxy`, `systemd.services.mihomo.after`, and `systemd.tmpfiles.settings.mihomo` on `lib.mkIf cfg.enable`, and gate `"adguardhome.service"` ordering on `config.services.adguardhome.enable`.
     - [services/resolved.nix](../../../services/resolved.nix): Gate AdGuard upstream/stub settings and `/etc/resolv.conf` override on `adguard.enable` and `cfg.enable`.
     - [services/flatpak.nix](../../../services/flatpak.nix): Gate `flatpak-flathub` (system & user units) and `flatpak-update` (service & timer) on `lib.mkIf cfg.enable`.
2. **Use `lib.mkDefault` for overridable defaults, `lib.mkForce` only for invariants**:
   - **Use `lib.mkDefault`**:
     - Service enablement in optional/shared service modules (`services.adguardhome.enable`, `services.mihomo.enable`, `services.resolved.enable`, `services.flatpak.enable`, `services.fstrim.enable`).
     - Wayland & desktop stack defaults in [packages/gui.nix](../../../packages/gui.nix) and [profiles/desktop.nix](../../../profiles/desktop.nix) (`environment.sessionVariables`, `xdg.portal.xdgOpenUsePortal`, `networking.nftables.enable`, `programs.xwayland.enable`, `services.dbus.implementation`, `services.displayManager.sddm.wayland.compositor`, `services.xserver.enable`).
     - Host build concurrency (`nix.settings.max-jobs`, `nix.settings.cores`) and proxy settings (`networking.proxy.default`, `networking.proxy.noProxy`).
   - **Use `lib.mkForce`**:
     - Hard security/isolation boundaries (`networking.firewall.allowed*Ports = []`, `trustedInterfaces = [ "lo" ]`, `allowNullPassword = false`, per-host `nix.settings.trusted-users`, AdGuard loopback bind address/port, disabling `thermald`/`tlp`/`iptsd` on incompatible hardware).
3. **Preserve package precedence & host boundaries**:
   - Keep CLI/development packages in [packages/develop.nix](../../../packages/develop.nix) and host-specific CLI tools using `lib.mkBefore` and [packages/workstation.nix](../../../packages/workstation.nix) using `lib.mkOrder 600` so CLI binaries take precedence over GUI desktop packages.
   - Ensure laptop hosts (`x1-carbon-8th`, `surface-laptop-3`) satisfy [system/swap.nix](../../../system/swap.nix) (one `/dev/` swap partition without random encryption) and keep `zramSwap` priority (`100`) above disk swap.

### 4. Test & Documentation Synchronization

1. **Synchronize tests with any module, host, or script change**:
   - Check that every module change is covered in `tests/modules/<name>.nix`, every host change in `tests/hosts/<host>.nix`, and every script change in `tests/scripts/<name>.sh`.
   - Include `config` (default behavior), `changed` (user/host overrides take effect), and `disabled` (disabling a service cleans up companion settings) evaluations where applicable.
2. **Run targeted checks first during iteration**:
   ```bash
   make check-module-<name>   # e.g., make check-module-services check-module-gui
   make check-host-<host>     # e.g., make check-host-surface-laptop-3
   make check-script-<name>   # e.g., make check-script-channels check-script-mount
   ```
3. **Validate machine-local configuration** (when root `configuration.nix` exists):
   ```bash
   NIX_BUILD_HOST=x1-carbon-8th make check-local
   ```
   Verify `warnings` is `[]` and `toplevel` evaluates to a valid `.drv` store path.
4. **Run the full verification suite**:
   ```bash
   make check
   ```
5. **Check documentation parity**:
   - Ensure [README.md](../../../README.md), [scripts/README.md](../../../scripts/README.md), and [AGENTS.md](../../../AGENTS.md) accurately reflect host profiles, default services, script arguments, and override examples.
