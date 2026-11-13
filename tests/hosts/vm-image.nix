let
  t = import ../lib.nix;
  inherit (t) lib;
  sources = import ../../sources.nix;
  config = t.eval [ ../../main.nix ];
  changed = t.eval [
    ../../main.nix
    {
      networking.hostName = "custom-vm";
      virtualisation.diskSize = 16384;
      services.qemuGuest.enable = false;
    }
  ];
  legacy = t.eval [
    ../../main.nix
    {
      image.efiSupport = false;
    }
  ];
in
t.check "hosts/vm-image" {
  evaluates = t.validSystem config && t.validSystem changed && t.validSystem legacy;
  selection = config.environment.variables.NIX_BUILD_HOST == "vm-image";
  random-hostname =
    config.networking.hostName == ""
    && !(config.environment.etc ? hostname)
    && config.systemd.services ? vm-random-hostname
    && lib.hasInfix "/dev/urandom" config.systemd.services.vm-random-hostname.script;
  host-name-override =
    changed.networking.hostName == "custom-vm"
    && !(changed.systemd.services ? vm-random-hostname)
    && changed.environment.variables.NIX_BUILD_HOST == "vm-image";
  allow-unfree =
    config.nixpkgs.config.allowUnfree
    && (import <nixpkgs> {
      system = t.pkgs.stdenv.hostPlatform.system;
      inherit (config.nixpkgs) config overlays;
    }).config.allowUnfree;
  mainland-mirrors =
    config.nix.settings.substituters == sources.substituters
    && config.system.defaultChannel == sources.channels.nixos
    && config.nix.envVars.GOPROXY == sources.development.goProxy
    && config.environment.sessionVariables.GOPROXY == sources.development.goProxy
    && config.environment.sessionVariables.NPM_CONFIG_GLOBALCONFIG == "/etc/npmrc"
    && lib.hasInfix "registry=${sources.development.npmRegistry}" config.environment.etc.npmrc.text
    && lib.hasInfix sources.development.pypiIndex config.environment.etc."pip.conf".text
    && lib.hasInfix sources.development.pypiIndex config.environment.etc."uv/uv.toml".text
    && lib.hasInfix sources.development.cargoRegistry config.environment.etc."cargo/mainland.toml".text
    && config.environment.sessionVariables.RUSTUP_DIST_SERVER == sources.development.rustupDistServer
    && config.environment.sessionVariables.RUSTUP_UPDATE_ROOT == sources.development.rustupUpdateRoot;
  shared-profile = config.nix.gc.automatic && config.time.timeZone == "Asia/Shanghai";
  qcow2-image =
    config.image.format == "qcow2"
    && config.image.extension == "qcow2"
    && lib.hasSuffix ".qcow2" config.image.fileName
    && config.image.efiSupport
    && config.virtualisation.diskSize == "auto"
    && builtins.isString config.system.build.image.drvPath;
  disk-layout =
    config.boot.loader.systemd-boot.enable
    && !config.boot.loader.grub.enable
    && config.boot.growPartition
    && config.fileSystems."/".device == "/dev/disk/by-label/nixos"
    && config.fileSystems."/".fsType == "ext4"
    && config.fileSystems."/".autoResize
    && config.fileSystems."/boot".device == "/dev/disk/by-label/ESP"
    && config.fileSystems."/boot".fsType == "vfat";
  legacy-boot-override =
    !legacy.image.efiSupport
    && !legacy.boot.loader.systemd-boot.enable
    && legacy.boot.loader.grub.enable
    && legacy.boot.loader.grub.devices == [ "/dev/vda" ]
    && builtins.isString legacy.system.build.image.drvPath;
  disk-size-override = changed.virtualisation.diskSize == 16384 && !changed.services.qemuGuest.enable;
  qemu-guest =
    config.services.qemuGuest.enable
    && builtins.elem "console=ttyS0,115200n8" config.boot.kernelParams
    && lib.all (name: builtins.elem name config.boot.initrd.availableKernelModules) [
      "virtio_pci"
      "virtio_blk"
      "virtio_scsi"
      "virtio_net"
    ];
  docker =
    config.virtualisation.docker.enable
    && config.virtualisation.docker.liveRestore
    && config.virtualisation.docker.autoPrune.enable
    && t.hasPackages config.environment.systemPackages [ "docker-compose" ]
    && builtins.elem "docker" config.users.users.mingcheng.extraGroups;
  root-and-ssh =
    config.users.users.root.initialHashedPassword == ""
    && config.services.openssh.enable
    && !config.services.openssh.openFirewall
    && config.services.openssh.settings.PermitRootLogin == "no"
    && !config.services.openssh.settings.PermitEmptyPasswords
    && !config.services.openssh.settings.PasswordAuthentication
    && !config.services.openssh.settings.KbdInteractiveAuthentication
    && config.services.openssh.settings.AuthenticationMethods == "publickey";
  cli-tools = t.hasPackages config.environment.systemPackages [
    "git"
    "neovim"
    "inetutils"
  ];
  account-and-trust =
    config.users.mutableUsers
    && config.users.users.mingcheng.isNormalUser
    && builtins.elem "wheel" config.users.users.mingcheng.extraGroups
    &&
      config.nix.settings.trusted-users == [
        "root"
        "mingcheng"
      ];
  dhcp = config.networking.useDHCP && !config.networking.enableIPv6;
  headless =
    !config.services.xserver.enable
    && !config.services.displayManager.enable
    && !config.services.flatpak.enable
    && !config.programs.xwayland.enable
    && !config.xdg.portal.enable
    && !(config ? workstation)
    && config.users.users.mingcheng.packages == [ ];
  no-desktop-policy = !config.zramSwap.enable && !config.services.fprintd.enable;
  no-proxy = !(config.systemd.services.nix-daemon.environment ? http_proxy);
}
