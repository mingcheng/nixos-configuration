#!#
# Copyright (c) 2026 mingcheng
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: kernel.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-04 11:15:44
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-04 11:55:59
##

{ pkgs, ... }: {
  imports = [ ../../system/kernel.nix ];

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

    # Select Linux/S3 sleep in the firmware to expose the deep sleep state.
    kernelParams = [
      "mem_sleep_default=deep"
      "verbose"
      "fsck.mode=force"
      "fsck.fix=yes"
      "fsck.repair=yes"
      "selinux=0"
    ];

    kernel.sysctl = {
      "net.ipv6.conf.all.disable_ipv6" = 1;
    };
  };

  hardware = {
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
