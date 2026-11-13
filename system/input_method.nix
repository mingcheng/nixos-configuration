#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: input-method.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 1970-01-01 08:00:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-06 23:01:44
##

{
  config,
  lib,
  pkgs,
  ...
}:
let
  inputMethod = config.i18n.inputMethod;
  fcitxEnabled = inputMethod.enable && inputMethod.type == "fcitx5";

  # Keep the Rime engine and its schema data in one place.
  fcitx5Rime = pkgs.fcitx5-rime.override {
    rimeDataPkgs = [ pkgs.rime-wanxiang ];
  };
in
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        # Configuration UI and toolkit integration.
        fcitx5-fluent
        qt6Packages.fcitx5-configtool
        fcitx5-gtk
        qt6Packages.fcitx5-qt

        # Chinese input engines and Rime schema data.
        qt6Packages.fcitx5-chinese-addons
        librime
        librime-lua
        fcitx5Rime
      ];
    };
  };

  # Toolkit/XWayland compatibility; native Electron uses KWin's input method
  # connection instead of these GTK/Qt variables.
  environment.sessionVariables = lib.mkIf fcitxEnabled {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    SDL_IM_MODULE = "fcitx";
  };

  # Plasma-specific integration: KWin must launch Fcitx to pass it the privileged
  # Wayland input-method socket. waylandFrontend alone does not select it.
  # User-level kwinrc settings can override this system default.
  environment.etc =
    lib.mkIf
      (
        fcitxEnabled && inputMethod.fcitx5.waylandFrontend && config.services.desktopManager.plasma6.enable
      )
      {
        "xdg/kwinrc".text = ''
          [Wayland]
          InputMethod=${inputMethod.package}/share/applications/org.fcitx.Fcitx5.desktop
          VirtualKeyboardEnabled=true
        '';

        # Avoid a second instance started without KWin's Wayland socket.
        "xdg/autostart/org.fcitx.Fcitx5.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=Fcitx 5
          Hidden=true
        '';
      };
}
