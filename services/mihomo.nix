#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: mihomo.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-10 16:20:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-10 18:31:51
##

{
  config,
  lib,
  pkgs,
  ...
}:
let
  configPath = toString config.services.mihomo.configFile;
in
{
  networking.proxy = {
    default = lib.mkDefault "http://127.0.0.1:7890";
    noProxy = lib.mkDefault "127.0.0.1,localhost,internal.domain";
  };

  services.mihomo = {
    enable = true;
    configFile = lib.mkDefault "/etc/mihomo.yaml";
    tunMode = lib.mkDefault true;
    webui = lib.mkDefault pkgs.metacubexd;
  };

  systemd = {
    services.mihomo.after = [ "adguardhome.service" ];

    tmpfiles.settings.mihomo.${configPath}.f = {
      mode = "0600";
      argument = lib.mkDefault ''
        mixed-port: 7890
        bind-address: 127.0.0.1
        allow-lan: false
        mode: direct
        log-level: info
        rules:
          - MATCH,DIRECT
      '';
    };
  };
}
