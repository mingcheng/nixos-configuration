# File: networking.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 11:52:28 pm
# Last Modified: Sunday, August 14th 2022, 11:54:48 pm
#
# http://www.opensource.org/licenses/MIT

{ config, lib, ... }: {
  networking = {
    hostName = "supermicro";

    enableIPv6 = lib.mkForce false;
    useDHCP = lib.mkForce false;

    interfaces = {
      "br0" = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "192.168.0.2";
          prefixLength = 23;
        }];
      };
    };

    #      "bond1" = {
    #        interfaces = [ "enp1s0f2" "enp1s0f3" ];
    #        driverOptions = { mode = "802.3 ad"; };
    #      };
    #    };

    # bridges = { "br0" = { interfaces = [ "bond0" "bond1" ]; }; };
    bridges = {
      "br0" = { interfaces = [ "enp1s0f0" "enp1s0f1" "enp1s0f2" "enp1s0f3" ]; };
    };

    defaultGateway = {
      address = "192.168.0.1";
      interface = "br0";
    };

    nameservers = [ "192.168.0.1" ];
  };
}
