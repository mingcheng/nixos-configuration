# File: sshd.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 11:54:23 pm
# Last Modified: Sunday, August 14th 2022, 11:59:03 pm
#
# http://www.opensource.org/licenses/MIT

{ config, lib, ... }: {
  services.openssh = {
    enable = true;

    extraConfig = ''
      AllowAgentForwarding yes
      AllowStreamLocalForwarding yes
      AllowTcpForwarding yes
      X11Forwarding no

      Subsystem powershell /run/current-system/sw/bin/pwsh -sshs -nologo
    '';

    settings = {
      #AllowSFTP = true;
      #KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
