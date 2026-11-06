let
  t = import ../lib.nix;
  flathub = (import ../../sources.nix).flathub;
  config = t.eval [
    ../../services/flatpak.nix
    {
      services.flatpak.enable = true;
      xdg.portal = {
        enable = true;
        extraPortals = [ t.pkgs.xdg-desktop-portal-gtk ];
        config.common.default = [ "gtk" ];
      };
    }
  ];
  service = config.systemd.services.flatpak-flathub;
in
t.check "modules/flatpak" {
  evaluates = t.validSystem config;
  mirror-source =
    service.environment.FLATHUB_REPO == flathub.repository
    && service.environment.FLATHUB_URL == flathub.mirror;
  network-ordering =
    builtins.elem "network-online.target" service.wants
    && builtins.elem "network-online.target" service.after;
  idempotent-setup = t.lib.hasInfix "--if-not-exists" service.script;
  verified-mirror = t.lib.hasInfix "--gpg-verify --no-follow-redirect" service.script;
  failures-retry =
    service.serviceConfig.Restart == "on-failure"
    && service.serviceConfig.RestartSec == "1min"
    && t.lib.hasInfix "set -eu" service.script;
}
