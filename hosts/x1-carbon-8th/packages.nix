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
# Last Modified: 2026-11-05 12:50:29
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
    # Network, storage and hardware maintenance, including use from root.
    ethtool
    iproute2
    nfs-utils
    hddtemp
    hdparm
    nvme-cli
    pciutils
    smartmontools
    usbutils

    # Basic system inspection and process management.
    file
    killall
    lsof
    sysstat
  ];

  users.users.mingcheng.packages = with pkgs; [
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
    inetutils
    iperf
    wget

    # Interactive navigation.
    eza
    fzf
    zoxide

    # Optional monitoring and benchmarking.
    fastfetch
    htop
    btop
    stress

    # Files, text and terminals.
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
