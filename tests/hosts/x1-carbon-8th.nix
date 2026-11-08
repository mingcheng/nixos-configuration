let
  t = import ../lib.nix;
  inherit (t) lib;
  config = t.eval [ ../../main.nix ];
  changed = t.eval [
    ../../main.nix
    {
      networking.hostName = "custom-x1";
      networking.proxy = {
        default = "http://proxy.example.test:3128";
        noProxy = "localhost,.example.test";
      };
      nix.settings = {
        max-jobs = 3;
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
t.check "hosts/x1-carbon-8th" {
  evaluates = t.validSystem config;
  selection =
    config.networking.hostName == "x1-carbon-8th"
    && config.environment.variables.NIX_BUILD_HOST == "x1-carbon-8th";
  host-name-override =
    changed.networking.hostName == "custom-x1"
    && changed.environment.variables.NIX_BUILD_HOST == "x1-carbon-8th";
  shared-profile = config.nix.gc.automatic && config.time.timeZone == "Asia/Shanghai";
  online_hosts = lib.all (
    url: builtins.elem (toString (builtins.fetchurl url)) (map toString config.networking.hostFiles)
  ) (import ../../sources.nix).hosts;
  selected-user = config.workstation.users == [ "mingcheng" ];
  wayland-desktop =
    config.services.desktopManager.plasma6.enable
    && config.services.displayManager.sddm.wayland.enable
    && config.services.displayManager.defaultSession == "plasma";
  plasma-portals =
    !(config.xdg.portal.config.common ? default) && config.xdg.portal.configPackages != [ ];
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
  lts-kernel = lib.versions.majorMinor config.boot.kernelPackages.kernel.version == "6.12";
  early-graphics = builtins.elem "i915" config.boot.initrd.kernelModules;
  systemd-boot =
    config.boot.loader.systemd-boot.enable
    && !config.boot.loader.grub.enable
    && config.boot.loader.efi.efiSysMountPoint == "/boot";
  disk-resume = config.boot.resumeDevice == "/dev/disk/by-label/test-swap";
  compressed-swap =
    config.zramSwap.enable
    && config.zramSwap.algorithm == "zstd"
    && config.zramSwap.memoryPercent == 25
    && config.zramSwap.priority == 100;
  power-policy =
    config.services.power-profiles-daemon.enable
    && !config.services.thermald.enable
    && !config.services.tlp.enable;
  build-limits = config.nix.settings.max-jobs == 2 && config.nix.settings.cores == 4;
  build-limits-overridable = changed.nix.settings.max-jobs == 3 && changed.nix.settings.cores == 2;
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
    config.networking.firewall.enable
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
