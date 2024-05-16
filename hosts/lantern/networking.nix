# File: networking.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 11:52:28 pm
# Last Modified: Sunday, August 14th 2022, 11:54:48 pm
#
# http://www.opensource.org/licenses/MIT

{ config, lib, ... }:

let host = builtins.getEnv "NIX_BUILD_HOST";
in {
  networking = {
    hostName = "${host}";

    # head -c4 /dev/urandom | od -A none -t x4
    hostId = "f262c6e7";

    enableIPv6 = lib.mkForce false;
    useDHCP = lib.mkForce false;

    interfaces."bond0" = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.0.4";
        prefixLength = 23;
      }];
    };

    bonds = {
      "bond0" = {
        interfaces = [ "eno3" "eno4" ];
        driverOptions = {
          #mode = "802.3ad";
          mode = "active-backup";
          miimon = "100";
        };
      };
    };

    defaultGateway = "192.168.0.1";
    nameservers = [ "192.168.0.1" "192.168.1.254" ];
    firewall = { enable = false; };
  };
}
