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
    ../../services/apcupsd.nix

    ./kernel.nix
    ./networking.nix
    ../chartman/packages.nix
    ../../packages/vim.nix
  ];

  services.prometheus.exporters.smartctl = {
    enable = true;
    devices = [ "/dev/nvme0n1" ];
  };

  services.prometheus.exporters.apcupsd = {
    enable = true;
    apcupsdNetwork = "tcp4";
    apcupsdAddress = "127.0.0.1:3551";
  };

  services.prometheus.exporters.ipmi = { enable = true; };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "performance";
  };
}
