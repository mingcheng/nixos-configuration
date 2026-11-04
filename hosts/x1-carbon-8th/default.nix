{
  imports = [
    # Shared system policy.
    ../../system/nixconfig.nix
    ../../system/boot.nix
    ../../system/i18n.nix
    ../../system/power.nix
    ../../system/swap.nix
    ../../system/sudo.nix

    # Host services.
    ../../services/fstrim.nix
    ../../services/timesyncd.nix
    ../../services/docker.nix
    ../../services/keyd.nix
    ../../services/sshd.nix

    # Hardware, desktop composition, and host tools.
    ./kernel.nix
    ./desktop.nix
    ./packages.nix
  ];

  networking = {
    hostName = "x1-carbon-8th";
    networkmanager.enable = true;
    useDHCP = false;
  };
}
