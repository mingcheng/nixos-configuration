#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: default.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 1970-01-01 08:00:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-05 11:23:53
##

{
  imports = [
    # Shared system policy.
    ../../profiles/base.nix

    ../../system/boot.nix
    ../../system/ld.nix
    ../../system/power.nix
    ../../system/swap.nix

    # Host services.
    ../../services/fstrim.nix
    ../../services/timesyncd.nix
    ../../services/docker.nix
    ../../services/keyd.nix

    # Hardware, desktop composition, and host tools.
    ./kernel.nix
    ./tuning.nix

    ./desktop.nix
    ./packages.nix
  ];

  networking = {
    networkmanager.enable = true;
    useDHCP = false;
  };
}
