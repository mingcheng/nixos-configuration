# File: boot.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 11:07:28 am
# Last Modified: Thursday, August 18th 2022, 11:07:39 am
#
# http://www.opensource.org/licenses/MIT

{ pkgs, lib, ... }: {
  boot = {
    plymouth.enable = false;

    loader = {
      timeout = 3;
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
        #memtest86.enable = true;
      };
    };
    supportedFilesystems = lib.mkForce [ "btrfs" "ext4" "vfat" "f2fs" ];

    initrd = {
      availableKernelModules = [ "f2fs" "ext4" "btrfs" "nvme" "vfat" ];
    };

    extraModulePackages = [ ];
  };
}
