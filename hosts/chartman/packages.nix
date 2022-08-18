# File: default.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 9:45:39 pm
# Last Modified: Monday, August 15th 2022, 11:47:51 am
#
# http://www.opensource.org/licenses/MIT

{ pkgs, ... }:
let
  nixpkgs-tools = with pkgs; [
    direnv
    manix
    nix-direnv
    nix-du
    nix-index
    nixfmt
    nixpkgs-fmt
    nixpkgs-lint
    nixpkgs-pytools
    nixpkgs-review
  ];

  build-tools = with pkgs; [ binutils jq nodejs-16_x stow git unzip yq ];

  system-tools = with pkgs; [
    btrfs-progs
    coreutils
    f2fs-tools
    file
    ipmitool
    iproute
    killall
    libosinfo
    lm_sensors
    lsof
    lz4
    nfs-utils
    p7zip
    pciutils
    smartmontools
    stress
    unzip
  ];

  modern-unix = with pkgs; [
    tree
    wget
    aria2
    # fish
    # pstree
    file
    rsync
    tmux
    # psmisc
    vim
    bat
    htop
    shfmt
  ];
in {
  environment.systemPackages = nixpkgs-tools ++ modern-unix ++ build-tools
    ++ system-tools ++ (with pkgs; [ neofetch qemu qemu_kvm virt-manager ]);
}
