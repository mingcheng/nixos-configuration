{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  #boot.kernelPackages = lib.mkForce pkgs.linuxPackages_5_15;

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
    #"acpi_enforce_resources=lax"
    "amd_iommu=on"
    "audit=0"
    "fsck.fix=yes"
    "fsck.mode=force"
    "fsck.repair=yes"
    "intremap=off"
    "iommu=pt"
    "iwlwifi.power_save=0"
    "iwlwifi.swcrypto=0"
    "loglevel=3"
    "nofb"
    "nomodeset"
    "pcie_acs_override=downstream,multifunction"
    "selinux=0"
    "verbose"
    "vfio-pci.ids=1002:1636,1002:1637,1022:1639"
    "vfio_iommu_type1.allow_unsafe_interrupts=1"
    "video=efifb:off"
    "kvm.ignore_msrs=1"
  ];

  boot.blacklistedKernelModules = [
    "snd_pcsp"
    "snd_hda_intel"
    "amdgpu"
    "amdkfd"
  ];
  # https://github.com/NixOS/nixos-hardware/blob/master/common/cpu/amd/default.nix
  boot.initrd.kernelModules = [
    "amd-pstate"
    "asus_wmi"
    "kvm_amd"
  ];

  boot.extraModprobeConfig = ''
    blacklist snd
    options iwlmvm power_scheme=1
    options iwlwifi power_save=0 swcrypto=0
  '';

  hardware.enableRedistributableFirmware = true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.graphics = {
    enable = lib.mkDefault true;
    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
      amdvlk
    ];
  };

  environment.variables.AMD_VULKAN_ICD = lib.mkDefault "RADV";
}
