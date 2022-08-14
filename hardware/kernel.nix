{ config, lib, pkgs, ... }: {
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

  boot.kernel = {
    sysctl = {
      "net.ipv4.ip_forward" = 1;
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
    "intremap=off"
    "selinux=0"
    "intel_iommu=on"
    "intel_iommu=igfx_off"
    "iommu=pt"
    "vfio_iommu_type1.allow_unsafe_interrupts=1"
    "vfio-pci.ids=8086:1533" # lspci -nn | grep -i Ether
  ];

  boot.kernelModules = [
    "kvm-intel"
    "vfio_virqfd"
    "vfio_pci"
    "vfio_iommu_type1"
    "vfio"
    "virtio_blk"
  ];
}
