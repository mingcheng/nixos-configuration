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
{
  # Keep this lazy: evaluating session packages already requires nixpkgs.
  nixpkgs.config = lib.mkBefore {
    allowUnfreePredicate = package: lib.getName package == "vscode" && hasGui;
  };

  environment.systemPackages = lib.mkIf hasGui [ pkgs.vscode ];
}
