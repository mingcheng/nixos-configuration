# Scripts

| Script                       | Purpose                                                                                                               |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| [channel.sh](channel.sh)     | Register `nixos` (default) or `unstable` using the URL in [sources.nix](../sources.nix). Does not update the channel. |
| [disk-init.sh](disk-init.sh) | Partition and format a disk for UEFI installation, with optional hibernation swap.                                    |
| [iommu.sh](iommu.sh)         | List PCI devices by IOMMU group. Requires `lspci`.                                                                    |
| [mount.sh](mount.sh)         | Mount the `nixos` filesystem at `/mnt` and `EFI` at `/mnt/boot`, then display disk usage.                             |
| [nixconfig.sh](nixconfig.sh) | Register and update only the selected channel: `nixos` (default) or `unstable`. Leaves `nix.conf` unchanged.          |

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

The script does not mount filesystems, activate swap, or install a bootloader. Use [mount.sh](mount.sh) for the `/boot` layout. USB configurations using `/efi` must mount EFI at `/mnt/efi` instead. Labels must be unique when mounting by label.

If swap was created, run `sudo swapon /dev/disk/by-label/swap` before `nixos-generate-config --root /mnt` so it is included in the generated hardware configuration. Hibernation also requires compatible hardware and a configured resume device.
