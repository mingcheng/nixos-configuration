# File: boot.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 11:07:28 am
# Last Modified: Thursday, August 18th 2022, 11:07:39 am
#
# http://www.opensource.org/licenses/MIT

{ lib, ... }: {
  boot = {
    plymouth.enable = false;

    loader = {
      timeout = 3;
      efi.canTouchEfiVariables = true;
      grub.enable = false;
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };
    };
    supportedFilesystems = lib.mkForce [
      "ext4"
      "vfat"
      "f2fs"
    ];

    initrd = {
      availableKernelModules = [
        "f2fs"
        "ext4"
        "nvme"
        "ahci"
        "vfat"
      ];
    };
  };
}
