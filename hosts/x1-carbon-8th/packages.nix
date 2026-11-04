#!#
# Copyright (c) 2026 mingcheng
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: packages.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Sunday, August 14th 2022, 9:45:39 pm
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-04 16:07:04
##

{ pkgs, ... }:
{
  imports = [
    ../../packages/fish.nix
    ../../packages/nvim.nix
  ];

  programs = {
    direnv.enable = true;
    mtr.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Nix and development tools.
    binutils
    gnumake
    manix
    nix-du
    nix-index
    nixfmt
    nixpkgs-lint
    nixpkgs-pytools
    nixpkgs-review
    shfmt
    stow

    # Networking and transfers.
    aria2
    ethtool
    inetutils
    iperf
    iproute2
    nfs-utils
    wget

    # Storage and hardware diagnostics.
    hddtemp
    hdparm
    nvme-cli
    pciutils
    smartmontools
    usbutils

    # System monitoring.
    # duf
    fastfetch
    htop
    btop
    killall
    lsof
    stress
    sysstat

    # Files, text and terminals.
    bat
    file
    jq
    lz4
    p7zip
    tmux
    tree
    unzip
    yq

    # Additional interactive shells; the login shell remains unchanged.
    nushell
    # starship
    # mise
    powershell
  ];
}
