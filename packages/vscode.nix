#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: vscode.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-04 12:14:45
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-06 19:17:22
##

{
  lib,
  pkgs,
  hasGui,
}:
let
  # Import packages only, not NixOS modules; keep the rest of the system stable.
  # Lazy evaluation means headless hosts do not require the unstable channel.
  unstable = import <unstable> {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfreePredicate =
      package:
      builtins.elem (lib.getName package) [
        "vscode"
        # The code-cursor attribute uses "cursor" as its package name.
        # "cursor"
      ];
  };
in
lib.mkIf hasGui {
  workstation.userPackages = [
    unstable.vscode
    # unstable.code-cursor
  ];
}
