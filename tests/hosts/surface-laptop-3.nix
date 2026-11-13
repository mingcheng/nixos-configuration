let
  t = import ../lib.nix;
  inherit (t) lib;
  sources = import ../../sources.nix;
  config = t.eval [ ../../main.nix ];
  changed = t.eval [
    ../../main.nix
    {
      networking.hostName = "custom-surface";
      networking.proxy = {
        default = "http://proxy.example.test:3128";
        noProxy = "localhost,.example.test";
      };
      nix.settings = {
        max-jobs = 2;
        cores = 2;
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
t.check "hosts/surface-laptop-3" {
  evaluates = t.validSystem config;
  selection =
    config.networking.hostName == "surface-laptop-3"
    && config.environment.variables.NIX_BUILD_HOST == "surface-laptop-3";
  host-name-override =
    changed.networking.hostName == "custom-surface"
    && changed.environment.variables.NIX_BUILD_HOST == "surface-laptop-3";
  shared-profile = config.nix.gc.automatic && config.time.timeZone == "Asia/Shanghai";
  online_hosts = lib.all (
    url: builtins.elem (toString (builtins.fetchurl url)) (map toString config.networking.hostFiles)
  ) sources.hosts;
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

    "gnupg"
    "stow"
    "zoxide"
    "jq"
    "aria2"
    "mise"
    "python3"
    "gnumake"
    "opencode"
  ];
  no-development-toolchain =
    config.programs.nix-ld.enable
    && !config.programs.direnv.enable
    && t.hasPackages config.environment.systemPackages [ "fhs" ]
    && lib.all (name: !(t.hasPackages config.users.users.mingcheng.packages [ name ])) [
      "gcc"
      "cmake"
      "ninja"
      "pkg-config"
      "nixfmt"
      "manix"
      "nix-du"
      "nix-index"
      "nixpkgs-lint"
      "nixpkgs-pytools"
      "nixpkgs-review"
      "shfmt"
      "nushell"
      "powershell"
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
    && !(t.hasPackages config.environment.systemPackages [ "konsole" ]);
  prebuilt-surface-kernel =
    lib.versions.majorMinor config.boot.kernelPackages.kernel.version == "6.12"
    && config.boot.kernelPatches == [ ]
    && config.boot.kernelPackages.kernel.drvPath == t.pkgs.linuxPackages_6_12.kernel.drvPath
    && builtins.elem "hid_multitouch" config.boot.initrd.availableKernelModules
    && builtins.elem "surface_aggregator" config.boot.initrd.availableKernelModules
    && builtins.elem "surface_hid" config.boot.initrd.availableKernelModules
    && !(builtins.elem "surface_kbd" config.boot.initrd.availableKernelModules)
    && builtins.elem "hid_multitouch" config.boot.kernelModules
    && builtins.elem "surface_aggregator_cdev" config.boot.kernelModules
    && builtins.elem "surface_gpe" config.boot.kernelModules
    && builtins.elem "surface_platform_profile" config.boot.kernelModules
    && t.hasPackages config.environment.systemPackages [ "surface-control" ];
  touchscreen-disabled =
    !config.services.iptsd.enable
    && !config.hardware.sensor.iio.enable
    && builtins.elem "ipts" config.boot.blacklistedKernelModules
    && builtins.elem "ithc" config.boot.blacklistedKernelModules
    && !(builtins.elem "hid_multitouch" config.boot.blacklistedKernelModules)
    && !(builtins.elem "surface_gpe" config.boot.blacklistedKernelModules)
    && lib.hasInfix "ID_INPUT_TOUCHSCREEN" config.services.udev.extraRules
    && lib.hasInfix "ID_INPUT_TABLET" config.services.udev.extraRules
    && lib.hasInfix "LIBINPUT_IGNORE_DEVICE" config.services.udev.extraRules;
  early-graphics = builtins.elem "i915" config.boot.initrd.kernelModules;
  systemd-boot =
    config.boot.loader.systemd-boot.enable
    && !config.boot.loader.grub.enable
    && config.boot.loader.efi.efiSysMountPoint == "/boot";
  disk-resume =
    config.boot.resumeDevice == "/dev/disk/by-label/test-swap"
    && builtins.elem "mem_sleep_default=s2idle" config.boot.kernelParams;
  compressed-swap =
    config.zramSwap.enable
    && config.zramSwap.algorithm == "zstd"
    && config.zramSwap.memoryPercent == 50
    && config.zramSwap.priority == 100;
  power-policy =
    config.services.power-profiles-daemon.enable
    && config.services.thermald.enable
    && config.services.thermald.configFile != null
    && !(lib.hasInfix "--adaptive" config.systemd.services.thermald.serviceConfig.ExecStart)
    && !config.services.tlp.enable
    && !config.services.fprintd.enable
    && !config.services.hardware.bolt.enable;
  build-limits = config.nix.settings.max-jobs == 1 && config.nix.settings.cores == 4;
  build-limits-overridable = changed.nix.settings.max-jobs == 2 && changed.nix.settings.cores == 2;
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
