let
  t = import ../lib.nix;
  config = t.eval [ ../../packages/gui.nix ];
  noUserDesktop = t.eval [
    ../../packages/gui.nix
    { services.desktopManager.plasma6.enable = true; }
  ];
in
t.check "modules/gui-headless" {
  unstable-unavailable = !(builtins.tryEval (import <unstable>)).success;
  evaluates = t.validSystem config;
  no-desktop-user = !(config.users.users ? mingcheng);
  no-flatpak =
    !config.services.flatpak.enable
    && !(config.systemd.services ? flatpak-flathub)
    && !(config.systemd.services ? flatpak-update)
    && !(config.systemd.timers ? flatpak-update)
    && !(config.systemd.user.services ? flatpak-flathub);
  no-portals = !config.xdg.portal.enable && !config.xdg.portal.xdgOpenUsePortal;
  no-wayland-flags = t.lib.all (name: !(builtins.hasAttr name config.environment.sessionVariables)) [
    "NIXOS_OZONE_WL"
    "ELECTRON_OZONE_PLATFORM_HINT"
    "MOZ_ENABLE_WAYLAND"
    "QT_QPA_PLATFORM"
    "GDK_BACKEND"
    "SDL_VIDEODRIVER"
  ];
  no-user-desktop-evaluates = t.validSystem noUserDesktop;
  no-user-desktop-portals =
    noUserDesktop.xdg.portal.enable
    && noUserDesktop.xdg.portal.xdgOpenUsePortal
    && !(noUserDesktop.xdg.portal.config.common ? default)
    && t.hasPackages noUserDesktop.xdg.portal.configPackages [ "plasma-workspace" ]
    && t.hasPackages noUserDesktop.xdg.portal.extraPortals [
      "xdg-desktop-portal-kde"
      "xdg-desktop-portal-gtk"
    ];
  no-user-desktop-keeps-applications = t.hasPackages noUserDesktop.environment.systemPackages [
    "konsole"
    "dolphin"
  ];
  no-user-desktop-keeps-accounts =
    noUserDesktop.workstation.users == [ ]
    && noUserDesktop.workstation.userPackages == [ ]
    && !(noUserDesktop.users.users ? mingcheng);
}
