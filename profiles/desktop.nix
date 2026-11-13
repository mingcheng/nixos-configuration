#!#
# Copyright (c) 2026 mingcheng
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: desktop.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 1970-01-01 08:00:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-13 00:30:17
##

{ config, lib, ... }:
{
  # Keep desktop-only features together; locale/timezone live in system/i18n.nix.
  imports = [
    ./base.nix
    ../packages/gui.nix

    ../system/fonts.nix
    ../system/input_method.nix
    ../system/network_hosts.nix

    ../services/pipewire.nix
    ../services/keyd.nix
  ];

  networking = {
    networkmanager.enable = true;
    nftables.enable = lib.mkDefault true;
    useDHCP = false;
    resolvconf.extraConfig = lib.optionalString (
      config.services.nscd.enable && config.services.nscd.enableNsncd
    ) "libc_restart=':'";
  };

  programs.xwayland.enable = lib.mkDefault true;

  services = {
    dbus.implementation = lib.mkDefault "broker";
    desktopManager.plasma6.enable = true;
    displayManager = {
      defaultSession = "plasma";
      sddm = {
        enable = true;
        wayland = {
          enable = true;
          compositor = lib.mkDefault "kwin";
        };
      };
    };

    libinput.enable = true;

    # Disable printing by default
    printing.enable = lib.mkDefault false;

    # Disable X server by default
    xserver.enable = lib.mkForce false;
  };
}
