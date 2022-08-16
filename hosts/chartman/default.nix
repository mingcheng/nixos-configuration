{ config, lib, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    ../../nixconfig.nix
    ../../hardware/cpu_intel.nix
    # ./hardware/fs.nix
    # ./hardware/kernel.nix
    ../../hardware/power.nix

    ../../system/fs.nix
    ../../system/autoupdate.nix
    ../../system/boot.nix
    ../../system/env.nix
    ../../system/i18n.nix
    ../../system/misc.nix
    ../../system/sudo.nix
    ../../system/user.nix
    ../../system/shell.nix

    ../../services/apcupsd.nix
    ../../services/libvirtd.nix
    ../../services/timesyncd.nix
    ../../services/fstrim.nix
    ../../services/prometheus.nix

    ../../packages/default.nix
    ../../packages/fish.nix
    # ../../packages/vim.nix
    ../../packages/nvim.nix
    ../../packages/git.nix

    ./kernel.nix
    ./networking.nix
    ./openssh.nix
  ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "performance";
  };
}
