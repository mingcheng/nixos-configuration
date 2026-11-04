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
    nixfmt-classic
    nixpkgs-fmt
    nixpkgs-lint
    nixpkgs-pytools
    nixpkgs-review
  ];

  build-tools = with pkgs; [
    inetutils
    mtr
    sysstat
    binutils
    usbutils
    gnumake
    nodejs
    stow
    git
    unzip
    yq
    jq
  ];

  system-tools = with pkgs; [
    coreutils
    iproute2
    killall
    hddtemp
    lsof
    lz4
    nfs-utils
    p7zip
    pciutils
    iperf
    smartmontools
    nvme-cli
    hdparm
    powershell
    #lm_sensors
    stress
    powershell
    nushell
    ethtool
    unzip
  ];

  modern-unix = with pkgs; [
    tree
    wget
    aria2
    file
    rsync
    tmux
    bat
    htop
    shfmt
    gdu
    duf
  ];
in
{
  environment.systemPackages =
    nixpkgs-tools ++ modern-unix ++ build-tools ++ system-tools ++ (with pkgs; [ fastfetch ]);
}
