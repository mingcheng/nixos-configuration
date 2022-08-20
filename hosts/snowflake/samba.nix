# File: samba.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 6:34:09 pm
# Last Modified: Thursday, August 18th 2022, 6:34:09 pm
#
# http://www.opensource.org/licenses/MIT

{ pkgs, ... }:

let host = builtins.getEnv "NIX_BUILD_HOST";
in {
  services.samba = {
    enable = true;
    enableNmbd = false;
    enableWinbindd = false;

    securityType = "user";
    extraConfig = ''
      netbios name = ${host}
      dns proxy = no
      load printers = no
      log file = /var/log/samba/%U.log

      map to guest = bad user
      passdb backend = tdbsam
      printcap name = /dev/null

      server role = standalone server
      bind interfaces only = yes
      interfaces = eth0
      unix extensions = no

      min protocol = SMB2
      spotlight = no

      inherit permissions = no
      create mask = 0640
      directory mask = 0750

      fruit:aapl = yes
      fruit:model = TimeCapsule6,106
    '';

    shares = {
      "Public" = {
        "path" = "/opt/public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "force user" = "nobody";
        "force group" = "+nobody";
        "public" = "yes";
        "writable" = "yes";
        "only guest" = "yes";
        "printable" = "no";
        "spotlight" = "no";
      };

      "Time Capsule" = {
        "path" = "/opt/timemachine/%U";
        "valid users" = "@users";
        "force group" = "+users";
        "writable" = "yes";
        "browsable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "public" = "no";
        "kernel oplocks" = "no";
        "kernel share modes" = "no";
        "posix locking" = "no";
        "fruit:time machine" = "yes";
        "vfs objects" = "catia fruit streams_xattr";

        # fruit:time machine max size = 1T;
        "create mask" = 600;
        "directory mask" = 700;
      };
    };
  };
}
