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

    # Surface Laptop 3 keyboards and touchpads attach behind SAM over UART/SPI
    # (surface_hid on SL3+, unlike surface_kbd on SL1/2); include SAM and LPSS
    # modules in initrd so early boot prompts and recovery work.
    initrd = {
      systemd.enable = true;
      availableKernelModules = [
        "8250_dw"
        "hid_multitouch"
        "intel_lpss"
        "intel_lpss_pci"
        "pinctrl_icelake"
        "spi_pxa2xx_platform"
        "surface_aggregator"
        "surface_aggregator_hub"
        "surface_aggregator_registry"
        "surface_hid"
        "surface_hid_core"
      ];
      kernelModules = [
        "i915"
        "f2fs"
      ];
    };

    kernelModules = [
      "f2fs"
      "hid_multitouch"
      "surface_acpi_notify"
      "surface_aggregator_cdev"
      "surface_battery"
      "surface_charger"
      "surface_fan"
      "surface_gpe"
      "surface_platform_profile"
      "surface_temp"
    ];

    # Keep touchscreen/stylus modules blacklisted even if present in initrd/rootfs.
    # Do not blacklist hid_multitouch (required by the 045e:09af Precision Touchpad)
    # or surface_gpe (required to arm the ACPI lid GPE for s2idle wakeup).
    blacklistedKernelModules = [
      "ipts"
      "ithc"
    ];

    # Surface Laptop 3 (Ice Lake-U i5-1035G7 / Iris Plus G7): firmware only
    # exposes S0ix Modern Standby (s2idle), combined with suspend-then-hibernate
    # from system/power.nix; disable PSR to prevent panel stutter on Ice Lake eDP.
    kernelParams = [
      "mem_sleep_default=s2idle"
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

  # Ignore any touchscreen or stylus/pen input devices exposed over generic HID.
  services.udev = {
    packages = [ pkgs.surface-control ];
    extraRules = ''
      SUBSYSTEM=="input", ENV{ID_INPUT_TOUCHSCREEN}=="1", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      SUBSYSTEM=="input", ENV{ID_INPUT_TABLET}=="1", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    '';
  };

  environment.systemPackages = [ pkgs.surface-control ];

  services.fwupd.enable = true;
  services.iptsd.enable = lib.mkForce false;
}
