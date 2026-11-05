#!#
# Copyright (c) 2026 mingcheng
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: docker.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Monday, August 15th 2022, 10:59:12 am
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-04 11:59:50
##

{ lib, pkgs, ... }: {
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      debug = lib.mkDefault false;
      experimental = lib.mkDefault false;
    };
    autoPrune = {
      enable = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      flags = lib.mkDefault [
        "--all"
        "--filter"
        "until=168h"
      ];
    };
    liveRestore = lib.mkDefault true;
  };

  environment.systemPackages = with pkgs; [ docker-compose ];
}
