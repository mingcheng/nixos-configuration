# File: networking.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 11:52:28 pm
# Last Modified: Sunday, August 14th 2022, 11:54:48 pm
#
# http://www.opensource.org/licenses/MIT

{ config, lib, ... }: {
  services.udev = {
    extraRules = ''
      SUBSYSTEM == "net", ACTION=="add", DRIVERS=="r8169", NAME="eth0"
    '';
  };

  networking = {
    hostName = "lantern";
    # head -c4 /dev/urandom | od -A none -t x4
    hostId = "f262c6e7";

    enableIPv6 = lib.mkForce false;
    useDHCP = lib.mkForce false;

    interfaces = {
      "eth0" = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "192.168.0.5";
          prefixLength = 23;
        }];
      };
    };

    defaultGateway = "192.168.0.1";
    nameservers = [ "192.168.0.1" ];
  };

  networking.firewall.enable = false;
  networking.nftables = {
    enable = true;
    ruleset = ''
      flush ruleset                                                                    
      table inet filter {
        chain input {
          type filter hook input priority 0; policy accept;
        }

        chain output {
          type filter hook output priority 0; policy accept;
        }

        chain forward {
          type filter hook forward priority 0; policy accept;
        }
      }
    '';
  };
}
