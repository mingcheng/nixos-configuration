#!#
# Copyright (c) 2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: kernel.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-09 18:26:43
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-16 21:48:35
##

{ pkgs, ... }:
{
  boot = {
    # Follow stable-channel fixes on the 6.18 LTS branch.
    kernelPackages = pkgs.linuxPackages_6_18;

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
    ];

    # Block the desktop board's misidentified laptop hotkey stack, not its sensors.
    blacklistedKernelModules = [
      "eeepc_wmi"
      "asus_wmi"
    ];

    kernelParams = [
      "amd_pstate=active"
      "preempt=full"
      "iommu=pt"
      # Retain the PCIe/NVMe baseline during the long-running stability test.
      "pcie_aspm=off"
      "nvme_core.default_ps_max_latency_us=20000"
      "amdgpu.aspm=0"
      "amdgpu.runpm=0"
      "amdgpu.dcdebugmask=0x2"
      # Keep MGCG/CGCG clock gating (0x1b6a05) for low idle power while disabling
      # all *_LS/*_CGLS SRAM light-sleep bits that lock up CP/RLC/SDMA/SMU7.
      "amdgpu.cg_mask=0x1b6a05"
      "amdgpu.ppfeaturemask=0xfff5baf3"
      # Bypass soft recovery livelocks; leave reset_method at default BACO so
      # runtime resets do not trigger a Renoir Data Fabric Sync Flood.
      "amdgpu.debug_mask=0x4"
      # Allow long compute dispatches on Polaris' non-preemptible GFX ring.
      "amdgpu.lockup_timeout=60000,60000,10000,10000"
    ];
  };

  hardware = {
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
