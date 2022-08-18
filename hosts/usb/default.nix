# File: usb.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Monday, August 15th 2022, 2:33:25 pm
# Last Modified: Monday, August 15th 2022, 2:33:26 pm
#
# http://www.opensource.org/licenses/MIT

{ pkgs, lib, ... }: {
  imports = [
    #https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/profiles
    (modulesPath + "/profiles/all-hardware.nix")

    ../qemu
    ../../packages/kubectl.nix
    ../../packages/git.nix
    ../../packages/nvim.nix
    ../../packages/netutils.nix
    ../../system/grub.nix

    ../chartman/packages.nix
  ];

  boot.kernel = { sysctl = { "net.ipv6.conf.all.disable_ipv6" = 1; }; };

  boot.kernelParams = [ "verbose" ];

  boot.kernelModules = [
    "btrfs"
    "f2fs"
    "ext4"
    "vfat"
    "nvme"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];

  boot.tmpOnTmpfs = true;
  boot.supportedFilesystems = [ "btrfs" "ext4" "vfat" "f2fs" "xfs" "ntfs" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/24e24f36-6056-42a2-90a2-d0d60027b2ab";
    fsType = "f2fs";
  };

  fileSystems."/efi" = {
    device = "/dev/disk/by-uuid/7E68-0551";
    fsType = "vfat";
  };
}
