#!#
# Copyright (c) 2026 mingcheng
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: flatpak.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-04 11:52:34
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-04 11:58:22
##

{
  config,
  lib,
  pkgs,
  ...
}:
let
  flathubUrl = "https://mirrors.ustc.edu.cn/flathub";
in
{
  config = lib.mkIf config.services.flatpak.enable {
    systemd.services.flatpak-flathub = {
      description = "Configure the system Flathub mirror";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = [ config.services.flatpak.package ];
      environment.FLATHUB_URL = flathubUrl;
      script = ''
        set -eu
        flatpak remote-modify --system --gpg-verify --no-follow-redirect \
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
