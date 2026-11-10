#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: adguard.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-10 16:20:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-10 17:03:12
##

{ lib, ... }:
{
  networking = {
    nameservers = lib.mkForce [ "127.0.0.1" ];
    networkmanager.insertNameservers = lib.mkForce [ "127.0.0.1" ];
  };

  services.adguardhome = {
    enable = true;
    allowDHCP = lib.mkForce false;
    openFirewall = lib.mkForce false;
    mutableSettings = lib.mkForce true;
    host = lib.mkForce "127.0.0.1";
    port = lib.mkForce 9527;
    settings = {
      dhcp.enabled = lib.mkForce false;
      dns = {
        bind_hosts = lib.mkForce [ "127.0.0.1" ];
        port = lib.mkForce 53;
        bootstrap_dns = lib.mkDefault [
          "223.5.5.5"
          "223.6.6.6"
        ];
        upstream_dns = lib.mkDefault [
          "https://dns.alidns.com/dns-query"
          "https://doh.pub/dns-query"
        ];
      };
      filters = lib.mkDefault [
        {
          enabled = true;
          id = 1;
          name = "AdGuard DNS filter";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
        }
        {
          enabled = true;
          id = 2;
          name = "AdAway Default Blocklist";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
        }
        {
          enabled = true;
          id = 33;
          name = "Steven Black's List";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_33.txt";
        }
        {
          enabled = true;
          id = 21;
          name = "CHN: anti-AD";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_21.txt";
        }
        {
          enabled = true;
          id = 29;
          name = "CHN: AdRules DNS List";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_29.txt";
        }
      ];
    };
  };
}
