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
  plasmaPower = t.eval [
    ../../system/power.nix
    { services.desktopManager.plasma6.enable = true; }
  ];
  changedPower = t.eval [
    ../../system/power.nix
    {
      services.desktopManager.plasma6.enable = true;
      services.logind.settings.Login.HandleLidSwitch = "hibernate";
      services.upower = {
        percentageLow = 25;
        percentageCritical = 15;
        percentageAction = 10;
      };
      systemd.sleep.settings.Sleep.HibernateDelaySec = "1h";
    }
  ];
  disabledPower = t.eval [
    ../../system/power.nix
    {
      services.desktopManager.plasma6.enable = true;
      services.upower.enable = lib.mkForce false;
      systemd.sleep.settings.Sleep = {
        AllowHibernation = false;
        AllowSuspendThenHibernate = false;
      };
    }
  ];
in
t.check "modules/system" {
  evaluates = t.validSystem config;
  grub-evaluates = t.validSystem grub;
  disabled-upgrade-evaluates = t.validSystem disabledUpgrade;
  plasma-power-evaluates = t.validSystem plasmaPower;
  changed-power-evaluates = t.validSystem changedPower;
  disabled-power-evaluates = t.validSystem disabledPower;
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
    && !config.boot.plymouth.enable
    && config.boot.tmp.cleanOnBoot;
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
    config.services.logind.settings.Login.HandleLidSwitch == "suspend-then-hibernate"
    && config.services.logind.settings.Login.HandleLidSwitchExternalPower == "suspend-then-hibernate"
    && config.services.logind.settings.Login.HandleLidSwitchDocked == "ignore";
  hibernation =
    config.systemd.sleep.settings.Sleep.AllowHibernation
    && config.systemd.sleep.settings.Sleep.AllowSuspendThenHibernate
    && config.systemd.sleep.settings.Sleep.HibernateDelaySec == "2h"
    && !config.systemd.sleep.settings.Sleep.HibernateOnACPower;
  critical-battery =
    config.services.upower.enable
    && config.services.upower.usePercentageForPolicy
    && config.services.upower.percentageLow == 20
    && config.services.upower.percentageCritical == 10
    && config.services.upower.percentageAction == 7
    && config.services.upower.criticalPowerAction == "Hibernate"
    && !config.services.upower.allowRiskyCriticalPowerAction;
  plasma-sleep-policy =
    lib.all
      (
        profile:
        lib.hasInfix "[${profile}][SuspendAndShutdown]\nSleepMode=3"
          plasmaPower.environment.etc."xdg/powerdevilrc".text
      )
      [
        "AC"
        "Battery"
        "LowBattery"
      ]
    && lib.hasInfix "BatteryCriticalAction=2" plasmaPower.environment.etc."xdg/powerdevilrc".text
    && lib.hasInfix "BatteryCriticalLevel=10" plasmaPower.environment.etc."xdg/powerdevilrc".text;
  power-defaults-overridable =
    changedPower.services.logind.settings.Login.HandleLidSwitch == "hibernate"
    && changedPower.systemd.sleep.settings.Sleep.HibernateDelaySec == "1h"
    && changedPower.services.upower.percentageAction == 10
    && lib.hasInfix "BatteryLowLevel=25" changedPower.environment.etc."xdg/powerdevilrc".text
    && lib.hasInfix "BatteryCriticalLevel=15" changedPower.environment.etc."xdg/powerdevilrc".text;
  headless-no-plasma-policy = !(config.environment.etc ? "xdg/powerdevilrc");
  disabled-power-cleanup =
    !disabledPower.services.upower.enable
    && !(disabledPower.environment.etc ? "UPower/UPower.conf")
    && !(disabledPower.environment.etc ? "xdg/powerdevilrc")
    && disabledPower.services.logind.settings.Login.HandleLidSwitch == "suspend";
  nix-ld =
    config.programs.nix-ld.enable
    && config.environment.variables.MISE_ALL_COMPILE == "false"
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
