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
      AllowTcpForwarding yes
      AuthorizedKeysFile .ssh/authorized_keys
      PubkeyAuthentication yes

      Subsystem powershell /run/current-system/sw/bin/pwsh -SSHServerMode -NoLogo -NoProfile
    '';

    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
