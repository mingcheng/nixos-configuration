# File: samba.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Wednesday, August 17th 2022, 4:38:35 pm
# Last Modified: Wednesday, August 17th 2022, 4:39:02 pm
#
# http://www.opensource.org/licenses/MIT

{ lib, ... }: {
  services.samba = {
    enable = true;

    nmbd.enable = false;
    winbindd.enable = false;

    settings = {
      global = {
        security = "user";
        "server string" = "Samba Server Version %v";
        "load printers" = "no";
        "log file" = "/var/log/samba/%U.log";
        "map to guest" = "bad user";
        "passdb backend" = "tdbsam";
        "printcap name" = "/dev/null";
        "server role" = "standalone server";
        "bind interfaces only" = "yes";
        interfaces = lib.mkDefault "eth0";
        "server min protocol" = "SMB2";
        spotlight = "no";
        "inherit permissions" = "no";
        "create mask" = "0640";
        "directory mask" = "0750";
      };

      Public = {
        path = "/data/";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "force user" = "nobody";
        "only guest" = "yes";
        "printable" = "no";
      };
    };
  };
}
