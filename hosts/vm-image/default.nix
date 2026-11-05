#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: default.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Friday, August 26th 2022, 2:54:00 pm
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-05 11:25:27
##

{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../profiles/base.nix
    ../../system/networking.nix
  ];
}
