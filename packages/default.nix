/*
  * File: default.nix
  * Author: Ming Cheng<mingcheng@outlook.com>
  * 
  * Created Date: Sunday, August 14th 2022, 9:45:39 pm
  * Last Modified: Monday, August 15th 2022, 11:47:51 am
  * 
  * http://www.opensource.org/licenses/MIT
*/

{ pkgs, ... }:
let
  nixpkgs-tools = with pkgs; [
    nixpkgs-fmt
    nixpkgs-lint
    nixpkgs-review
    nixpkgs-pytools
    nix-index
    nix-du
    manix
    nixfmt
    nix-direnv
    direnv
  ];

  build-tools = with pkgs; [
    jq
    stow
    yq
    unzip
    nodejs-16_x
    # git
    binutils
  ];

  system-tools = with pkgs; [
    p7zip
    pciutils
    coreutils
    ipmitool
    stress
    lm_sensors
    smartmontools
    nfs-utils
    btrfs-progs
    f2fs-tools
    killall
    lsof
    lz4
    # tldr
    unzip
    file
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
    # vim
    bat
    htop
    # ncdu
    shfmt
  ];
in
{
  environment.systemPackages = nixpkgs-tools ++ modern-unix ++ build-tools
    ++ (with pkgs; [
    # home-manager
    neofetch
    qemu
    qemu_kvm
    virt-manager
    iproute
    libosinfo
  ]);
}
