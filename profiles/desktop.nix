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

{ lib, ... }:
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
    ../services/samba-client.nix
  ];

  # NetworkManager re-enables IPv6 on every managed connection whose
  # ipv6.method is not "disabled", so disable_ipv6 sysctls have no effect here;
  # use `nmcli connection modify <name> ipv6.method disabled` per connection.
  networking = {
    networkmanager.enable = true;
    nftables.enable = lib.mkDefault true;
    useDHCP = false;
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

    # Printing and Xorg are off by default; Plasma runs as a Wayland session
    # with XWayland, and a host can still opt back in.
    printing.enable = lib.mkDefault false;
    xserver.enable = lib.mkDefault false;
  };
}
