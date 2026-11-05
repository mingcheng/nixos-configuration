#!#
# Copyright (c) 2026 mingcheng
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: gui.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-04 11:52:34
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-04 12:12:54
##

{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Wayland sessions can be available without Xorg or a display manager.
  hasGui =
    config.services.xserver.enable
    || config.services.displayManager.enable
    || config.services.displayManager.sessionPackages != [ ];

  # Keep Plasma services, shared plugins and system settings installed globally.
  plasmaUserPackages =
    with pkgs.kdePackages;
    [
      ark
      dolphin
      elisa
      gwenview
      kate
      khelpcenter
      konsole
      okular
      spectacle
    ]
    ++ lib.optional config.networking.networkmanager.enable qrca
    ++ lib.optional (config.services.flatpak.enable || config.services.fwupd.enable) discover;
in
{
  imports = [ ../services/flatpak.nix ];

  config = lib.mkMerge [
    (import ./vscode.nix { inherit lib pkgs hasGui; })
    (lib.mkIf hasGui {
      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      # programs.firefox.enable = lib.mkDefault true;
      programs.git.enable = lib.mkDefault true;
      services.flatpak.enable = lib.mkDefault true;

      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        # A generic portals.conf would override KDE's screen-sharing backend.
        config.common.default = lib.mkIf (config.xdg.portal.configPackages == [ ]) (
          lib.mkDefault [ "gtk" ]
        );
      };
    })
    (lib.mkIf config.services.desktopManager.plasma6.enable {
      environment.plasma6.excludePackages = plasmaUserPackages;
      users.users.mingcheng.packages = plasmaUserPackages;
    })
  ];
}
