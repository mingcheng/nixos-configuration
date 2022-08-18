# File: nanopc-t4.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Monday, August 15th 2022, 2:24:42 pm
# Last Modified: Monday, August 15th 2022, 2:24:43 pm
#
# http://www.opensource.org/licenses/MIT

# https://github.com/NixOS/nixos-hardware/tree/master/friendlyarm/nanopc-t4
# ref https://github.com/NixOS/nixos-hardware/blob/master/friendlyarm/nanopc-t4/default.nix

# imports = [ (modulesPath + "/nixos-hardware/friendlyarm/nanopc-t4/default.nix") ];

{ config, pkgs, lib, ... }: {
  imports = [
    <nixos-hardware/friendlyarm/nanopc-t4>

    ../../system/i18n.nix
    ../../system/networking.nix
    ../../system/sudo.nix
    ../../system/user.nix

    ../../services/openssh.nix
    ../../services/docker.nix

    ../farlion/packages.nix
    ../../packages/kubectl.nix
  ];

  boot.kernel = {
    sysctl = {
      "net.ipv6.conf.all.disable_ipv6" = 1;
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "vm.swappiness" = 1;
      "vm.overcommit_memory" = 0;
      "vm.panic_on_oom" = 0;
    };
  };

  boot.kernelParams = lib.mkDefault [
    "verbose"
    "console=ttyS2,1500000"
    "fsck.mode=force"
    "fsck.fix=yes"
    "fsck.repair=yes"
    "selinux=0"
  ];

  boot.kernelModules = [ "btrfs" "vfat" "ext4" ];

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nix";
    fsType = "btrfs";
    neededForBoot = true;
    options = [ "defaults" "subvol=@nix" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/nix";
    fsType = "btrfs";
    neededForBoot = true;
    options = [ "defaults" "subvol=@home" ];
  };

  # boot.growPartition = true;
  boot.loader.grub.device = "/dev/vda";
  boot.initrd = {
    availableKernelModules = [ "f2fs" "ext4" "btrfs" "nvme" "vfat" ];
  };

  boot.loader.timeout = 0;
}
