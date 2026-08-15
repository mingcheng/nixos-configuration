# File: samba.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 6:34:09 pm
# Last Modified: Thursday, August 18th 2022, 6:34:09 pm
#
# http://www.opensource.org/licenses/MIT

{ ... }:
let host = builtins.getEnv "NIX_BUILD_HOST";
in {
  services.samba = {
    enable = true;
    nmbd.enable = false;
    winbindd.enable = false;

    settings = {
      global = {
        security = "user";
        "netbios name" = host;
        "dns proxy" = "no";
        "load printers" = "no";
        "log file" = "/var/log/samba/%U.log";
        "map to guest" = "bad user";
        "passdb backend" = "tdbsam";
        "printcap name" = "/dev/null";
        "server role" = "standalone server";
        spotlight = "no";
        "inherit permissions" = "no";
        "create mask" = "0600";
        "directory mask" = "0700";
        "fruit:aapl" = "yes";
        "fruit:model" = "TimeCapsule6,106";
      };

      "Public" = {
        "path" = "/opt/public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "force user" = "nobody";
        "force group" = "+nogroup";
        "public" = "yes";
        "writable" = "yes";
        "only guest" = "yes";
        "printable" = "no";
        "spotlight" = "no";
        "create mask" = 666;
        "directory mask" = 777;
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
        "vfs objects" = "fruit streams_xattr";

        "fruit:delete_empty_adfiles" = "yes";
        "fruit:metadata" = "stream";
        "fruit:nfs_aces" = "no";
        "fruit:posix_rename" = "yes";
        "fruit:time machine" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:zero_file_id" = "yes";
        "fruit:time machine max size" = "1T";

        "create mask" = 600;
        "directory mask" = 700;
      };
    };
  };
}
