#!#
# Copyright (c) 2026 mingcheng
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: vscode.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-04 12:14:45
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-04 12:16:54
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
    config.allowUnfreePredicate = package: lib.getName package == "vscode";
  };
in
lib.mkIf hasGui {
  users.users.mingcheng.packages = [ unstable.vscode ];
}
