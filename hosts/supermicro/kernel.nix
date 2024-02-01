{ config, lib, pkgs, ... }: {
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_1;
  boot.kernel = {
    sysctl = {
      "net.ipv6.conf.all.disable_ipv6" = 1;
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "vm.swappiness" = 1;
    };
  };

  boot.kernelParams = [
    "verbose"
    "nohibernate"
    "fsck.mode=force"
    "fsck.fix=yes"
    "fsck.repair=yes"
    "pcie_aspm=off"
    "intremap=off"
    "selinux=0"
    "intel_iommu=on"
    "iommu=pt"
    "vfio_iommu_type1.allow_unsafe_interrupts=1"
    # lspci -nn | grep -i Ether
    "vfio-pci.ids=8086:1533,8086:a352"
    "mitigations=off"
  ];

  boot.kernelModules = [
    "ipmi_devintf"
    "ipmi_si"
    "kvm-intel"
    "vfio_virqfd"
    "vfio_pci"
    "vfio_iommu_type1"
    "vfio"
    "virtio_blk"
  ];
}
