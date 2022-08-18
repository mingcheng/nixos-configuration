# File: nfs.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Wednesday, August 17th 2022, 5:01:40 pm
# Last Modified: Wednesday, August 17th 2022, 5:01:40 pm
#
# http://www.opensource.org/licenses/MIT

{ pkgs, ... }: {
  fileSystems."/public" = {
    device = "/data";
    options = [ "bind" ];
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /public 172.16.0.0/24(rw,all_squash,no_subtree_check,async)
    '';
  };

  # services.rpcbind.enable = true; # needed for NFS
  # systemd.mounts = [{
  #   type = "nfs";
  #   mountConfig = {
  #     Options = "noatime nfsvers=4.2";
  #   };
  #   what = "172.16.0.201:/public";
  #   where = "/data2";
  # }];

  # fileSystems."/mnt/tomoyo" = {
  #   device = "server:/tomoyo";
  #   fsType = "nfs";
  #   options = [ "nfsvers=4.2" ];
  # };
}
