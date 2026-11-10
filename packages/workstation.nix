#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: workstation.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Sunday, August 14th 2022, 9:45:39 pm
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-06 17:33:54
##

{ lib, pkgs, ... }:
{
  imports = [
    ./user-packages.nix
    ./bat.nix
    ./fish.nix
    ./git.nix
    ./nvim.nix
    ./starship.nix
    ./atuin.nix
    ./tmux.nix
  ];

  programs = {
    mtr.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Network, storage and hardware maintenance, including use from root.
    ethtool
    iproute2
    nfs-utils
    lm_sensors
    hddtemp
    hdparm
    nvme-cli
    pciutils
    smartmontools
    usbutils
    inetutils
    dnsutils
    nmap

    # File system tools
    f2fs-tools
    ntfs3g
    exfat

    # Basic system inspection and process management.
    file
    killall
    lsof
    sysstat
    readline
    binutils
  ];

  # Preserve CLI-first collision precedence when combining user applications.
  workstation.userPackages =
    with pkgs;
    lib.mkOrder 600 [
      # Dotfiles and credential utilities.
      stow
      gnupg

      # Networking and transfers.
      aria2
      iperf
      wget

      # Interactive navigation.
      eza
      fzf
      zoxide

      # System monitoring.
      fastfetch
      htop
      btop

      # Files, archives and structured text.
      jq
      lz4
      p7zip
      tree
      unzip
      yq
    ];
}
