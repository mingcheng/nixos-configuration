{ config, lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../nixconfig.nix

    ../../hardware/cpu_intel.nix
    ../../hardware/power.nix

    ../../system/boot.nix
    ../../system/env.nix
    ../../system/fs.nix
    ../../system/i18n.nix
    ../../system/misc.nix
    ../../system/shell.nix
    ../../system/sudo.nix
    ../../system/user.nix

    ../../services/apcupsd.nix
    ../../services/fstrim.nix
    ../../services/libvirtd.nix
    ../../services/prometheus.nix
    ../../services/timesyncd.nix

    ./openssh.nix
    ./kernel.nix
    ./networking.nix
    ./packages.nix
  ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "performance";
  };
}
