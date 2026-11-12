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
  lts-kernel = lib.versions.majorMinor config.boot.kernelPackages.kernel.version == "6.12";
  amd-platform =
    config.hardware.cpu.amd.updateMicrocode
    && !config.hardware.cpu.intel.updateMicrocode
    && builtins.elem "kvm-amd" config.boot.kernelModules
    && builtins.elem "amd_pstate=active" config.boot.kernelParams
    && builtins.elem "amd_iommu=on" config.boot.kernelParams
    && builtins.elem "iommu=pt" config.boot.kernelParams
    && builtins.elem "amdgpu.aspm=0" config.boot.kernelParams
    && builtins.elem "amdgpu.runpm=0" config.boot.kernelParams
    && builtins.elem "amdgpu.bapm=0" config.boot.kernelParams
    && builtins.elem "amdgpu.dcdebugmask=0x2" config.boot.kernelParams
    && builtins.elem "amdgpu.ppfeaturemask=0xfff5baf3" config.boot.kernelParams
    && builtins.elem "amdgpu.lockup_timeout=60000,60000,10000,10000" config.boot.kernelParams;
  early-graphics =
    builtins.elem "amdgpu" config.boot.initrd.kernelModules
    && !(builtins.elem "i915" config.boot.initrd.kernelModules)
    && config.hardware.graphics.enable
    && config.hardware.graphics.enable32Bit;
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
    && !config.services.openssh.openFirewall
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
    && config.networking.firewall.allowedTCPPorts == [ ]
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
