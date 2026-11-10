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
      "f2fs"
    ];

    # Ryzen 7 PRO 4750G (Renoir APU) + Radeon Pro WX 4100 (Polaris 11):
    # amd_pstate=active enables CPPC autonomous frequency scaling with EPP
    # hints driven by power-profiles-daemon; full preemption suits the Plasma
    # Wayland + PipeWire desktop; AMD-Vi with passthrough avoids host DMA
    # translation overhead while keeping IOMMU groups ready for libvirt/KVM.
    kernelParams = [
      "amd_pstate=active"
      "preempt=full"
      "amd_iommu=on"
      "iommu=pt"
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
