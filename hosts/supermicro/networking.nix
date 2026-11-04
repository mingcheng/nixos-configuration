# File: networking.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 11:52:28 pm
# Last Modified: Sunday, August 14th 2022, 11:54:48 pm
#
# http://www.opensource.org/licenses/MIT

{ config, lib, ... }:
let
  host = builtins.getEnv "NIX_BUILD_HOST";
in
{
  networking = {
    hostName = "${host}";

    enableIPv6 = lib.mkForce false;
    useDHCP = lib.mkForce false;

    interfaces = {
      "br0" = {
        ipv4.addresses = [
          {
            address = "192.168.0.2";
            prefixLength = 24;
          }
        ];

      };
    };

    bonds = {
      "bond0" = {
        interfaces = [
          "enp1s0f0"
          "enp1s0f1"
          "enp1s0f2"
          "enp1s0f3"
        ];
        driverOptions = {
          miimon = "100";
          #mode = "802.3ad";
          mode = "active-backup";
        };
      };
    };

    bridges = {
      "br0" = {
        interfaces = [ "bond0" ];
      };
    };

    defaultGateway = {
      address = "192.168.0.252";
      interface = "br0";
    };

    nameservers = [ "192.168.0.252" ];
    firewall.enable = false;
  };
}
