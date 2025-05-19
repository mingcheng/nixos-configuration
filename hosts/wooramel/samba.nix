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
    openFirewall = true;

    settings = {
      global = {
        "security" = "user";
        "workgroup" = "WORKGROUP";
        "netbios name" = "${host}";
        "server string" = "${host}";

        "dns proxy" = "no";
        "load printers" = "no";
        "log file" = "/var/log/samba/%U.log";
        "min protocol" = "SMB3";
        "passdb backend" = "smbpasswd";
        "server role" = "standalone server";
        "unix extensions" = "no";
        "inherit permissions" = "yes";
        "create mask" = "0600";
        "directory mask" = "0700";
        "hosts allow" = "192.168.0.";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";

        "fruit:aapl" = "yes";
        "fruit:model" = "TimeCapsule6,106";

        "fruit:zerofileid" = "yes";
        "fruit:metadata" = "stream";
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";

        "fruit:nfs_aces" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        #"vfs objects" = "catia fruit streams_xattr";
      };

      "Public" = {
        "path" = "/public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "force user" = "nobody";
        "force group" = "nogroup";
        "create mask" = "0666";
        "directory mask" = "0777";
        "public" = "yes";
        "writable" = "yes";
        "only guest" = "yes";
      };

      "Personal" = {
        "path" = "/samba/%U";
        "browseable" = "yes";
        "valid users" = "@users";
        "read only" = "no";
        "force group" = "+users";
        "public" = "no";
        "writable" = "yes";
      };

      "Time Capsule" = {
        "path" = "/timemachine/%U";
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

        "fruit:aapl" = "yes";
        #"fruit:time machine max size" = "2T";
        "fruit:time machine" = "yes";

        "vfs objects" = "catia fruit streams_xattr";
      };

      "WebDAV" = {
        "path" = "/webdav";
        "valid users" = "@users";
        "force user" = "mingcheng";
        "force group" = "+users";
        "public" = "no";
        "writable" = "yes";
      };

      "Software" = {
        "path" = "/software";
        "valid users" = "@users";
        "force user" = "mingcheng";
        "force group" = "+users";
        "public" = "no";
        "writable" = "yes";
      };
    };
  };
}
