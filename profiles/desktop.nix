#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: desktop.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 1970-01-01 08:00:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-07 08:32:02
##

{ config, lib, ... }:
{
  # Keep desktop-only features together; locale/timezone live in system/i18n.nix.
  imports = [
    ./base.nix
    ../packages/gui.nix
    ../system/fonts.nix
    ../system/input_method.nix
    ../services/pipewire.nix
    ../services/keyd.nix
  ];

  networking = {
    networkmanager.enable = true;
    useDHCP = false;
    resolvconf.extraConfig = lib.optionalString (
      config.services.nscd.enable && config.services.nscd.enableNsncd
    ) "libc_restart=':'";
  };

  services = {
    desktopManager.plasma6.enable = true;
    displayManager = {
      defaultSession = "plasma";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

    libinput.enable = true;
    printing.enable = true;
  };
}
