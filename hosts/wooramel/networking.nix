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
  services.udev = {
    extraRules = ''
      SUBSYSTEM == "net", ACTION=="add", DRIVERS=="virtio_net", NAME="eth0"
    '';
  };

  networking = {
    hostName = "${host}";

    # head -c4 /dev/urandom | od -A none -t x4
    hostId = "a96cdf62";

    enableIPv6 = lib.mkForce false;
    useDHCP = lib.mkForce false;

    interfaces = {
      "eth0" = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "192.168.0.14";
          prefixLength = 23;
        }];
      };
    };

    #defaultGateway = { address = "192.168.0.1"; };
    defaultGateway = { address = "192.168.1.254"; };
    nameservers = [ "114.114.114.114" "192.168.1.254" ];
  };

  #networking.dhcpcd.enable = false;
  networking.firewall.enable = false;
}
