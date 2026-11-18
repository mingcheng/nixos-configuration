let
  t = import ../lib.nix;
  inherit (t) lib;
  config = t.eval [ ../../main.nix ];
  changed = t.eval [
    ../../main.nix
    {
      networking.hostName = "custom-ryzen";
      networking.proxy = {
        default = "http://proxy.example.test:3128";
        noProxy = "localhost,.example.test";
      };
      nix.settings = {
        max-jobs = 2;
        cores = 4;
      };
    }
  ];
  disabled = t.eval [
    ../../main.nix
    {
      networking.proxy = {
        default = null;
        noProxy = "";
      };
    }
  ];
  protocolProxy = t.eval [
    ../../main.nix
    {
      networking.proxy = {
        default = null;
        httpProxy = "http://http.example.test:3128";
        httpsProxy = "http://https.example.test:3129";
      };
    }
  ];
  proxyMatches =
    cfg:
    let
      expected = cfg.networking.proxy.envVars;
      names = builtins.attrNames expected;
    in
    lib.getAttrs names cfg.environment.sessionVariables == expected
    && lib.getAttrs names cfg.systemd.services.nix-daemon.environment == expected;
in
t.check "hosts/ryzen-4750g" {
  evaluates = t.validSystem config;
  selection =
    config.networking.hostName == "ryzen-4750g"
    && config.environment.variables.NIX_BUILD_HOST == "ryzen-4750g";
  host-name-override =
    changed.networking.hostName == "custom-ryzen"
    && changed.environment.variables.NIX_BUILD_HOST == "ryzen-4750g";
  shared-profile = config.nix.gc.automatic && config.time.timeZone == "Asia/Shanghai";
  online_hosts = lib.all (
    url: builtins.elem (toString (builtins.fetchurl url)) (map toString config.networking.hostFiles)
  ) (import ../../sources.nix).hosts;
  selected-user = config.workstation.users == [ "mingcheng" ];
  wayland-desktop =
    !config.services.xserver.enable
    && config.programs.xwayland.enable
    && config.services.dbus.implementation == "broker"
    && config.services.desktopManager.plasma6.enable
    && config.services.displayManager.sddm.wayland.enable
    && config.services.displayManager.sddm.wayland.compositor == "kwin"
    && config.services.displayManager.defaultSession == "plasma";
  plasma-portals =
    config.xdg.portal.xdgOpenUsePortal
    && !(config.xdg.portal.config.common ? default)
    && config.xdg.portal.configPackages != [ ]
    && t.hasPackages config.xdg.portal.extraPortals [
      "xdg-desktop-portal-kde"
      "xdg-desktop-portal-gtk"
    ];
  user-applications = t.hasPackages config.users.users.mingcheng.packages [
    "vscode"

    "konsole"
    "dolphin"
    "fastfetch"
    "htop"
    "btop"
    "gnumake"

    "cmake"
    "ninja"
    "mise"
    "nixfmt"
    "gnupg"
    "stow"
    "zoxide"
    "jq"
    "aria2"
    "powershell"
    "opencode"
    "go"
    "gopls"
    "delve"
    "golangci-lint"
    "gotools"
    "rustup"
    "clang-wrapper"
    "lldb"
    "cargo"

    "amdgpu_top"
    "glmark2"
    "memtest_vulkan"
    "s-tui"
    "stress-ng"
    "vkmark"
  ];
  all-shared-applications-assigned = lib.all (
    package:
    builtins.elem package.outPath (
      map (installed: installed.outPath) config.users.users.mingcheng.packages
    )
  ) config.workstation.userPackages;
  cursor-remains-disabled = !(t.hasPackages config.users.users.mingcheng.packages [ "cursor" ]);
  applications-not-global =
    !(t.hasPackages config.environment.systemPackages [ "vscode" ])
    && !(t.hasPackages config.environment.systemPackages [ "cursor" ])
    && !(t.hasPackages config.environment.systemPackages [ "fastfetch" ])
    && !(t.hasPackages config.environment.systemPackages [ "konsole" ])
    && !(t.hasPackages config.environment.systemPackages [ "amdgpu_top" ])
    && !(t.hasPackages config.environment.systemPackages [ "glmark2" ])
    && !(t.hasPackages config.environment.systemPackages [ "memtest_vulkan" ]);
  lts-kernel = lib.versions.majorMinor config.boot.kernelPackages.kernel.version == "6.18";
  amd-platform =
    config.hardware.cpu.amd.updateMicrocode
    && !config.hardware.cpu.intel.updateMicrocode
    && builtins.elem "kvm-amd" config.boot.kernelModules
    && builtins.elem "k10temp" config.boot.kernelModules
    && builtins.elem "asus_wmi_sensors" config.boot.kernelModules
    && builtins.elem "eeepc_wmi" config.boot.blacklistedKernelModules
    && builtins.elem "asus_wmi" config.boot.blacklistedKernelModules
    && builtins.elem "amd_pstate=active" config.boot.kernelParams
    && !(builtins.elem "amd_iommu=on" config.boot.kernelParams)
    && builtins.elem "iommu=pt" config.boot.kernelParams
    && builtins.elem "pcie_aspm=off" config.boot.kernelParams
    && builtins.elem "nvme_core.default_ps_max_latency_us=20000" config.boot.kernelParams
    && builtins.elem "amdgpu.aspm=0" config.boot.kernelParams
    && builtins.elem "amdgpu.runpm=0" config.boot.kernelParams
    && builtins.elem "amdgpu.dcdebugmask=0x2" config.boot.kernelParams
    && builtins.elem "amdgpu.debug_mask=0x4" config.boot.kernelParams
    && !(lib.any (lib.hasPrefix "amdgpu.reset_method=") config.boot.kernelParams)
    && builtins.elem "amdgpu.lockup_timeout=60000,60000,10000,10000" config.boot.kernelParams;
  gpu-clock-gating =
    lib.filter (lib.hasPrefix "amdgpu.ppfeaturemask=") config.boot.kernelParams == [
      "amdgpu.ppfeaturemask=0xfff5baf3"
    ]
    &&
      lib.filter (lib.hasPrefix "amdgpu.cg_mask=") config.boot.kernelParams == [
        "amdgpu.cg_mask=0x1b6a05"
      ]
    && !(lib.any (lib.hasPrefix "amdgpu.pg_mask=") config.boot.kernelParams);
  early-graphics =
    builtins.elem "amdgpu" config.boot.initrd.kernelModules
    && !(builtins.elem "i915" config.boot.initrd.kernelModules)
    && config.hardware.graphics.enable
    && config.hardware.graphics.enable32Bit;
  filesystem-loading =
    builtins.elem "f2fs" config.boot.initrd.kernelModules
    && !(builtins.elem "f2fs" config.boot.kernelModules)
    && !(builtins.elem "btrfs" config.boot.initrd.kernelModules);
  home-btrfs =
    let
      home = config.fileSystems."/home";
    in
    home.fsType == "btrfs"
    && !home.neededForBoot
    && lib.all (opt: builtins.elem opt home.options) [
      "subvol=@home"
      "noatime"
      "compress=zstd:1"
      "discard=async"
    ]
    && lib.filter (lib.hasPrefix "compress") home.options == [ "compress=zstd:1" ];
  backup-disk =
    let
      backup = config.fileSystems."/mnt/backup";
    in
    backup.fsType == "btrfs" && builtins.elem "nofail" backup.options && !backup.neededForBoot;
  home-snapper =
    let
      home = config.services.snapper.configs.home;
    in
    home.SUBVOLUME == "/home"
    && home.TIMELINE_CREATE
    && home.TIMELINE_CLEANUP
    && home.ALLOW_USERS == [ "mingcheng" ]
    && config.services.snapper.persistentTimer
    && builtins.elem "snapper-timeline.service" config.systemd.services.home-snapshot-dirs.requiredBy;
  home-btrbk =
    let
      instance = config.services.btrbk.instances.home;
      service = config.systemd.services.btrbk-home;
    in
    instance.settings.backend == "btrfs-progs"
    && instance.settings.subvolume."/home".target == "/mnt/backup/btrbk"
    && instance.onCalendar == "daily"
    && service.serviceConfig.User == "root"
    && builtins.elem "/mnt/backup" service.unitConfig.RequiresMountsFor
    && config.security.sudo.execWheelOnly;
  btrfs-scrub =
    config.services.btrfs.autoScrub.enable
    &&
      config.services.btrfs.autoScrub.fileSystems == [
        "/home"
        "/mnt/backup"
      ]
    && builtins.elem "/mnt/backup" config.systemd.services.btrfs-scrub-mnt-backup.unitConfig.RequiresMountsFor
    && config.services.fstrim.enable;
  no-unused-kernel-parameters =
    lib.all (
      param: !(lib.hasPrefix "amdgpu.bapm=" param) && !(lib.hasPrefix "selinux=" param)
    ) config.boot.kernelParams
    && !(builtins.elem "selinux" config.security.lsm);
  # NetworkManager re-enables IPv6 on managed links, so no half-disabled sysctls.
  ipv6-left-to-networkmanager =
    config.networking.enableIPv6
    && !config.boot.kernel.sysctl."net.ipv6.conf.all.disable_ipv6"
    && !config.boot.kernel.sysctl."net.ipv6.conf.default.disable_ipv6";
  cargo-mirror-link =
    config.systemd.user.tmpfiles.users.mingcheng.rules == [
      "L %h/.cargo/config.toml - - - - /etc/cargo/mainland.toml"
    ];
  systemd-boot =
    config.boot.loader.systemd-boot.enable
    && !config.boot.loader.grub.enable
    && config.boot.loader.efi.efiSysMountPoint == "/boot";
  no-disk-hibernation =
    config.boot.resumeDevice == ""
    && config.systemd.sleep.settings.Sleep.AllowSuspend
    && !config.systemd.sleep.settings.Sleep.AllowHibernation
    && !config.systemd.sleep.settings.Sleep.AllowSuspendThenHibernate;
  compressed-swap =
    config.zramSwap.enable
    && config.zramSwap.algorithm == "zstd"
    && config.zramSwap.memoryPercent == 25
    && config.zramSwap.priority == 100;
  power-policy =
    config.powerManagement.enable
    && config.services.power-profiles-daemon.enable
    && !config.services.thermald.enable
    && !config.services.tlp.enable
    && !config.services.fprintd.enable
    && !config.services.hardware.bolt.enable;
  desktop-services =
    config.hardware.bluetooth.enable
    && config.services.openssh.enable
    && config.services.openssh.openFirewall
    && config.virtualisation.libvirtd.enable;
  build-limits = config.nix.settings.max-jobs == 4 && config.nix.settings.cores == 8;
  build-limits-overridable = changed.nix.settings.max-jobs == 2 && changed.nix.settings.cores == 4;
  proxy-default = config.networking.proxy.default == "http://127.0.0.1:7890";
  proxy-inheritance = proxyMatches config && proxyMatches changed && proxyMatches protocolProxy;
  proxy-disabled =
    lib.all
      (
        name:
        !(builtins.hasAttr name disabled.environment.sessionVariables)
        && !(builtins.hasAttr name disabled.systemd.services.nix-daemon.environment)
      )
      [
        "http_proxy"
        "https_proxy"
        "all_proxy"
        "ftp_proxy"
        "rsync_proxy"
      ];
  no-protocol-fallback = !(protocolProxy.systemd.services.nix-daemon.environment ? all_proxy);
  nsncd-no-dns-restarts = config.networking.resolvconf.extraConfig == "libc_restart=':'";
  firewall =
    config.networking.nftables.enable
    && config.networking.firewall.enable
    && config.networking.firewall.allowedTCPPorts == config.services.openssh.ports
    && config.networking.firewall.allowedUDPPorts == [ ]
    && config.networking.firewall.trustedInterfaces == [ "lo" ];
  kernel-security =
    config.boot.kernel.sysctl."kernel.kexec_load_disabled" == 1
    && config.boot.kernel.sysctl."kernel.kptr_restrict" == 2
    && config.boot.kernel.sysctl."fs.suid_dumpable" == 0
    && !config.security.protectKernelImage
    && !(builtins.elem "nohibernate" config.boot.kernelParams);
  trusted-users =
    config.nix.settings.trusted-users == [
      "root"
      "mingcheng"
    ];
  docker-loopback =
    config.virtualisation.docker.daemon.settings.ip == "127.0.0.1"
    &&
      config.virtualisation.docker.daemon.settings.default-network-opts.bridge."com.docker.network.bridge.host_binding_ipv4"
      == "127.0.0.1";
}
