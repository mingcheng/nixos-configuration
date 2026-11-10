#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: laptop.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-10 12:01:55
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-10 12:01:55
##

{
  imports = [
    ../system/power.nix
    ../system/swap.nix
    ./workstation.nix
  ];
}
