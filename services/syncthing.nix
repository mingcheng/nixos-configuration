#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: syncthing.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-10 16:20:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-10 16:20:00
##

{
  config,
  lib,
  pkgs,
  ...
}:
let
  users = if config.workstation.users != [ ] then config.workstation.users else [ "mingcheng" ];
  conditionUser =
    if builtins.length users == 1 then builtins.head users else map (user: "|${user}") users;
in
{
  imports = [
    ../packages/user-packages.nix
  ];

  users.users = lib.genAttrs users (_: {
    linger = lib.mkDefault false;
    packages = lib.optionals (config.workstation.users == [ ]) [ pkgs.syncthing ];
  });

  workstation.userPackages = lib.mkIf (config.workstation.users != [ ]) [
    pkgs.syncthing
  ];

  systemd.user.services.syncthing = {
    description = "Syncthing continuous file synchronization";
    documentation = [ "https://docs.syncthing.net/" ];
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];

    environment = {
      STNORESTART = "yes";
      STNOUPGRADE = "yes";
    };

    unitConfig = {
      ConditionUser = lib.mkDefault conditionUser;
    };

    serviceConfig = {
      ExecStart = lib.mkDefault (
        lib.concatStringsSep " " [
          (lib.getExe pkgs.syncthing)
          "--no-browser"
          "--gui-address=127.0.0.1:8384"
          "--config=%h/Syncthing/config"
          "--data=%h/Syncthing/config"
        ]
      );
      Restart = lib.mkDefault "on-failure";
      RestartSec = lib.mkDefault "5s";
      SuccessExitStatus = "3 4";
      RestartForceExitStatus = "3 4";
    };
  };
}
