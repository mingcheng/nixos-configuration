#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: golang.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Sunday, August 14th 2022, 10:53:42 pm
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-16 12:05:00
##

{ lib, pkgs, ... }:
let
  mirrors = (import ../sources.nix).development;
in
{
  imports = [
    ./user-packages.nix
  ];

  # Place after develop.nix's mkBefore (500) so gnumake remains first,
  # while still preceding workstation.nix (600) and GUI packages (1000).
  workstation.userPackages =
    with pkgs;
    lib.mkOrder 550 [
      go
      gopls
      delve
      golangci-lint
      gotools
    ];

  environment.sessionVariables = {
    GO111MODULE = lib.mkDefault "on";
    GOPROXY = lib.mkDefault mirrors.goProxy;
    GOSUMDB = lib.mkDefault mirrors.goSumdb;
  };

  environment.extraInit = ''
    export PATH="''${GOBIN:-''${GOPATH:-$HOME/go}/bin}:$PATH"
  '';
}
