#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: network.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Friday, November 13th 2026, 11:48:00 pm
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-13 23:48:00
##

{
  imports = [
    ./base.nix

    ../system/kernel.nix
    ../system/networking.nix
    ../system/shell_alias.nix

    ../services/fstrim.nix
    ../services/sshd.nix
    ../services/timesyncd.nix

    ../packages/bat.nix
    ../packages/git.nix
    ../packages/netutils.nix
    ../packages/nvim.nix
    ../packages/sysutils.nix
    ../packages/tmux.nix
  ];
}
