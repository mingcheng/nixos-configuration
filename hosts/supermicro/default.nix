{ config, lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../nixconfig.nix

    ../../system/boot.nix
    ../../system/fs.nix
    ../../system/i18n.nix
    ../../system/sudo.nix
    ../../system/user.nix
    ../../system/supermicro.nix

    ../../services/fstrim.nix
    ../../services/libvirtd.nix
    ../../services/prometheus.nix
    ../../services/timesyncd.nix
    ../../services/sshd.nix

    ../chartman/kernel.nix
    ./networking.nix
    ../chartman/packages.nix
    ../../packages/vim.nix
  ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "performance";
  };

  services.apcupsd = {
    enable = true;
    configText = ''
      UPSCABLE ether
      UPSTYPE net
      DEVICE 192.168.0.4:3551
    '';
  };
}
