let
  t = import ../lib.nix;
  config = t.eval [ ../../main.nix ];
in
t.check "hosts/vm-image" {
  evaluates = t.validSystem config;
  selection =
    config.networking.hostName == "vm-image"
    && config.environment.variables.NIX_BUILD_HOST == "vm-image";
  shared-profile = config.nix.gc.automatic && config.time.timeZone == "Asia/Shanghai";
  qemu-drivers = t.lib.all (name: builtins.elem name config.boot.initrd.availableKernelModules) [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
  ];
  dhcp = config.networking.useDHCP && !config.networking.enableIPv6;
  headless =
    !config.services.xserver.enable
    && !config.services.displayManager.enable
    && !config.services.flatpak.enable
    && !(config.users.users ? mingcheng);
  no-desktop-policy =
    !config.zramSwap.enable && !config.services.fprintd.enable && !config.virtualisation.docker.enable;
  no-proxy = !(config.systemd.services.nix-daemon.environment ? http_proxy);
}
