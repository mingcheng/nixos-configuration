#!#
# Copyright (c) 2026 mingcheng
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: sudo.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Thursday, August 18th 2022, 11:09:16 am
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-04 16:51:32
##

{
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };
}
