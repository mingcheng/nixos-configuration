#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: default.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Friday, August 26th 2022, 2:54:00 pm
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-13 13:13:29
##

{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:
let
  sources = import ../../sources.nix;
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/virtualisation/disk-image.nix")

    ../../profiles/base.nix
    ../../system/networking.nix
    ../../services/docker.nix
    ../../services/sshd.nix

    ../../packages/git.nix
    ../../packages/nvim.nix
    ../../packages/netutils.nix
  ]
  ++ lib.optional (builtins.pathExists ./local.nix) ./local.nix;

  nixpkgs.config = lib.mkForce {
    allowUnfree = true;
  };
  system.defaultChannel = lib.mkDefault sources.channels.nixos;

  image = {
    format = lib.mkDefault "qcow2";
    efiSupport = lib.mkDefault true;
  };

  boot = {
    kernelParams = [
      "console=ttyS0,115200n8"
    ];
    loader = {
      timeout = lib.mkDefault 3;
      grub.enable = lib.mkIf (!config.image.efiSupport) (lib.mkOverride 900 true);
    };
  };

  # Leave static hostName empty by default so each VM instance generates a
  # random hostname on first boot unless overridden in local.nix.
  networking.hostName = lib.mkOverride 900 "";

  systemd.services = lib.mkIf (config.networking.hostName == "") {
    vm-random-hostname = {
      description = "Generate and apply a random VM hostname";
      wantedBy = [
        "network-pre.target"
        "multi-user.target"
      ];
      before = [
        "network-pre.target"
        "network.target"
      ];
      path = [
        pkgs.coreutils
        pkgs.nettools
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        if [ -s /etc/hostname ]; then
          name=$(tr -d ' \t\r\n' < /etc/hostname)
        else
          name="vm-$(head -c 4 /dev/urandom | od -An -tx1 | tr -d ' \n')"
          printf '%s\n' "$name" > /etc/hostname
        fi
        hostname "$name"
      '';
    };
  };

  services = {
    qemuGuest.enable = lib.mkDefault true;
    openssh.settings = {
      PermitRootLogin = lib.mkForce "no";
      PermitEmptyPasswords = false;
    };

    # Headless VM image: never install or enable any GUI stack.
    xserver.enable = lib.mkForce false;
    displayManager.enable = lib.mkForce false;
    flatpak.enable = lib.mkForce false;
  };

  programs.xwayland.enable = lib.mkForce false;
  xdg.portal.enable = lib.mkForce false;

  # Keep this host's narrower trust policy out of the reusable profiles.
  nix.settings.trusted-users = lib.mkForce [
    "root"
    "mingcheng"
  ];

  users = {
    mutableUsers = lib.mkDefault true;
    users = {
      root.initialHashedPassword = lib.mkDefault "";
      "mingcheng" = {
        description = "mingcheng <mingcheng@outlook.com>";
        isNormalUser = true;
        group = "users";
        extraGroups = [
          "wheel"
          "docker"
        ];
        shell = pkgs.bash;
      };
    };
  };

  system.stateVersion = lib.mkDefault "26.05";
}
