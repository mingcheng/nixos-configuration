#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: kernel.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-09 18:26:43
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-09 18:26:43
##

{ pkgs, ... }:
{
  boot = {
    # 6.12 is the second-newest upstream LTS branch (November 2026).
    # Keep Renoir (Zen 2) and Polaris 11 (WX 4100) on this mature LTS branch.
    kernelPackages = pkgs.linuxPackages_6_12;

    initrd = {
      systemd.enable = true;
      kernelModules = [
        "amdgpu"
        "f2fs"
      ];
    };

    kernelModules = [
      "kvm-amd"
      "k10temp"
      "asus_wmi_sensors"
      "f2fs"
    ];

    # ROG STRIX B450-I GAMING exposes the generic ASUS WMI GUID, which otherwise
    # auto-loads the legacy Eee PC laptop hotkey stack (eeepc_wmi -> asus_wmi,
    # battery, i8042) with SFUN=0x0. The desktop board sensor driver
    # asus_wmi_sensors only depends on wmi and works independently.
    blacklistedKernelModules = [
      "eeepc_wmi"
      "asus_wmi"
    ];

    # ASUS ROG STRIX B450-I GAMING + Ryzen 7 PRO 4750G (Renoir APU) +
    # Radeon Pro WX 4100 (Polaris 11) + WD PC SN810 NVMe:
    # amd_pstate=active enables CPPC autonomous frequency scaling with EPP
    # hints driven by power-profiles-daemon; full preemption suits the Plasma
    # Wayland + PipeWire desktop; AMD-Vi initializes automatically from ACPI
    # IVRS (amd_iommu=on is not a valid kernel option) and iommu=pt avoids host
    # DMA translation overhead while keeping IOMMU groups ready for libvirt/KVM.
    # Disable PCIe ASPM globally across Renoir root ports and the B450 chipset,
    # cap NVMe APST latency at 20 ms on the WD PC SN810 (keeping 25 mW PS3 idle
    # while skipping the 49.6 ms PS4 state that triggers Replay Timer Timeouts
    # on 00:02.2), harden Polaris 11 against GFX ring/SMU hangs and BadTLP/BadDLLP
    # link glitches under sustained 3D load, and raise GFX ring lockup_timeout
    # to 60 s (matching Compute ring) so long Vulkan compute dispatches on RADV
    # Queue Family 0 do not trip false 10 s TDR resets on non-preemptible GFX8.
    kernelParams = [
      "amd_pstate=active"
      "preempt=full"
      "iommu=pt"
      "pcie_aspm=off"
      "nvme_core.default_ps_max_latency_us=20000"
      "amdgpu.aspm=0"
      "amdgpu.runpm=0"
      "amdgpu.bapm=0"
      "amdgpu.dcdebugmask=0x2"
      "amdgpu.ppfeaturemask=0xfff5baf3"
      "amdgpu.lockup_timeout=60000,60000,10000,10000"
      #"fsck.mode=force"
      #"fsck.fix=yes"
      #"fsck.repair=yes"
      "selinux=0"
    ];

    kernel.sysctl = {
      "net.ipv6.conf.all.disable_ipv6" = 1;
    };
  };

  hardware = {
    # Zen 2 (Renoir) needs updated AMD microcode for speculative execution
    # and Zenbleed (CVE-2023-20593) mitigations.
    cpu.amd.updateMicrocode = true;
    bluetooth.enable = true;
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  services.fwupd.enable = true;
}
