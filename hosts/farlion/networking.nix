# File: networking.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Monday, August 15th 2022, 12:01:52 am
# Last Modified: Monday, August 15th 2022, 12:02:21 am
#
# http://www.opensource.org/licenses/MIT

{ pkgs, lib, ... }:
let host = builtins.getEnv "NIX_BUILD_HOST";
in {
  networking = {
    hostName = "${host}";

    enableIPv6 = lib.mkForce false;
    useDHCP = lib.mkForce false;

    interfaces = {
      "eth0" = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "192.168.0.11";
          prefixLength = 23;
        }];
      };
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 2375 ];
    };

    defaultGateway = "192.168.1.254";
    nameservers = [ "192.168.1.254" ];
  };
}
