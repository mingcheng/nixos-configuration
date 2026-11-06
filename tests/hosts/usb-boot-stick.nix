let
  t = import ../lib.nix;
  config = t.eval [ ../../main.nix ];
in
t.check "hosts/usb-boot-stick" {
  evaluates = t.validSystem config;
  selection =
    config.networking.hostName == "usb-boot-stick"
    && config.environment.variables.NIX_BUILD_HOST == "usb-boot-stick";
  shared-profile = config.nix.gc.automatic && config.time.timeZone == "Asia/Shanghai";
  removable-efi =
    config.boot.loader.grub.enable
    && config.boot.loader.grub.efiSupport
    && config.boot.loader.grub.efiInstallAsRemovable
    && config.boot.loader.grub.devices == [ "nodev" ]
    && !config.boot.loader.efi.canTouchEfiVariables
    && config.boot.loader.efi.efiSysMountPoint == "/efi";
  storage-drivers = t.lib.all (name: builtins.elem name config.boot.kernelModules) [
    "nvme"
    "usb_storage"
    "sd_mod"
    "f2fs"
  ];
  temporary-files = config.boot.tmp.useTmpfs;
  maintenance-tools = t.hasPackages config.environment.systemPackages [
    "kubectl"
    "k9s"
    "git"
    "neovim"
    "inetutils"
  ];
  dhcp = config.networking.useDHCP && !config.networking.enableIPv6;
  headless =
    !config.services.displayManager.enable
    && !config.services.flatpak.enable
    && !(config.users.users ? mingcheng);
  no-desktop-policy = !config.zramSwap.enable && !config.services.fprintd.enable;
}
