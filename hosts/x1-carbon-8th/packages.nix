#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: packages.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Sunday, August 14th 2022, 9:45:39 pm
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-05 11:26:32
##

{ pkgs, ... }:
{
  imports = [
    ../../packages/bat.nix
    ../../packages/fish.nix
    ../../packages/git.nix
    ../../packages/nvim.nix
    ../../packages/starship.nix
    ../../packages/atuin.nix
    ../../packages/tmux.nix
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
    eza
    fzf
    zoxide

    # System monitoring.
    fastfetch
    htop
    btop
    killall
    lsof
    stress
    sysstat

    # Files, text and terminals.
    file
    jq
    lz4
    p7zip
    tree
    unzip
    yq

    # Additional interactive shells; the login shell remains unchanged.
    nushell
    mise
    powershell
  ];
}
