{
  imports = [
    ../system/kernel.nix
    ../system/security.nix
    ../services/fstrim.nix
    ../services/timesyncd.nix
    ../services/docker.nix
    ../services/adguard.nix
    ../services/syncthing.nix
    ../packages/workstation.nix
    ./desktop.nix
  ];
}
