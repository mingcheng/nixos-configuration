###
# File: mount.sh
# Author: Ming Cheng<mingcheng@outlook.com>
# 
# Created Date: Thursday, August 18th 2022, 2:36:51 pm
# Last Modified: Thursday, August 18th 2022, 2:37:43 pm
# 
# http://www.opensource.org/licenses/MIT
###

mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/efi
mount /dev/disk/by-label/EFI /mnt/efi

df -lh