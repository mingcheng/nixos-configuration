#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: kernel.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-04 11:15:44
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-06 22:28:44
##

{ pkgs, ... }: {
  boot = {
    # 6.18 is the newest upstream LTS branch (November 2026).
    # Follow its fixes from the stable channel, not linuxPackages_latest.
    kernelPackages = pkgs.linuxPackages_6_18;

    initrd = {
      systemd.enable = true;
      availableKernelModules = [ "thunderbolt" ];
      kernelModules = [
        "i915"
        "f2fs"
      ];
    };

    kernelModules = [
      "thinkpad_acpi"
      "f2fs"
    ];

    # X1 Carbon Gen 8 / Comet Lake-U: the Linux/S3 firmware setting exposes
    # "deep" and avoids s2idle battery drain; full preemption suits the Plasma
    # Wayland + PipeWire desktop; VT-d isolates Thunderbolt 3 DMA (bolt
    # authorises devices in userspace), it is not for GPU passthrough here;
    # disabling PSR avoids eDP flicker on the UHD GT2 panel.
    kernelParams = [
      "mem_sleep_default=deep"
      "preempt=full"
      "intel_iommu=on"
      "i915.enable_psr=0"
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
    # Comet Lake-U (06-8e-0c) needs updated microcode for the Spectre v2,
    # GDS, SRBDS and MMIO stale data mitigations; do not tie it to the
    # redistributable-firmware toggle.
    cpu.intel.updateMicrocode = true;
    # CNVi AX201 Wi-Fi 6 + Bluetooth use linux-firmware; cAVS audio uses SOF.
    bluetooth.enable = true;
    enableRedistributableFirmware = true;
    firmware = [ pkgs.sof-firmware ];
    graphics = {
      enable = true;
      extraPackages = [ pkgs.intel-media-driver ];
    };
  };

  services.fwupd.enable = true;
  services.hardware.bolt.enable = true;
}
