# File: networking.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 11:52:28 pm
# Last Modified: Sunday, August 14th 2022, 11:54:48 pm
#
# http://www.opensource.org/licenses/MIT

{ config, lib, ... }: {
  # services.udev = {
  #   extraRules = ''
  #     SUBSYSTEM == "net", ACTION=="add", DRIVERS=="r8169", NAME="eth0"
  #   '';
  # };

  networking = {
    hostName = "wooramel";
    # head -c4 /dev/urandom | od -A none -t x4
    hostId = "a96cdf62";

    enableIPv6 = lib.mkForce false;
    useDHCP = lib.mkForce false;

    # https://github.com/NixOS/nixpkgs/issues/49534#issuecomment-528620896
    interfaces = {
      "bond0" = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "192.168.0.4";
          prefixLength = 23;
        }];
      };
    };

    bonds = {
      "bond0" = {
        interfaces = [ "eno3" "eno4" ];
        driverOptions = {
          mode = "802.3ad";
          xmit_hash_policy = "layer3+4";
          lacp_rate = "fast";
          downdelay = "200";
          miimon = "100";
          updelay = "200";
        };
      };
    };

    defaultGateway = { address = "192.168.0.1"; };

    nameservers = [ "192.168.0.1" ];
  };

  #networking.dhcpcd.enable = false;
  networking.firewall.enable = false;

  /* networking.nftables = {
       enable = true;
       ruleset = ''
         flush ruleset
         table inet filter {
           chain input {
             type filter hook input priority 0; policy accept;
           }

           chain output {
             type filter hook output priority 0; policy accept;
           }

           chain forward {
             type filter hook forward priority 0; policy accept;
           }
         }
       '';
     };
  */
}
