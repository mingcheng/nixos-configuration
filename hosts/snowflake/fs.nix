# File: fs.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 6:34:04 pm
# Last Modified: Thursday, August 18th 2022, 6:34:32 pm
#
# http://www.opensource.org/licenses/MIT

{
  fileSystems."/opt" = {
    device = "/dev/disk/by-label/tank";
    fsType = "ext4";
    options = [ "defaults" "discard" "errors=remount-ro" ];
  };
}
