#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: develop.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-10 12:01:55
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-10 12:01:55
##

{ lib, pkgs, ... }:
{
  imports = [
    ./user-packages.nix
  ];

  programs = {
    direnv.enable = true;
  };

  # Preserve CLI-first collision precedence when combining user applications.
  workstation.userPackages =
    with pkgs;
    lib.mkBefore [
      # Nix and development tools.
      gnumake
      manix
      nix-du
      nix-index
      nixfmt
      nixpkgs-lint
      nixpkgs-pytools
      nixpkgs-review
      shfmt

      # Optional benchmarking.
      stress

      # Additional interactive shells; the login shell remains unchanged.
      nushell
      powershell

      # Development tools and utilities.
      mise
      gcc
      cmake
      ninja
      pkg-config
      python3

      # ai agent
      opencode
      # claude-code
      # codex
    ];
}
