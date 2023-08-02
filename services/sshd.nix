# File: openssh.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 11:17:23 pm
# Last Modified: Monday, August 15th 2022, 10:37:22 pm
#
# http://www.opensource.org/licenses/MIT
{ lib, ... }: {
  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = lib.mkForce false;
      KbdInteractiveAuthentication = lib.mkForce false;
      PermitRootLogin = lib.mkForce "no";
    };
  };
}
