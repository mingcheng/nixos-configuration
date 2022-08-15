{ config, lib, pkgs, ... }: {
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

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

  boot.kernelParams = [
    "verbose"
    "fsck.mode=force"
    "fsck.fix=yes"
    "fsck.repair=yes"
    "pcie_aspm=off"
    "acpi_enforce_resources=lax"
    "selinux=0"
  ];

  boot.kernelModules = [

  ];
}
