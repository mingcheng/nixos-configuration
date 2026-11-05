#!#
# Copyright (c) 2026 mingcheng
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: nixconfig.nix
# Author: mingcheng <mingcheng@apache.org>
# Created Date: Sunday, August 14th 2022, 9:45:39 pm
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-04 15:36:55
##

{ lib, ... }: {
  nix = {
    settings = {
      # https://nixos.wiki/wiki/Storage_optimization
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      keep-derivations = true;
      keep-outputs = true;
      trusted-users = [
        "root"
        "@wheel"
      ];

      # Substituters for binary caches, defined in ../sources.nix for mainland China users
      substituters = lib.mkForce (import ../sources.nix).substituters;

      fallback = true;
      connect-timeout = 5;
      require-sigs = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
