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

    ../../profiles/network.nix
    ../../services/docker.nix
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

  fileSystems."/boot" = lib.mkIf config.image.efiSupport {
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  boot = {
    kernelParams = [
      "console=tty0"
      "console=ttyS0,115200n8"
    ];
    loader = {
      timeout = lib.mkDefault 3;
      systemd-boot.configurationLimit = lib.mkDefault 5;
      grub = {
        enable = lib.mkIf (!config.image.efiSupport) (lib.mkOverride 900 true);
        configurationLimit = lib.mkDefault 5;
        splashImage = null;
        extraConfig = lib.mkDefault ''
          serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
          terminal_input serial console
          terminal_output serial console
        '';
      };
    };
  };

  networking = {
    # Leave static hostName empty by default so each VM instance generates a
    # random hostname on first boot unless overridden in local.nix.
    hostName = lib.mkOverride 900 "";
    dhcpcd = {
      extraConfig = lib.mkDefault "noarp";
      denyInterfaces = [
        "veth*"
        "docker*"
        "br-*"
      ];
    };
    resolvconf.extraConfig = lib.optionalString (
      config.services.nscd.enable && config.services.nscd.enableNsncd
    ) "libc_restart=':'";
  };

  systemd = {
    oomd.enable = lib.mkDefault false;
    services = lib.mkIf (config.networking.hostName == "") {
      "systemd-hostnamed".environment.SYSTEMD_ETC_HOSTNAME = lib.mkForce "/etc/hostname";
      vm-random-hostname = {
        description = "Generate and apply a random VM hostname";
        wantedBy = [
          "sysinit.target"
          "multi-user.target"
        ];
        after = [ "local-fs.target" ];
        before = [
          "network-pre.target"
          "network.target"
          "dhcpcd.service"
          "systemd-hostnamed.service"
        ];
        unitConfig.DefaultDependencies = false;
        path = [
          pkgs.coreutils
          pkgs.nettools
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          name=""
          if [ -r /etc/hostname ]; then
            name=$(tr -d ' \t\r\n' < /etc/hostname)
          fi
          if [ -z "$name" ]; then
            name="vm-$(head -c 4 /dev/urandom | od -An -tx1 | tr -d ' \n')"
            printf '%s\n' "$name" > /etc/hostname
          fi
          hostname "$name"
        '';
      };
    };
  };

  documentation = {
    doc.enable = lib.mkDefault false;
    info.enable = lib.mkDefault false;
    nixos.enable = lib.mkDefault false;
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
