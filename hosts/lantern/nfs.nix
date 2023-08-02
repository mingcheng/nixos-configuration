# File: nfs.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Monday, August 22nd 2022, 10:51:13 am
# Last Modified: Monday, August 22nd 2022, 12:55:25 pm
#
# http://www.opensource.org/licenses/MIT

{ pkgs, lib, ... }: {
  services.rpcbind.enable = true;
  services.nfs.server = {
    enable = lib.mkForce true;
    exports = ''
      /archives   192.168.0.0/23(rw,no_root_squash,no_subtree_check,sync)
      /public     192.168.0.0/16(rw,all_squash,anonuid=65534,anongid=65534,no_subtree_check,sync)
    '';
  };
}
