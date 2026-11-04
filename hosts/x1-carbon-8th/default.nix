{ lib, ... }:
{
  imports = [
    ../../system/nixconfig.nix
    ../../system/boot.nix
    ../../system/i18n.nix
    ../../system/power.nix
    ../../system/swap.nix
    ../../system/sudo.nix

    ../../services/fstrim.nix
    ../../services/timesyncd.nix
    ../../services/docker.nix
    ../../services/keyd.nix
    ../../services/sshd.nix

    ./kernel.nix
    ./desktop.nix
    ./packages.nix
  ];

  networking = {
    hostName = "x1-carbon-8th";
    networkmanager.enable = true;
    useDHCP = false;
  };
	
  environment.variables = {
    NIXPKGS_ALLOW_UNFREE = 1;
  };
}
