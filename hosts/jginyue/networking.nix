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
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "192.168.0.3";
            prefixLength = 23;
          }
        ];
      };
    };

    bridges = {
      "br0" = {
        interfaces = [
          "enp3s0f0"
          "enp3s0f1"
          "enp4s0f0"
          "enp4s0f1"
        ];
      };
    };

    defaultGateway = "192.168.1.254";
    nameservers = [
      "192.168.1.254"
      "192.168.0.1"
    ];
  };
}
