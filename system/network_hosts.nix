#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: network_hosts.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Thursday, August 18th 2022, 11:09:16 am
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-06 10:25:38
##

{ lib, ... }:
let
  sources = import ../sources.nix;
in
{
  networking = {
    # Terminate local entries before NixOS concatenates the remote host files.
    extraHosts = lib.mkAfter "";
    hostFiles = map builtins.fetchurl sources.hosts;
  };
}
