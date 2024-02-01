# File: zfs.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Monday, August 22nd 2022, 10:51:17 am
# Last Modified: Monday, August 22nd 2022, 12:55:23 pm
#
# http://www.opensource.org/licenses/MIT

# https://github.com/NixOS/nixpkgs/blob/6039648c50c7c0858b5e506c6298773a98e0f066/nixos/modules/tasks/filesystems/zfs.nix#L303

{ config, lib, ... }: {
  boot.zfs = {
    #enabled = lib.mkForce true;
    enableUnstable = false;
    #forceImportAll = true;
    extraPools = [ "tank" "ship" ];
    #devNodes = "/dev/disk/by-partuuid/4de39412-70a4-064b-a2ef-ce263a9f3274";
  };

  services.zfs = {
    trim.enable = true;
    autoScrub = {
      enable = true;
      interval = "monthly";
    };

    autoSnapshot.enable = true;
  };
}

