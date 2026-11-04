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
  boot = {
    initrd = {
      systemd.enable = true;
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ "i915" ];
    };

    kernelModules = [
      "kvm-intel"
      "thinkpad_acpi"
    ];

    # Select Linux/S3 sleep in the firmware to expose the deep sleep state.
    kernelParams = [ "mem_sleep_default=deep" ];
  };

  hardware = {
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
