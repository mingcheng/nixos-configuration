# File: openssh.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 11:17:23 pm
# Last Modified: Monday, August 15th 2022, 10:37:22 pm
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

      Subsystem powershell /run/current-system/sw/bin/pwsh -sshs -NoLogo -NoProfile
    '';

    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
