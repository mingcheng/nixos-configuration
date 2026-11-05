# File: nfs.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Wednesday, August 17th 2022, 5:01:40 pm
# Last Modified: Wednesday, August 17th 2022, 5:01:40 pm
#
# http://www.opensource.org/licenses/MIT

{
  fileSystems."/public" = {
    device = "/data";
    fsType = "none";
    options = [ "bind" ];
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      # /public 172.16.0.0/24(rw,all_squash,no_subtree_check,async)
    '';
  };

}
