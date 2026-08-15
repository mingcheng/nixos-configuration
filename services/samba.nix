# File: samba.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Wednesday, August 17th 2022, 4:38:35 pm
# Last Modified: Wednesday, August 17th 2022, 4:39:02 pm
#
# http://www.opensource.org/licenses/MIT

{ ... }: {

  # https://discourse.nixos.org/t/nixos-configuration-for-samba/17079/6
  # system.activationScripts = {
  #   sambaUserSetup = {
  #     text = ''
  #       PATH=$PATH:${lib.makeBinPath [ pkgs.samba ]}
  #       pdbedit -i smbpasswd:/home/john/smbpasswd -e tdbsam:/var/lib/samba/private/passdb.tdb
  #     '';
  #     deps = [ ];
  #   };
  # };

  #  services.samba-wsdd.enable = true;
  services.samba = {
    enable = true;
    # package = pkgs.sambaFull;

    nmbd.enable = false;
    winbindd.enable = false;

    settings = {
      global = {
        security = "user";
        "netbios name" = "wooramel";
        "server string" = "Samba Server Version %v";
        "dns proxy" = "no";
        "load printers" = "no";
        "log file" = "/var/log/samba/%U.log";
        "map to guest" = "bad user";
        "passdb backend" = "tdbsam";
        "printcap name" = "/dev/null";
        "server role" = "standalone server";
        "bind interfaces only" = "yes";
        interfaces = "eth0";
        "unix extensions" = "no";
        "min protocol" = "SMB2";
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
        "force group" = "+nobody";
        "public" = "yes";
        "writable" = "yes";
        "only guest" = "yes";
        "printable" = "no";
        "spotlight" = "no";
        # "fruit:time machine" = "no";

        #         "fruit:aapl" = "yes";
        # "fruit:time machine" = "yes";
        # "vfs objects" = "catia fruit streams_xattr";

        # [ Time Capsule ]
        #   path = /timemachine/%U
        # valid users = @wheel
        # force group = +wheel
        # writable = yes
        # browsable = yes
        # read only = no
        # guest ok = no
        # public = no
        # kernel oplocks = no
        # kernel share modes = no
        # posix locking = no
        # fruit:time machine = yes

        # create mask = 0600
        # directory mask = 0700
        # ;  fruit:time machine max size = 1T
      };
    };
  };
}

# services.samba = {
# shares = {
# tm_share = {
# path = "/mnt/Shares/tm_share";
# "valid users" = "username";
# public = "no";
# writeable = "yes";
# "force user" = "username";
# "fruit:aapl" = "yes";
# "fruit:time machine" = "yes";
# "vfs objects" = "catia fruit streams_xattr";
# };
# };
# }

# [ global ]
#   netbios
#   name = Dorre
# server string = University of GNUs Samba Server %v

# dns proxy = no
# load printers = no
# log file = /var/log/samba/%U.log
# map to guest = bad user
# passdb backend = tdbsam
# printcap name = /dev/null

# server role = standalone server
# max log size = 1024
# socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=524288 SO_SNDBUF=524288
# wins support = yes

# bind interfaces only = yes
# interfaces = enp1s0
# unix extensions = no

# min protocol = SMB2

# # Special configuration for Apple's Time Machine
# fruit:aapl = yes
# fruit:advertise_fullsync = true
# fruit:delete_empty_adfiles = yes
# fruit:model = TimeCapsule6,106
# fruit:posix_rename = yes
# fruit:nfs_aces = no
# fruit:veto_appledouble = no
# fruit:wipe_intentionally_left_blank_rfork = yes
# fruit:metadata = stream
# fruit:zero_file_id = yes
# fruit:resource = stream

# allocation roundup size = 0
# directory name cache size = 0
# ;dos filemode = Yes
#
# ea support = yes
# spotlight = no

# inherit permissions = no
# create mask = 0640
# directory mask = 0750
