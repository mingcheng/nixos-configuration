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
# Last Modified: 2026-11-14 08:14:05
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
      # Bit 9 (0x200) lets SMU7 control clock gating; preserve the other bits.
      "amdgpu.ppfeaturemask=0xfff5baf3"
      # Bypass soft recovery and select PCI CONFIG reset instead of BACO.
      "amdgpu.debug_mask=0x4"
      "amdgpu.reset_method=0"
      # Allow long compute dispatches on Polaris' non-preemptible GFX ring.
      "amdgpu.lockup_timeout=60000,60000,10000,10000"
    ];

    kernel.sysctl = {
      "net.ipv6.conf.all.disable_ipv6" = 1;
    };
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
