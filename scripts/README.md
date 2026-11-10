# Scripts

| Script                       | Purpose                                                                                                               |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| [channel.sh](channel.sh)     | Register `nixos` and `unstable` (default) or a single specified channel using [sources.nix](../sources.nix). Leaves `nix.conf` unchanged and does not update channels. |
| [disk-init.sh](disk-init.sh) | Partition and format a disk for UEFI installation, with optional hibernation swap.                                                                                     |
| [iommu.sh](iommu.sh)         | List PCI devices by IOMMU group. Requires `lspci`.                                                                                                                     |
| [mount.sh](mount.sh)         | Mount the `nixos` filesystem at `/mnt`, `EFI` at `/mnt/boot`, activate `swap` if present, and display disk usage.                                                      |
| [nixconfig.sh](nixconfig.sh) | Write `substituters` from [sources.nix](../sources.nix) to `~/.config/nix/nix.conf`, then register and update `nixos` and `unstable` (default) or a specified channel. |

Use `sudo bash scripts/<script>.sh` for disk, mount, and system channel operations. Channel scripts work from any directory and manage the invoking user's channels.

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
