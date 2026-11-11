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
  imports = [
    ./user-packages.nix
    ../services/flatpak.nix
  ];

  config = lib.mkMerge [
    (lib.mkIf hasGui {
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        MOZ_ENABLE_WAYLAND = "1";
        QT_QPA_PLATFORM = "wayland;xcb";
        GDK_BACKEND = "wayland,x11";
        SDL_VIDEODRIVER = "wayland";
      };

      # programs.firefox.enable = lib.mkDefault true;
      programs.git.enable = lib.mkDefault true;
      services.flatpak.enable = lib.mkDefault true;

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ]
        ++ lib.optionals config.services.desktopManager.plasma6.enable [
          pkgs.kdePackages.xdg-desktop-portal-kde
        ];
        configPackages = lib.mkIf config.services.desktopManager.plasma6.enable (
          lib.mkDefault [ pkgs.kdePackages.plasma-workspace ]
        );
        # A generic portals.conf would override KDE's screen-sharing backend.
        config.common.default = lib.mkIf (config.xdg.portal.configPackages == [ ]) (
          lib.mkDefault [ "gtk" ]
        );
      };
    })
    (lib.mkIf (config.services.desktopManager.plasma6.enable && config.workstation.users != [ ]) {
      environment.plasma6.excludePackages = plasmaUserPackages;
      workstation.userPackages = plasmaUserPackages;
    })
    (import ./vscode.nix {
      inherit lib pkgs;
      hasGui = hasGui && config.workstation.users != [ ];
    })
  ];
}
