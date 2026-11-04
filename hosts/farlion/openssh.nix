# File: openssh.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 11:58:49 pm
# Last Modified: Monday, August 15th 2022, 12:02:15 am
#
# http://www.opensource.org/licenses/MIT

{ lib, ... }: {
  services.openssh = lib.mkForce {
    enable = true;
    listenAddresses = [
      {
        addr = "192.168.0.11";
        port = 22;
      }
    ];

    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
