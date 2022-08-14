{ pkgs, lib, ... }: {
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "f2fs";
    options = [
      "defaults"
      "relatime"
      "lazytime"
      "background_gc=on"
      "discard"
      "no_heap"
      "inline_xattr"
      "inline_data"
      "inline_dentry"
      "flush_merge"
      "extent_cache"
      "mode=adaptive"
      "active_logs=6"
      "alloc_mode=default"
      "fsync_mode=posix"
    ];
  };

  fileSystems."/efi" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
  };

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/efi";
  };
}
