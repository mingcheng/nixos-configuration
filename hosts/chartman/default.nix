{ config, pkgs, lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../nixconfig.nix

    ../../system/boot.nix
    ../../system/fs.nix
    ../../system/i18n.nix
    ../../system/sudo.nix
    ../../system/user.nix
    ../../system/supermicro.nix

    # ../../services/apcupsd.nix
    ../../services/fstrim.nix
    ../../services/libvirtd.nix
    ../../services/prometheus.nix
    ../../services/timesyncd.nix
    ../../services/sshd.nix

    ./kernel.nix
    ../strix/networking.nix
    # ../strix/hostapd.nix
    ./packages.nix
    ../../packages/vim.nix
  ];

  powerManagement = {
    enable = true;
    #cpuFreqGovernor = lib.mkDefault "performance";
    cpuFreqGovernor = lib.mkDefault "powersave";
    cpufreq = {
      max = 2200000;
      min = 800000;
    };
  };

  services.apcupsd = {
    enable = true;
    configText = ''
      UPSCABLE ether
      UPSTYPE net
      DEVICE 10.0.10.6:3551
    '';
  };

  # https://nixos.wiki/wiki/Visual_Studio_Code#Remote_SSH
  programs.nix-ld.enable = true;
  environment.variables = {
    NIX_LD_LIBRARY_PATH =
      lib.mkDefault (lib.makeLibraryPath [ pkgs.stdenv.cc.cc ]);
    NIX_LD = lib.mkDefault
      (lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker");
  };
}
