{ config, lib, pkgs, ... }: {
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
    #"acpi=off"
    #"acpi_enforce_resources=lax"
    #"amd_iommu=on"
    "audit=0"
    "fsck.fix=yes"
    "fsck.mode=force"
    "fsck.repair=yes"
    "intremap=off"
    "iommu=pt"
    "loglevel=3"
    "nomodeset"
    #"pcie_aspm.policy=performance"
    #"processor.max_cstate=1"
    "selinux=0"
    "verbose"
    #"rtw88_pci.disable_aspm=true"
    #"rtw88_core.lps_deep_mode=0"
    #"module_blacklist=snd,nvidia"
    #"iwlmvm.power_scheme=1"
    "iwlwifi.swcrypto=0"
    "iwlwifi.power_save=0"
  ];

  #boot.blacklistedKernelModules = [ "snd_pcsp" ];
  # https://github.com/NixOS/nixos-hardware/blob/master/common/cpu/amd/default.nix
  #boot.initrd.kernelModules = [ "amdgpu" "amd-pstate" "asus_wmi" "kvm_amd" ];
  boot.initrd.kernelModules = [ "amdgpu" "asus_wmi" "kvm_amd" ];

  boot.extraModprobeConfig = ''
    blacklist snd
    options iwlmvm power_scheme=1
    options iwlwifi power_save=0 swcrypto=0
  '';

  hardware.enableRedistributableFirmware = true;

  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
    amdvlk
  ];

  hardware.opengl = { driSupport = lib.mkDefault true; };

  environment.variables.AMD_VULKAN_ICD = lib.mkDefault "RADV";
}
