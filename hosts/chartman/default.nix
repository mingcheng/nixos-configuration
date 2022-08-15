{ config, lib, ... }: {
  imports = [
    ../../nixconfig.nix
    ../../hardware-configuration.nix

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
