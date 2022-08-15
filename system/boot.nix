{ pkgs, lib, ... }: {
  boot = {
    plymouth.enable = false;

    loader = {
      timeout = 3;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        # memtest86.enable = true;
      };
    };
    supportedFilesystems = lib.mkForce [ "btrfs" "ext4" "vfat" "f2fs" ];

    initrd = {
      availableKernelModules = [ "f2fs" "ext4" "btrfs" "nvme" "vfat" ];
    };
    extraModulePackages = [ ];
  };
}
