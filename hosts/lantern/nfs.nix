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
      /downloads 192.168.0.14(ro,no_root_squash,no_subtree_check,sync)
    '';
  };
}
