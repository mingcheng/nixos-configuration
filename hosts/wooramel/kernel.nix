# File: kernel.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Monday, August 22nd 2022, 2:21:03 pm
# Last Modified: Monday, August 22nd 2022, 2:21:04 pm
#
# http://www.opensource.org/licenses/MIT

{ config, lib, pkgs, ... }: {
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_1;
  boot.kernel = {
    sysctl = {
      "net.ipv6.conf.all.disable_ipv6" = 1;
      "vm.swappiness" = 1;
    };
  };

  boot.kernelParams = [
    "verbose"
    "nohibernate"
    "fsck.mode=force"
    "fsck.fix=yes"
    "fsck.repair=yes"
  ];

  boot.supportedFilesystems = lib.mkForce [ "zfs" "ext4" "vfat" "nfs" ];
}
