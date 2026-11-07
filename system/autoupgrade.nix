#!#
# Copyright (c) 2026 mingcheng
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: autoupgrade.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Tuesday, August 16th 2022, 9:10:16 pm
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-07 22:35:57
##

{ config, lib, ... }:
{
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    channel = (import ../sources.nix).channels.nixos;
  };

  systemd.services.nixos-upgrade = lib.mkIf config.system.autoUpgrade.enable {
    environment.NIX_BUILD_HOST = config.environment.variables.NIX_BUILD_HOST;
  };
}
