# File: networking.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Monday, August 15th 2022, 12:01:52 am
# Last Modified: Monday, August 15th 2022, 12:02:21 am
#
# http://www.opensource.org/licenses/MIT

{ pkgs, lib, ... }: {
  imports = [
    ../qemu/udev.nix
    ./firewall.nix
  ];

  networking.useDHCP = lib.mkForce false;
  networking = {
    hostName = "snowflake";
    interfaces = {
      "eth0" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "172.16.0.201";
            prefixLength = 24;
          }
        ];
      };
    };

    defaultGateway = "172.16.0.1";
    nameservers = [ "172.16.0.1" ];
  };
}
