let
  t = import ../lib.nix;
  config = t.eval [ ../../packages/gui.nix ];
in
t.check "modules/gui-headless" {
  unstable-unavailable = !(builtins.tryEval (import <unstable>)).success;
  evaluates = t.validSystem config;
  no-desktop-user = !(config.users.users ? mingcheng);
  no-flatpak = !config.services.flatpak.enable && !(config.systemd.services ? flatpak-flathub);
  no-portals = !config.xdg.portal.enable;
  no-wayland-flags = !(config.environment.sessionVariables ? NIXOS_OZONE_WL);
}
