# Desktop workstation: the Plasma desktop plus hardening, Docker, local AdGuard
# DNS, the mihomo proxy and Syncthing. Hosts select accounts via
# workstation.users; laptop.nix adds power management on top.
{
  imports = [
    ../system/kernel.nix
    ../system/security.nix
    ../services/fstrim.nix
    ../services/timesyncd.nix
    ../services/docker.nix
    ../services/adguard.nix
    ../services/mihomo.nix
    ../services/syncthing.nix
    ../packages/workstation.nix
    ./desktop.nix
  ];
}
