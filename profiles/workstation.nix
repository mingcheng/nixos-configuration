{
  imports = [
    ../system/kernel.nix
    ../system/ld.nix
    ../system/security.nix
    ../services/fstrim.nix
    ../services/timesyncd.nix
    ../services/docker.nix
    ../packages/workstation.nix
    ./desktop.nix
  ];
}
