# File: fs.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 11:20:01 am
# Last Modified: Thursday, August 18th 2022, 11:20:03 am
#
# http://www.opensource.org/licenses/MIT

{ pkgs, lib, ... }: {
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    neededForBoot = true;
    options = [ "defaults" "discard" "noatime" ];
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };
}
