# File: sshd.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 11:54:23 pm
# Last Modified: Sunday, August 14th 2022, 11:59:03 pm
#
# http://www.opensource.org/licenses/MIT

{ config, lib, ... }: {
  services.openssh = lib.mkForce {
    enable = true;
    listenAddresses = [{
      addr = "192.168.0.4";
      port = 22;
    }];
  };
}
