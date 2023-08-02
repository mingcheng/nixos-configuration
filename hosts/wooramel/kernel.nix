# File: kernel.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Monday, August 22nd 2022, 2:21:03 pm
# Last Modified: Monday, August 22nd 2022, 2:21:04 pm
#
# http://www.opensource.org/licenses/MIT

{ config, lib, pkgs, ... }: {
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_5_10;
  #lib.mkForce config.boot.zfs.package.latestCompatibleLinuxPackages;

  boot.kernel = {
    sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.disable_ipv6" = 1;
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "vm.swappiness" = 1;
      "vm.overcommit_memory" = 0;
      "vm.panic_on_oom" = 1;
    };
  };

  boot.kernelParams = [
    "verbose"
    #"nohibernate"
    "fsck.mode=force"
    "fsck.fix=yes"
    "fsck.repair=yes"
    "pcie_aspm=off"
    #"acpi_enforce_resources=lax"
    "intremap=off"
    "selinux=0"
  ];

  boot.supportedFilesystems = lib.mkForce [ "zfs" "f2fs" "vfat" "nfs" ];
}
