# File: networking.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 11:52:28 pm
# Last Modified: Sunday, August 14th 2022, 11:54:48 pm
#
# http://www.opensource.org/licenses/MIT

{ lib, ... }:
let host = builtins.getEnv "NIX_BUILD_HOST";
in {
  services.udev = {
    extraRules = ''
      SUBSYSTEM == "net", ACTION=="add", DRIVERS=="igb", NAME="eth0"
    '';
  };

  networking = {
    hostName = "${host}";
    enableIPv6 = lib.mkForce false;
    useDHCP = lib.mkForce false;
    interfaces = {
      "eth0" = { useDHCP = false; };
      "br0" = { useDHCP = true; };
    };
    bridges = { "br0" = { interfaces = [ "eth0" ]; }; };
  };
}
