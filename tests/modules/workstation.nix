let
  t = import ../lib.nix;
  inherit (t) lib pkgs;
  desktop = t.eval [
    ../../profiles/desktop.nix
    {
      networking.hostName = "desktop-test";
      workstation.users = [ "alice" ];
      users.users.alice.isNormalUser = true;
      swapDevices = lib.mkForce [ ];
    }
  ];
  workstation = t.eval [
    ../../profiles/workstation.nix
    {
      networking.hostName = "workstation-test";
      workstation.users = [ "bob" ];
      users.users.bob.isNormalUser = true;
      boot.kernelPackages = pkgs.linuxPackages;
      boot.initrd.kernelModules = [ "amdgpu" ];
      hardware.cpu.amd.updateMicrocode = true;
      swapDevices = lib.mkForce [ ];
      nix.settings = {
        max-jobs = 6;
        cores = 2;
      };
    }
  ];
  noHostPolicy =
    config:
    !(config.users.users ? mingcheng)
    && !(config.environment.variables ? NIX_BUILD_HOST)
    && !config.boot.loader.systemd-boot.enable
    && config.boot.resumeDevice == ""
    && !config.zramSwap.enable
    && !config.services.fprintd.enable
    && !config.services.hardware.bolt.enable
    && !config.services.thermald.enable
    && !config.hardware.cpu.intel.updateMicrocode
    && lib.all (name: !(builtins.elem name config.boot.kernelParams)) [
      "mem_sleep_default=deep"
      "intel_iommu=on"
      "i915.enable_psr=0"
    ]
    && config.networking.proxy.default == null
    && !(config.systemd.services.nix-daemon.environment ? http_proxy)
    &&
      lib.sort builtins.lessThan config.nix.settings.trusted-users == [
        "@wheel"
        "root"
      ];
in
t.check "modules/workstation" {
  desktop-evaluates = t.validSystem desktop;
  workstation-evaluates = t.validSystem workstation;
  desktop-composition =
    desktop.nix.gc.automatic
    && desktop.services.desktopManager.plasma6.enable
    && desktop.services.displayManager.sddm.wayland.enable
    && desktop.services.pipewire.enable
    && desktop.services.printing.enable
    && desktop.services.keyd.enable
    && desktop.i18n.inputMethod.enable
    && desktop.networking.networkmanager.enable
    && !desktop.networking.useDHCP;
  desktop-user-applications = t.hasPackages desktop.users.users.alice.packages [
    "vscode"
    "konsole"
    "dolphin"
  ];
  development-is-opt-in =
    !desktop.virtualisation.docker.enable
    && !desktop.programs.nix-ld.enable
    && !(t.hasPackages desktop.users.users.alice.packages [ "cmake" ]);
  workstation-services =
    workstation.virtualisation.docker.enable
    && workstation.programs.nix-ld.enable
    && workstation.services.keyd.enable
    && workstation.services.fstrim.enable
    && workstation.services.timesyncd.enable;
  workstation-user-applications = t.hasPackages workstation.users.users.bob.packages [
    "vscode"
    "konsole"
    "fastfetch"
    "htop"
    "btop"
    "cmake"
    "mise"
    "nixfmt"
  ];
  cursor-remains-disabled =
    !(t.hasPackages desktop.users.users.alice.packages [ "cursor" ])
    && !(t.hasPackages workstation.users.users.bob.packages [ "cursor" ]);
  cli-package-precedence =
    lib.getName (builtins.head workstation.users.users.bob.packages) == "gnumake";
  applications-not-global =
    lib.all (name: !(t.hasPackages workstation.environment.systemPackages [ name ]))
      [
        "vscode"
        "cursor"
        "konsole"
        "fastfetch"
        "cmake"
      ];
  maintenance-tools = t.hasPackages workstation.environment.systemPackages [
    "ethtool"
    "nvme-cli"
    "smartmontools"
    "file"
  ];
  shared-security =
    workstation.networking.firewall.enable
    && workstation.networking.firewall.allowedTCPPorts == [ ]
    && !workstation.networking.firewall.allowPing
    && workstation.nix.settings.sandbox
    && workstation.boot.kernel.sysctl."kernel.kptr_restrict" == 2
    && workstation.systemd.coredump.settings.Coredump.Storage == "none"
    && workstation.virtualisation.docker.daemon.settings.ip == "127.0.0.1";
  host-policy-isolation = noHostPolicy desktop && noHostPolicy workstation;
  host-hardware-selection =
    workstation.hardware.cpu.amd.updateMicrocode
    && builtins.elem "amdgpu" workstation.boot.initrd.kernelModules
    && !(builtins.elem "i915" workstation.boot.initrd.kernelModules)
    && workstation.boot.kernelPackages.kernel.drvPath == pkgs.linuxPackages.kernel.drvPath;
  host-build-capacity = workstation.nix.settings.max-jobs == 6 && workstation.nix.settings.cores == 2;
  no-implicit-privileges = workstation.users.users.bob.extraGroups == [ ];
}
