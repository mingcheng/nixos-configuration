#!/usr/bin/env bash
###
# File: mount.sh
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 2:36:51 pm
# Last Modified: Friday, December 2nd 2022, 4:51:16 pm
#
# http://www.opensource.org/licenses/MIT
###

set -euo pipefail

mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/EFI /mnt/boot

df -lh /mnt /mnt/boot
