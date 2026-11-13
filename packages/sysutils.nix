#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: sysutils.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Friday, November 13th 2026, 11:40:00 pm
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-13 23:40:00
##

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    fd
    file
    htop
    jq
    killall
    lsof
    lz4
    p7zip
    pciutils
    ripgrep
    sysstat
    tree
    unzip
    usbutils
    yq
  ];
}
