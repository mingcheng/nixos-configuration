# File: networking.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 11:52:28 pm
# Last Modified: Sunday, August 14th 2022, 11:54:48 pm
#
# http://www.opensource.org/licenses/MIT

{ config, lib, ... }: {
  networking = {
    hostName = "strix";

    enableIPv6 = lib.mkForce false;
    useDHCP = lib.mkForce false;

    interfaces = {
      "br0" = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "172.16.0.2";
          prefixLength = 24;
        }];
      };

      "br1" = { useDHCP = false; };
    };

    bridges = {
      "br0" = { interfaces = [ "enp1s0f0" "enp1s0f1" "enp1s0f2" "enp1s0f3" ]; };
      "br1" = { interfaces = [ "enp4s0" ]; };
    };

    defaultGateway = {
      address = "172.16.0.1";
      interface = "br0";
    };

    nameservers = [ "172.16.0.1" ];

    firewall.enable = false;
    nftables = {
      enable = true;
      ruleset = ''
        #flush ruleset
        table inet filter {
          chain input {
            type filter hook input priority 0; policy accept;
            ip saddr != 172.16.0.0/24 tcp dport { ssh } drop
          }

          chain output {
            type filter hook output priority 0; policy accept;
          }

          chain forward {
            type filter hook forward priority 0; policy drop;
          }
        }
      '';
    };
  };
}
