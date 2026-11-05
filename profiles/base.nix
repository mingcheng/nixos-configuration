#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: base.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 1970-01-01 08:00:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-05 14:16:55
##

{
  imports = [
    ../system/nixconfig.nix
    ../system/mainland.nix
    ../system/i18n.nix
    ../system/sudo.nix
  ];
}
