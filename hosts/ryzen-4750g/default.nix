#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: default.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-09 18:26:43
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-09 18:26:43
##

{ lib, pkgs, ... }:
{
  imports = [
    ../../profiles/workstation.nix
    ../../profiles/develop.nix

    ../../system/boot.nix
    ../../services/libvirtd.nix
    ../../services/sshd.nix

    ./kernel.nix
    ./tuning.nix
  ];

  networking.proxy = {
    default = lib.mkDefault "http://127.0.0.1:7890";
    noProxy = lib.mkDefault "127.0.0.1,localhost,internal.domain";
  };

  # The shared profiles intentionally do not select or create personal accounts.
  workstation.users = [ "mingcheng" ];

  # Keep this host's narrower trust policy out of the reusable profiles.
  nix.settings.trusted-users = lib.mkForce [
    "root"
    "mingcheng"
  ];

  users = {
    mutableUsers = true;
    users."mingcheng" = {
      description = "mingcheng <mingcheng@outlook.com>";
      isNormalUser = true;
      group = "users";
      extraGroups = [
        "wheel"
        "libvirtd"
        "docker"
        "networkmanager"
        "video"
        "input"
        "audio"
      ];
      shell = pkgs.bash;
    };
  };
}
