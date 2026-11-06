#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: boot.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Thursday, August 18th 2022, 11:07:28 am
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-06 10:30:39
##

{ lib, ... }: {
  boot = {
    plymouth.enable = false;

    loader = {
      timeout = 3;
      efi.canTouchEfiVariables = true;
      grub.enable = false;
      systemd-boot = {
        enable = true;
        configurationLimit = 7;
      };
    };
    supportedFilesystems = [
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
