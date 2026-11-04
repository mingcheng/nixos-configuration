{
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../nixconfig.nix

    ../../system/boot.nix
    ../../system/cpu_intel.nix
    ../../system/i18n.nix
    ../../system/sudo.nix
    ../../system/user.nix

    ../../services/fstrim.nix
    ../../services/timesyncd.nix
    ../../packages/vim.nix

    ./kernel.nix
    ./fs.nix
    ./desktop.nix
    ./power.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking = {
    hostName = "x1-carbon-8th";
    networkmanager.enable = true;
    useDHCP = false;
  };

  # Do not inherit server-only groups or passwordless sudo on the laptop.
  users.users.mingcheng.extraGroups = lib.mkForce [
    "wheel"
    "networkmanager"
  ];
  security.sudo.wheelNeedsPassword = lib.mkForce true;

  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
    nvme-cli
  ];
}
