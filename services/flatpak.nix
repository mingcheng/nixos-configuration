#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: flatpak.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-04 11:52:34
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-10 19:49:08
##

{
  config,
  lib,
  ...
}:
let
  cfg = config.services.flatpak;
  flathub = (import ../sources.nix).flathub;
  desiredPackages = lib.unique cfg.packages;
in
{
  options.services.flatpak = {
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.nonEmptyStr;
      default = [
        "org.mozilla.firefox"
        "org.videolan.VLC"
        "org.libreoffice.LibreOffice"
      ];
      description = "System-wide Flatpak application IDs installed declaratively from Flathub.";
    };

    update = {
      onActivation = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to update system Flatpak packages when configuring Flathub.";
      };

      auto = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to periodically update system Flatpak packages.";
        };

        onCalendar = lib.mkOption {
          type = lib.types.nonEmptyStr;
          default = "weekly";
          description = "systemd calendar expression for automatic system Flatpak updates.";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.flatpak-flathub = {
      description = "Configure the system Flathub mirror and preinstalled applications";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = [ cfg.package ];
      environment = {
        FLATHUB_REPO = flathub.repository;
        FLATHUB_URL = flathub.mirror;
      };
      script = ''
        set -eu
        flatpak remote-add --system --if-not-exists --from flathub \
          "$FLATHUB_REPO"
        flatpak remote-modify --system --gpg-verify --no-follow-redirect \
          --url="$FLATHUB_URL" flathub

        state_file=/var/lib/flatpak/nixos-managed
        desired_packages=${lib.escapeShellArg (lib.concatStringsSep "\n" desiredPackages)}

        if [ -f "$state_file" ]; then
          while IFS= read -r app; do
            [ -n "$app" ] || continue
            if ! printf '%s\n' "$desired_packages" | grep -qxF "$app"; then
              if flatpak info --system "$app" >/dev/null 2>&1; then
                flatpak uninstall --system --noninteractive "$app"
              fi
            fi
          done < "$state_file"
        fi

        ${lib.optionalString (desiredPackages != [ ]) ''
          flatpak install --system --noninteractive --or-update flathub \
            ${lib.escapeShellArgs desiredPackages}
        ''}
        install -d -m 0755 /var/lib/flatpak
        printf '%s\n' "$desired_packages" > "$state_file"
        ${lib.optionalString cfg.update.onActivation ''
          flatpak update --system --noninteractive
        ''}
        flatpak uninstall --system --unused --noninteractive
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "1min";
        TimeoutStartSec = "15min";
      };
    };

    systemd.services.flatpak-update = lib.mkIf cfg.update.auto.enable {
      description = "Update system Flatpak applications";
      wants = [ "network-online.target" ];
      after = [
        "network-online.target"
        "flatpak-flathub.service"
      ];
      requires = [ "flatpak-flathub.service" ];
      path = [ cfg.package ];
      script = ''
        set -eu
        flatpak update --system --noninteractive
        flatpak uninstall --system --unused --noninteractive
      '';
      serviceConfig = {
        Type = "oneshot";
        TimeoutStartSec = "15min";
      };
    };

    systemd.timers.flatpak-update = lib.mkIf cfg.update.auto.enable {
      description = "Periodic system Flatpak application updates";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.update.auto.onCalendar;
        Persistent = true;
      };
    };

    systemd.user.services.flatpak-flathub = {
      description = "Configure the user Flathub mirror";
      wantedBy = [ "default.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = [ cfg.package ];
      environment = {
        FLATHUB_REPO = flathub.repository;
        FLATHUB_URL = flathub.mirror;
      };
      unitConfig = {
        ConditionUser = "!@system";
      };
      script = ''
        set -eu
        flatpak remote-add --user --if-not-exists --from flathub \
          "$FLATHUB_REPO"
        flatpak remote-modify --user --gpg-verify --no-follow-redirect \
          --url="$FLATHUB_URL" flathub
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "1min";
        TimeoutStartSec = "1min";
      };
    };
  };
}
