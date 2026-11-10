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
  laptop = t.eval [
    ../../profiles/laptop.nix
    {
      networking.hostName = "laptop-test";
      workstation.users = [ "carol" ];
      users.users.carol.isNormalUser = true;
    }
  ];
  laptopDevelop = t.eval [
    ../../profiles/laptop.nix
    ../../profiles/develop.nix
    {
      networking.hostName = "laptop-develop-test";
      workstation.users = [ "dave" ];
      users.users.dave.isNormalUser = true;
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
  workstationDevelop = t.eval [
    ../../profiles/workstation.nix
    ../../profiles/develop.nix
    {
      networking.hostName = "workstation-develop-test";
      workstation.users = [ "eve" ];
      users.users.eve.isNormalUser = true;
      swapDevices = lib.mkForce [ ];
    }
  ];
  noHostPolicy =
    config:
    !(config.users.users ? mingcheng)
    && !(config.environment.variables ? NIX_BUILD_HOST)
    && !config.boot.loader.systemd-boot.enable
    && !config.zramSwap.enable
    && !config.services.fprintd.enable
    && !config.services.hardware.bolt.enable
    && !config.hardware.cpu.intel.updateMicrocode
    && lib.all (name: !(builtins.elem name config.boot.kernelParams)) [
      "mem_sleep_default=deep"
      "intel_iommu=on"
      "i915.enable_psr=0"
    ]
    &&
      lib.sort builtins.lessThan config.nix.settings.trusted-users == [
        "@wheel"
        "root"
      ];
in
t.check "modules/workstation" {
  desktop-evaluates = t.validSystem desktop;
  laptop-evaluates = t.validSystem laptop;
  laptop-develop-evaluates = t.validSystem laptopDevelop;
  workstation-evaluates = t.validSystem workstation;
  workstation-develop-evaluates = t.validSystem workstationDevelop;
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
    && !desktop.services.adguardhome.enable
    && !desktop.services.mihomo.enable
    && desktop.networking.proxy.default == null
    && !(desktop.systemd.services.nix-daemon.environment ? http_proxy)
    && !desktop.programs.nix-ld.enable
    && !(t.hasPackages desktop.users.users.alice.packages [ "cmake" ]);
  laptop-services-and-packages =
    laptop.virtualisation.docker.enable
    && laptop.services.adguardhome.enable
    && laptop.services.mihomo.enable
    && laptop.networking.proxy.default == "http://127.0.0.1:7890"
    && laptop.powerManagement.enable
    && laptop.services.power-profiles-daemon.enable
    && laptop.boot.resumeDevice == "/dev/disk/by-label/test-swap"
    && laptop.services.keyd.enable
    && laptop.services.fstrim.enable
    && laptop.services.timesyncd.enable
    && !laptop.programs.nix-ld.enable
    && !laptop.programs.direnv.enable
    && t.hasPackages laptop.users.users.carol.packages [
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
      "syncthing"
    ]
    && lib.all (name: !(t.hasPackages laptop.users.users.carol.packages [ name ])) [
      "gnumake"
      "gcc"
      "cmake"
      "ninja"
      "mise"
      "nixfmt"
      "powershell"
      "opencode"
    ];
  laptop-develop-overlay =
    laptopDevelop.programs.nix-ld.enable
    && laptopDevelop.programs.direnv.enable
    && t.hasPackages laptopDevelop.users.users.dave.packages [
      "vscode"
      "konsole"
      "fastfetch"
      "gnumake"
      "cmake"
      "mise"
      "nixfmt"
      "opencode"
    ];
  workstation-services =
    workstation.virtualisation.docker.enable
    && workstation.services.adguardhome.enable
    && workstation.services.mihomo.enable
    && workstation.networking.proxy.default == "http://127.0.0.1:7890"
    && !workstation.programs.nix-ld.enable
    && !workstation.programs.direnv.enable
    && workstation.services.keyd.enable
    && workstation.services.fstrim.enable
    && workstation.services.timesyncd.enable;
  workstation-user-applications = t.hasPackages workstation.users.users.bob.packages [
    "vscode"
    "konsole"
    "fastfetch"
    "htop"
    "btop"
    "gnupg"
    "stow"
    "zoxide"
    "jq"
    "aria2"
    "syncthing"
  ];
  workstation-develop-overlay =
    workstationDevelop.programs.nix-ld.enable
    && workstationDevelop.programs.direnv.enable
    && t.hasPackages workstationDevelop.users.users.eve.packages [
      "vscode"
      "konsole"
      "fastfetch"
      "htop"
      "btop"
      "gnumake"
      "cmake"
      "mise"
      "nixfmt"
      "opencode"
    ];
  cursor-remains-disabled =
    !(t.hasPackages desktop.users.users.alice.packages [ "cursor" ])
    && !(t.hasPackages workstation.users.users.bob.packages [ "cursor" ])
    && !(t.hasPackages workstationDevelop.users.users.eve.packages [ "cursor" ]);
  cli-package-precedence =
    lib.getName (builtins.head workstationDevelop.users.users.eve.packages) == "gnumake"
    && lib.getName (builtins.head laptopDevelop.users.users.dave.packages) == "gnumake";
  applications-not-global =
    lib.all (name: !(t.hasPackages workstationDevelop.environment.systemPackages [ name ]))
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
    && workstation.boot.kernel.sysctl."kernel.kexec_load_disabled" == 1
    && workstation.boot.kernel.sysctl."kernel.kptr_restrict" == 2
    && workstation.boot.kernel.sysctl."fs.suid_dumpable" == 0
    && workstation.systemd.coredump.settings.Coredump.Storage == "none"
    && workstation.virtualisation.docker.daemon.settings.ip == "127.0.0.1";
  host-policy-isolation =
    noHostPolicy desktop
    && desktop.boot.resumeDevice == ""
    && !desktop.services.thermald.enable
    && noHostPolicy laptop
    && noHostPolicy laptopDevelop
    && noHostPolicy workstation
    && workstation.boot.resumeDevice == ""
    && !workstation.services.thermald.enable
    && noHostPolicy workstationDevelop
    && workstationDevelop.boot.resumeDevice == ""
    && !workstationDevelop.services.thermald.enable;
  host-hardware-selection =
    workstation.hardware.cpu.amd.updateMicrocode
    && builtins.elem "amdgpu" workstation.boot.initrd.kernelModules
    && !(builtins.elem "i915" workstation.boot.initrd.kernelModules)
    && workstation.boot.kernelPackages.kernel.drvPath == pkgs.linuxPackages.kernel.drvPath;
  host-build-capacity = workstation.nix.settings.max-jobs == 6 && workstation.nix.settings.cores == 2;
  no-implicit-privileges = workstation.users.users.bob.extraGroups == [ ];
}
