# Scripts

| Script                           | Purpose                                                                                                                                                                |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [build-qcow2.sh](build-qcow2.sh) | Build the `vm-image` host configuration into a bootable QEMU `.qcow2` disk image (UEFI or Legacy BIOS, optional copy to output path).                                  |
| [channel.sh](channel.sh)         | Register `nixos` and `unstable` (default) or a single specified channel using [sources.nix](../sources.nix). Leaves `nix.conf` unchanged and does not update channels. |
| [disk-init.sh](disk-init.sh)     | Partition and format a disk for UEFI installation, with optional hibernation swap.                                                                                     |
| [iommu.sh](iommu.sh)             | List PCI devices by IOMMU group. Requires `lspci`.                                                                                                                     |
| [mount.sh](mount.sh)             | Mount the `nixos` filesystem at `/mnt`, `EFI` at `/mnt/boot`, activate `swap` if present, and display disk usage.                                                      |
| [nixconfig.sh](nixconfig.sh)     | Write `substituters` from [sources.nix](../sources.nix) to `~/.config/nix/nix.conf`, then register and update `nixos` and `unstable` (default) or a specified channel. |

Use `sudo bash scripts/<script>.sh` for disk, mount, and system channel operations. Channel and `qcow2` image build scripts work from any directory.

## Building a QEMU `qcow2` image

[build-qcow2.sh](build-qcow2.sh) evaluates `NIX_BUILD_HOST=vm-image` against `<nixpkgs/nixos>` (`config.system.build.image`) with `NIXPKGS_ALLOW_UNFREE=1`. If a gitignored `hosts/vm-image/local.nix` exists, [hosts/vm-image/default.nix](../hosts/vm-image/default.nix) imports it automatically.

```bash
# Build into the Nix store (creates ./result and prints the store .qcow2 path):
bash scripts/build-qcow2.sh

# Build and copy a writable (0644) .qcow2 image to a target file:
bash scripts/build-qcow2.sh -o ./nixos-vm.qcow2

# Customize disk size (in MiB), boot mode, and extra module file:
bash scripts/build-qcow2.sh --legacy --disk-size 16384 --config ./my-vm.nix -o ./nixos-vm.qcow2

# Instantiate the derivation without building the disk image:
bash scripts/build-qcow2.sh --dry-run
```

| Option                   | Description                                                                                       |
| ------------------------ | ------------------------------------------------------------------------------------------------- |
| `-c`, `--config FILE`    | Import an additional NixOS module file on top of `main.nix`.                                      |
| `-s`, `--disk-size SIZE` | Set `virtualisation.diskSize` to `auto` (default) or a positive integer in MiB.                   |
| `--efi`                  | Build a UEFI (`systemd-boot`) image with an ESP `/boot` partition (default).                      |
| `--legacy`               | Build a Legacy BIOS (`GRUB` on `/dev/vda`) image.                                                 |
| `-o`, `--output FILE`    | Copy the resulting `.qcow2` image to `FILE` with mode `0644` (suppresses the `./result` link).    |
| `-n`, `--dry-run`        | Run `nix-instantiate` and print the `.drv` path without building. Cannot be used with `--output`. |
| `-h`, `--help`           | Show usage information.                                                                           |

## Disk initialization

**This destroys existing data on the selected disk.** Back up first and confirm the resolved disk path at the prompt. Mounted disks, active swap, device mappings, and read-only devices are rejected.

Run one of these commands from the NixOS installer, replacing the device path:

```bash
sudo bash scripts/disk-init.sh /dev/nvme0n1
# Or, include swap for hibernation:
sudo bash scripts/disk-init.sh --hibernate /dev/nvme0n1
```

| Partition       | Format     | Label   | Size                                              |
| --------------- | ---------- | ------- | ------------------------------------------------- |
| EFI             | FAT32      | `EFI`   | 1 GiB                                             |
| Swap (optional) | Linux swap | `swap`  | 1.2 times RAM, rounded up to MiB                  |
| Root            | F2FS       | `nixos` | Remaining space; at least 1 GiB must be available |

Swap sizing uses `/proc/meminfo` on the machine running the script. Requires `parted`, `util-linux`, `dosfstools`, `f2fs-tools`, `udevadm`, and `awk` for hibernation. Failures stop the script; completed changes are not rolled back.

The script does not mount filesystems, activate swap, or install a bootloader. Use [mount.sh](mount.sh) for the `/boot` layout (which also activates `/dev/disk/by-label/swap` when present). USB configurations using `/efi` must mount EFI at `/mnt/efi` instead. Labels must be unique when mounting by label.

If mounting manually after creating swap, run `sudo swapon /dev/disk/by-label/swap` before `nixos-generate-config --root /mnt` so it is included in the generated hardware configuration. Hibernation also requires compatible hardware and a configured resume device.
