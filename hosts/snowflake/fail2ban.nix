# File: firewall.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Wednesday, August 17th 2022, 4:14:02 pm
# Last Modified: Wednesday, August 17th 2022, 4:14:31 pm
#
# http://www.opensource.org/licenses/MIT

{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.fail2ban = {
    enable = true;
    maxretry = 3;

    ignoreIP = [
      "127.0.0.0/8"
      "172.16.0.0/16"
      "192.168.0.0/16"
    ];

    jails.DEFAULT = ''
      bantime  = 1d
    '';

    jails.sshd = ''
      enabled  = true
      port     = sshd
      filter   = sshd
      action   = iptables[name=ssh, port=ssh, protocol=tcp]
    '';
  };
}
