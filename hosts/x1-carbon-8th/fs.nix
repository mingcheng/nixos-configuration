{ config, lib, ... }: {
  imports = [ ../../system/fs.nix ];

  # Use scheduled TRIM instead of foreground discards on the laptop SSD.
  fileSystems."/".options = lib.mkForce [
    "defaults"
    "noatime"
    "background_gc=on"
    "nodiscard"
    "alloc_mode=default"
    "fsync_mode=posix"
  ];

  boot.resumeDevice = "/dev/disk/by-label/swap";
  swapDevices = [ { device = config.boot.resumeDevice; } ];
}
