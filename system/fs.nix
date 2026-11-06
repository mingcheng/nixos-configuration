# File: fs.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 11:20:01 am
# Last Modified: Thursday, August 18th 2022, 11:20:03 am
#
# http://www.opensource.org/licenses/MIT

{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "f2fs";
    options = [
      "defaults"
      "background_gc=on"
      "discard"
      "alloc_mode=default"
      "fsync_mode=posix"
    ];
  };

  fileSystems."/efi" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
  };

}
