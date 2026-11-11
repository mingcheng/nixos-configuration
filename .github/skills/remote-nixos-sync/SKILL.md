---
name: remote-nixos-sync
description: "Use when diagnosing, installing, tuning, or updating a remote NixOS host over SSH/SCP (nixos-install on /mnt/etc/nixos or nixos-rebuild switch on /etc/nixos). Enforces local-first edits, local test validation, targeted SCP file synchronization, preservation of remote machine-local and temporary SSH debug configs, and remote evaluation/switch verification."
argument-hint: "<user@host> [NIX_BUILD_HOST] [task or issue]"
user-invocable: true
---

# Remote NixOS Diagnosis & Local-First SCP Sync

## When to Use

- Troubleshooting or running `nixos-install --root /mnt` on a remote NixOS Live installer (`nixos@<ip>`, repository at `/mnt/etc/nixos`).
- Diagnosing hardware, kernel modules, input devices (`libinput`, `keyd`), suspend/hibernation (`s2idle`, swap, ACPI GPE), or services on a running remote NixOS host (`<user>@<ip>`, repository at `/etc/nixos`).
- Modifying repository configurations/scripts locally and syncing them via `scp` to a remote host for live debugging and verification.

## Core Invariants

1. **Local-First Modification**: Always edit tracked files and their corresponding tests in the local repository first. Never leave ad-hoc fixes only on the remote host.
2. **Pre-Sync Remote Diff Check**: Before running `scp`, inspect `git status -s` and `git --no-pager diff` on the remote repository to identify temporary remote-only debugging changes (such as temporary `services/sshd.nix` imports in `hosts/<host>/default.nix`, relaxed `services/sshd.nix`, or `allowedTCPPorts = [ 22 ]` in `system/security.nix`). **Never overwrite remote SSH/firewall debug overrides** unless explicitly requested.
3. **Protect Machine-Local Files**: Never copy the local root `configuration.nix` or `hardware-configuration.nix` to the remote host; disk UUIDs and local account/network settings are machine-specific.
4. **Preserve `NIX_BUILD_HOST` Across `sudo`**: `sudo` strips environment variables. Always invoke NixOS commands with `sudo env NIX_BUILD_HOST=<host> ...` (`x1-carbon-8th` | `surface-laptop-3` | `ryzen-4750g` | `vm-image` | `usb-boot-stick`).

## Step-by-Step Procedure

### 1. Inspect Remote State & Diff Over SSH

Determine whether the remote target is a **Live Installer** (`/mnt/etc/nixos`) or an **Installed System** (`/etc/nixos`), and inspect its current state before making changes:

```bash
# Installed system (/etc/nixos) or Live installer (/mnt/etc/nixos)
ssh -o ConnectTimeout=10 -o BatchMode=yes <user@host> '
  repo_dir=/etc/nixos
  [ -d /mnt/etc/nixos ] && repo_dir=/mnt/etc/nixos
  echo "repo_dir=$repo_dir"
  uname -a
  git -C "$repo_dir" status -s
  git -C "$repo_dir" --no-pager diff
'
```

- **For Live Installer (`/mnt/etc/nixos`)**:
  - Verify mounts & swap: `lsblk`, `swapon --show`, and `/mnt/etc/nixos/hardware-configuration.nix`.
    - Laptop hosts (`x1-carbon-8th`, `surface-laptop-3`) import [laptop.nix](../../../profiles/laptop.nix) → [swap.nix](../../../system/swap.nix), which throws unless `hardware-configuration.nix` defines exactly one `/dev/` swap partition without random encryption.
    - Run `sudo bash /mnt/etc/nixos/scripts/mount.sh` (mounts `/mnt`, mounts `/mnt/boot` with `umask=0077`, and activates `/dev/disk/by-label/swap` if present) before `sudo nixos-generate-config --root /mnt`.
  - Verify root channels & binary cache substituters:
    - Run `sudo bash /mnt/etc/nixos/scripts/nixconfig.sh` so `root` has both `nixos` and `unstable` channels registered/updated and `/root/.config/nix/nix.conf` contains mainland `substituters` from [sources.nix](../../../sources.nix) (preventing fallback to `cache.nixos.org` during `nixos-install`).

- **For Installed System (`/etc/nixos`)**:
  - Check health and hardware logs:
    ```bash
    ssh -o ConnectTimeout=10 -o BatchMode=yes <user@host> '
      systemctl --failed --no-pager
      sudo dmesg --level=emerg,alert,crit,err,warn
      sudo journalctl -b -p err --no-pager
      swapon --show
      df -Th / /boot
    '
    ```
  - If `bootctl` warns that `/boot` or `/boot/loader/random-seed` is world-accessible, ensure `fileSystems."/boot".options` in the remote `/etc/nixos/hardware-configuration.nix` uses `[ "fmask=0077" "dmask=0077" ]`.

### 2. Edit Locally & Run Targeted Validation

1. Update the relevant files in the local workspace (`hosts/`, `profiles/`, `services/`, `system/`, `packages/`, `scripts/`) and corresponding tests under [tests/](../../../tests).
2. Format Nix files if any `.nix` file changed:
   ```bash
   make fmt
   ```
3. Run fast, targeted checks covering the modified scope (avoid full `make check` during rapid iteration unless doing final regression verification):
   ```bash
   make check-syntax
   make check-script-<name>   # e.g., make check-script-mount check-script-channels
   make check-module-<name>   # e.g., make check-module-keyd check-module-swap
   make check-host-<host>     # e.g., make check-host-surface-laptop-3
   ```

### 3. Sync Changed Tracked Files via SCP & Verify Checksums

Copy **only** the modified tracked files (excluding any files with remote-only SSH debug overrides) to the remote repository and verify SHA-256 parity:

```bash
# Example: syncing updated files to /etc/nixos (use /mnt/etc/nixos on Live ISO)
scp <path/to/file> <user@host>:/etc/nixos/<path/to/file>

# Verify local and remote SHA-256 hashes match
sha256sum <path/to/file> ...
ssh -o ConnectTimeout=10 -o BatchMode=yes <user@host> 'cd /etc/nixos && sha256sum <path/to/file> ...'
```

### 4. Evaluate & Apply on the Remote Host

1. **Validate the remote machine-local configuration** with [local.nix](../../../tests/local.nix):
   ```bash
   ssh -o ConnectTimeout=10 -o BatchMode=yes <user@host> '
     sudo env -u NIXPKGS_ALLOW_UNFREE NIX_BUILD_HOST=<host> \
       nix-instantiate --eval --strict --option allow-import-from-derivation false \
       --json /etc/nixos/tests/local.nix \
       --argstr configuration /etc/nixos/configuration.nix
   '
   ```
   Confirm `warnings` is `[]` and `toplevel` produces a valid `.drv` path.

2. **Apply the configuration**:
   - On an **Installed System**:
     ```bash
     ssh -o ConnectTimeout=10 -o BatchMode=yes <user@host> '
       sudo env NIX_BUILD_HOST=<host> nixos-rebuild switch
     '
     ```
   - On a **Live Installer** (after confirming evaluation succeeds):
     ```bash
     sudo env NIX_BUILD_HOST=<host> nixos-install --root /mnt
     ```

3. **Verify live runtime state**:
   - Check affected services, kernel modules (`lsmod`), input devices (`libinput list-devices`, `journalctl -b -u keyd`), power/wakeup state, and `systemctl --failed`.
