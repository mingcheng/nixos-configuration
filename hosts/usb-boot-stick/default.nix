#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: default.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Monday, August 15th 2022, 2:33:25 pm
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-05 11:25:10
##

{
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/all-hardware.nix")

    ../../profiles/base.nix
    ../../system/networking.nix
    ../../packages/kubectl.nix
    ../../packages/git.nix
    ../../packages/nvim.nix
    ../../packages/netutils.nix
    ../../system/grub.nix
  ];

  boot.kernelParams = [
    "verbose"
    "intel_iommu=on"
    "iommu=pt"
  ];
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

  boot.tmp.useTmpfs = true;
  boot.supportedFilesystems = [
    "btrfs"
    "ext4"
    "vfat"
    "f2fs"
    "xfs"
    "ntfs"
  ];

  boot.loader.efi = {
    canTouchEfiVariables = false;
    efiSysMountPoint = "/efi";
  };
}
