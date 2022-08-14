{ config, lib, pkgs, ... }:
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
    stow
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
  ];

  modern-unix = with pkgs; [
    tree
    wget
    aria2
    fish
    pstree
    file
    rsync
    tmux
    psmisc
    # vim
    bat
    htop
  ];
in {
  environment.systemPackages = nixpkgs-tools ++ modern-unix ++ build-tools
    ++ (with pkgs; [
      home-manager
      neofetch
      lm_sensors
      qemu
      qemu_kvm
      virt-manager
      iproute
      libosinfo
    ]);
}
