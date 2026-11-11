#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: resolved.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Friday, August 19th 2022, 10:24:36 am
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-11 12:30:03
##

{ config, lib, ... }:
let
  cfg = config.services.resolved;
  adguard = config.services.adguardhome;
in
{
  services.resolved = {
    enable = lib.mkDefault true;
    settings.Resolve = lib.mkMerge [
      {
        DNSSEC = lib.mkDefault "false";
      }
      (lib.mkIf adguard.enable {
        DNS = lib.mkDefault adguard.settings.dns.bind_hosts;
        FallbackDNS = lib.mkDefault [ ];
        Domains = lib.mkDefault [ "~." ];
        DNSOverTLS = lib.mkDefault "false";
        DNSStubListener = lib.mkDefault "no";
      })
    ];
  };

  environment.etc."resolv.conf" =
    lib.mkIf (cfg.enable && adguard.enable && (cfg.settings.Resolve.DNSStubListener or null) == "no")
      {
        source = lib.mkForce "/run/systemd/resolve/resolv.conf";
      };
}
