#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: ld.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 1970-01-01 08:00:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-05 20:15:43
##

{
  config,
  lib,
  pkgs,
  ...
}:
{
  # mise defaults to source builds on NixOS, even when nix-ld is available.
  environment.variables.MISE_ALL_COMPILE = "false";

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      glibc
      expat
      freeglut
      glib
      icu
      libcap
      libffi
      libxcrypt-legacy
      libxslt
      ncurses
      nghttp2
      openssl
      readline
      sqlite
    ];
  };

  environment.systemPackages = [
    (pkgs.buildFHSEnv {
      name = "fhs";
      targetPkgs =
        pkgs:
        # Include NixOS's default runtime libraries and any host additions.
        (map lib.getLib config.programs.nix-ld.libraries)
        ++ (with pkgs; [
          cacert
          curl
          file
          git
          gnupg
          mise
          unzip
        ]);
      runScript = "bash";
      profile = ''
        export MISE_ALL_COMPILE=${lib.escapeShellArg config.environment.variables.MISE_ALL_COMPILE}
      '';
    })
  ];
}
