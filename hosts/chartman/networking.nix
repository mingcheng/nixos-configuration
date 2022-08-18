# File: networking.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 11:52:28 pm
# Last Modified: Sunday, August 14th 2022, 11:54:48 pm
#
# http://www.opensource.org/licenses/MIT

{ config, lib, ... }: {
  networking = {
    hostName = "chartman";

    enableIPv6 = lib.mkForce false;
    useDHCP = lib.mkForce false;

    interfaces = {
      "br0" = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "192.168.0.8";
          prefixLength = 23;
        }];
      };
    };

    bridges = {
      "br0" = { interfaces = [ "enp1s0f0" "enp1s0f1" "enp1s0f2" "enp1s0f3" ]; };
    };

    defaultGateway = "192.168.1.254";
    nameservers = [ "192.168.1.254" ];
  };
}
