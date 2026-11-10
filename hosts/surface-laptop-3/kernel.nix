#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: kernel.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-10 11:40:39
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-10 11:40:39
##

{ lib, pkgs, ... }:
{
  boot = {
    # Use the pre-built 6.12 LTS kernel from the NixOS binary cache.
    # For Surface Laptop 3 (13.5" Intel Ice Lake i5-1035G7), all required
    # Surface System Aggregator Module (SAM) drivers for keyboard, touchpad,
    # battery, charger, sensors, platform profile, buttons, S0ix and UVC webcam
    # are upstream in Linux 5.13+ and enabled as modules in stock linuxPackages_6_12;
    # only IPTS touchscreen/pen requires out-of-tree linux-surface patches, which
    # we explicitly disable on this host.
    kernelPackages = pkgs.linuxPackages_6_12;

    # Surface Laptop 3 keyboards and touchpads attach behind SAM over UART/SPI;
    # include SAM modules in initrd so early boot prompts and recovery work.
    initrd = {
      systemd.enable = true;
      availableKernelModules = [
        "8250_dw"
        "intel_lpss"
        "intel_lpss_pci"
        "pinctrl_icelake"
        "spi_pxa2xx_platform"
        "surface_aggregator"
        "surface_aggregator_hub"
        "surface_aggregator_registry"
        "surface_hid"
        "surface_hid_core"
        "surface_kbd"
      ];
      kernelModules = [
        "i915"
        "f2fs"
      ];
    };

    kernelModules = [
      "f2fs"
      "surface_acpi_notify"
      "surface_battery"
      "surface_charger"
      "surface_fan"
      "surface_gpe"
      "surface_platform_profile"
      "surface_temp"
    ];

    # Keep touchscreen kernel modules blacklisted even if present in initrd/rootfs.
    blacklistedKernelModules = [
      "ipts"
      "ithc"
      "hid_multitouch"
    ];

    # Surface Laptop 3 (Ice Lake-U i5-1035G7 / Iris Plus G7): linux-surface
    # uses mem_sleep_default=deep to properly enter S0ix Modern Standby,
    # combined with suspend-then-hibernate from system/power.nix; disable PSR
    # to prevent panel stutter on Ice Lake eDP.
    kernelParams = [
      "mem_sleep_default=deep"
      "preempt=full"
      "intel_iommu=on"
      "i915.enable_psr=0"
      "selinux=0"
    ];

    kernel.sysctl = {
      "net.ipv6.conf.all.disable_ipv6" = 1;
    };
  };

  hardware = {
    # Ice Lake-U (06-7e-05) microcode updates for Spectre/GDS/MMIO mitigations.
    cpu.intel.updateMicrocode = true;
    # Intel AX201 CNVi Wi-Fi 6 + Bluetooth and Ice Lake SST/SOF audio.
    bluetooth.enable = true;
    enableRedistributableFirmware = true;
    firmware = [ pkgs.sof-firmware ];
    sensor.iio.enable = false;
    graphics = {
      enable = true;
      extraPackages = [ pkgs.intel-media-driver ];
    };
  };

  # Ignore any touchscreen input devices exposed over generic HID.
  services.udev = {
    packages = [ pkgs.surface-control ];
    extraRules = ''
      SUBSYSTEM=="input", ENV{ID_INPUT_TOUCHSCREEN}=="1", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    '';
  };

  environment.systemPackages = [ pkgs.surface-control ];

  services.fwupd.enable = true;
  services.iptsd.enable = lib.mkForce false;
}
