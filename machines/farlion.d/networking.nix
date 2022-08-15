/*
  * File: networking.nix
  * Author: Ming Cheng<mingcheng@outlook.com>
  *
  * Created Date: Monday, August 15th 2022, 12:01:52 am
  * Last Modified: Monday, August 15th 2022, 12:02:21 am
  *
  * http://www.opensource.org/licenses/MIT
*/

{ config, lib, ... }:
{
  networking = {
    hostName = "farlion";

    enableIPv6 = lib.mkForce false;
    useDHCP = lib.mkForce false;

    interfaces = {
      "enp7s0" = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "192.168.0.11";
          prefixLength = 23;
        }];
      };
    };

    defaultGateway = "192.168.1.254";
    nameservers = [ "192.168.1.254" ];
  };
}
