let
  t = import ../lib.nix;
  config = t.eval [ ../../services/docker.nix ];
  docker = config.virtualisation.docker;
  changed =
    (t.eval [
      ../../services/docker.nix
      {
        virtualisation.docker = {
          daemon.settings = {
            debug = true;
            experimental = true;
          };
          liveRestore = false;
          autoPrune = {
            enable = false;
            dates = "daily";
            flags = [
              "--filter"
              "until=24h"
            ];
          };
        };
      }
    ]).virtualisation.docker;
in
t.check "modules/docker" {
  evaluates = t.validSystem config;
  enabled = docker.enable;
  stable-daemon = !docker.daemon.settings.debug && !docker.daemon.settings.experimental;
  live-restore = docker.liveRestore;
  pruning =
    docker.autoPrune.enable
    && docker.autoPrune.dates == "weekly"
    &&
      docker.autoPrune.flags == [
        "--all"
        "--filter"
        "until=168h"
      ];
  defaults-overridable =
    changed.daemon.settings.debug
    && changed.daemon.settings.experimental
    && !changed.liveRestore
    && !changed.autoPrune.enable
    && changed.autoPrune.dates == "daily"
    &&
      changed.autoPrune.flags == [
        "--filter"
        "until=24h"
      ];
  compose = t.hasPackages config.environment.systemPackages [ "docker-compose" ];
  no-registry-override =
    !(docker.daemon.settings ? registry-mirrors) && !(docker.daemon.settings ? insecure-registries);
}
