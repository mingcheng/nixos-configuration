let
  t = import ../lib.nix;
  flathub = (import ../../sources.nix).flathub;
  basePortal = {
    xdg.portal = {
      enable = true;
      extraPortals = [ t.pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [ "gtk" ];
    };
  };
  config = t.eval [
    ../../services/flatpak.nix
    basePortal
    {
      services.flatpak.enable = true;
    }
  ];
  custom = t.eval [
    ../../services/flatpak.nix
    basePortal
    {
      services.flatpak = {
        enable = true;
        packages = [ ];
        update = {
          onActivation = false;
          auto.enable = false;
        };
      };
    }
  ];
  service = config.systemd.services.flatpak-flathub;
  userService = config.systemd.user.services.flatpak-flathub;
  updateService = config.systemd.services.flatpak-update;
  updateTimer = config.systemd.timers.flatpak-update;
in
t.check "modules/flatpak" {
  evaluates = t.validSystem config;
  custom-evaluates = t.validSystem custom;
  mirror-source =
    service.environment.FLATHUB_REPO == flathub.repository
    && service.environment.FLATHUB_URL == flathub.mirror;
  user-mirror-source =
    userService.environment.FLATHUB_REPO == flathub.repository
    && userService.environment.FLATHUB_URL == flathub.mirror
    && userService.unitConfig.ConditionUser == "!@system"
    && !(builtins.elem "network-online.target" userService.wants)
    && t.lib.hasInfix "flatpak remotes --user --columns=name | grep -qxF flathub" userService.script
    && t.lib.hasInfix "remote-add --user --if-not-exists" userService.script
    && t.lib.hasInfix "remote-modify --user --gpg-verify --no-follow-redirect" userService.script;
  network-ordering =
    builtins.elem "network-online.target" service.wants
    && builtins.elem "network-online.target" service.after;
  idempotent-setup =
    t.lib.hasInfix "flatpak remotes --system --columns=name | grep -qxF flathub" service.script
    && t.lib.hasInfix "--if-not-exists" service.script;
  verified-mirror = t.lib.hasInfix "--gpg-verify --no-follow-redirect" service.script;
  default-packages =
    config.services.flatpak.packages == [
      "org.mozilla.firefox"
      "org.videolan.VLC"
      "org.libreoffice.LibreOffice"
    ]
    && t.lib.hasInfix "flatpak install --system --noninteractive --or-update flathub" service.script
    && t.lib.all (app: t.lib.hasInfix app service.script) config.services.flatpak.packages;
  managed-state-reconciliation =
    t.lib.hasInfix "/var/lib/flatpak/nixos-managed" service.script
    && t.lib.hasInfix "flatpak uninstall --system --noninteractive" service.script
    && t.lib.hasInfix "flatpak uninstall --system --unused --noninteractive" service.script;
  activation-update-toggle =
    t.lib.hasInfix "flatpak update --system --noninteractive" service.script
    && !(t.lib.hasInfix "flatpak update --system --noninteractive" custom.systemd.services.flatpak-flathub.script)
    && !(t.lib.hasInfix "flatpak install --system" custom.systemd.services.flatpak-flathub.script);
  auto-update-timer =
    updateTimer.timerConfig.OnCalendar == "weekly"
    && updateTimer.timerConfig.Persistent
    && builtins.elem "flatpak-flathub.service" updateService.requires
    && t.lib.hasInfix "flatpak update --system --noninteractive" updateService.script
    && !(custom.systemd.services ? flatpak-update)
    && !(custom.systemd.timers ? flatpak-update);
  failures-retry =
    service.serviceConfig.Restart == "on-failure"
    && service.serviceConfig.RestartSec == "1min"
    && t.lib.hasInfix "set -eu" service.script;
}
