# File: nfs.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Monday, August 22nd 2022, 10:51:13 am
# Last Modified: Monday, August 22nd 2022, 12:55:25 pm
#
# http://www.opensource.org/licenses/MIT

{ pkgs, ... }: {
  services.nfs.server = {
    enable = true;
    exports = ''
      /archives   192.168.0.4(rw,no_root_squash,anonuid=0,anongid=0,no_subtree_check,sync)
      /public     192.168.0.0/23(rw,all_squash,anonuid=65534,anongid=65534,no_subtree_check,sync)
      /downloads  192.168.0.0/23(rw,all_squash,anonuid=1000,anongid=1000,no_subtree_check,sync)
    '';
  };
}
