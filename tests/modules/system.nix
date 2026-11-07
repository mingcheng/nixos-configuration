let
  t = import ../lib.nix;
  inherit (t) lib;
  config = t.eval [
    ../../system/autoupgrade.nix
    ../../system/boot.nix
    ../../system/cpu_intel.nix
    ../../system/fs.nix
    ../../system/kernel.nix
    ../../system/ld.nix
    ../../system/network_hosts.nix
    ../../system/networking.nix
    ../../system/power.nix
    ../../system/shell_alias.nix
    ../../system/supermicro.nix
    {
      environment.variables.NIX_BUILD_HOST = "vm-image";
      hardware.enableRedistributableFirmware = true;
    }
  ];
  grub = t.eval [ ../../system/grub.nix ];
  disabledUpgrade = t.eval [
    ../../system/autoupgrade.nix
    { system.autoUpgrade.enable = lib.mkForce false; }
  ];
  changed = t.eval [
    ../../system/kernel.nix
    ../../system/cpu_intel.nix
    {
      boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "cubic";
      hardware.enableRedistributableFirmware = false;
    }
  ];
in
t.check "modules/system" {
  evaluates = t.validSystem config;
  grub-evaluates = t.validSystem grub;
  disabled-upgrade-evaluates = t.validSystem disabledUpgrade;
  upgrade-channel = config.system.autoUpgrade.channel == (import ../../sources.nix).channels.nixos;
  upgrade-host = config.systemd.services.nixos-upgrade.environment.NIX_BUILD_HOST == "vm-image";
  no-unattended-reboot = !config.system.autoUpgrade.allowReboot;
  disabled-upgrade-cleanup =
    !disabledUpgrade.system.autoUpgrade.enable
    && !(disabledUpgrade.systemd.services ? nixos-upgrade)
    && !(disabledUpgrade.systemd.timers ? nixos-upgrade);
  boot-policy =
    config.boot.loader.systemd-boot.enable
    && config.boot.loader.systemd-boot.configurationLimit == 7
    && config.boot.loader.timeout == 3
    && !config.boot.plymouth.enable;
  removable-grub =
    grub.boot.loader.grub.efiInstallAsRemovable && grub.boot.loader.grub.devices == [ "nodev" ];
  root-filesystem =
    config.fileSystems."/".device == "/dev/disk/by-label/nixos"
    && config.fileSystems."/".fsType == "f2fs";
  efi-filesystem =
    config.fileSystems."/efi".device == "/dev/disk/by-label/EFI"
    && config.fileSystems."/efi".fsType == "vfat";
  microcode-follows-firmware =
    config.hardware.cpu.intel.updateMicrocode && !changed.hardware.cpu.intel.updateMicrocode;
  kernel-defaults =
    config.boot.kernel.sysctl."net.ipv4.tcp_congestion_control" == "bbr"
    && config.boot.kernel.sysctl."net.core.default_qdisc" == "fq"
    && config.boot.kernel.sysctl."vm.overcommit_memory" == 0;
  kernel-defaults-overridable =
    changed.boot.kernel.sysctl."net.ipv4.tcp_congestion_control" == "cubic";
  networking = config.networking.useDHCP && !config.networking.enableIPv6;
  hosts_module = lib.all (
    url: builtins.elem (toString (builtins.fetchurl url)) (map toString config.networking.hostFiles)
  ) (import ../../sources.nix).hosts;
  power-management = config.powerManagement.enable && config.services.power-profiles-daemon.enable;
  lid-policy =
    config.services.logind.settings.Login.HandleLidSwitch == "suspend"
    && config.services.logind.settings.Login.HandleLidSwitchDocked == "ignore";
  hibernation =
    config.systemd.sleep.settings.Sleep.AllowHibernation
    && config.systemd.sleep.settings.Sleep.HibernateDelaySec == "2h";
  nix-ld =
    config.programs.nix-ld.enable
    && config.environment.variables.MISE_NODE_COMPILE == "false"
    && t.hasPackages config.programs.nix-ld.libraries [
      "openssl"
      "sqlite"
      "libffi"
    ];
  fhs-shell = t.hasPackages config.environment.systemPackages [ "fhs" ];
  aliases =
    config.environment.shellAliases.rm == "rm -i" && config.environment.shellAliases.ll == "ls -l";
  ipmi =
    builtins.elem "ipmi_si" config.boot.kernelModules
    && t.hasPackages config.environment.systemPackages [ "ipmitool" ];
}
