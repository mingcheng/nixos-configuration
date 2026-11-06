#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: tuning.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 1970-01-01 08:00:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-06 17:33:05
##

{ lib, ... }:
{
  # X1 Carbon Gen 8: i7-10510U (4C/8T, 15 W), 16 GiB RAM, WD SN750 NVMe
  # with F2FS root, UHD GT2, AX201 CNVi Wi-Fi 6, JHL6540 TB3, cAVS/SOF.
  # PPD already controls intel_pstate/HWP and ThinkPad platform_profile.
  # Do not add TLP/tuned or force a governor/EPP that competes with Plasma.
  # Thermald exits on this machine because thinkpad_acpi/dytc_lapmode is
  # present; respect its compatibility check instead of forcing it to run.
  services.thermald.enable = lib.mkForce false;

  # About 4 GiB logical compressed swap, allocated on demand, ahead of NVMe.
  # Keep the existing 16.9 GiB disk swap and boot.resumeDevice for hibernation.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
    priority = 100;
  };

  # zram is RAM-backed and outranks the NVMe swap, so let anonymous pages go
  # there first instead of reclaiming F2FS file pages, and disable the 8-page
  # swap readahead that only wastes decompression work. Smaller dirty ratios
  # keep SN750 writeback smooth instead of stalling on ~3 GiB of dirty pages.
  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.page-cluster" = 0;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
  };

  # Bound local build pressure on a 15 W CPU / 16 GiB desktop. These are
  # scheduling hints, not hard CPU or memory limits; retain binary substitutes.
  nix.settings = {
    max-jobs = lib.mkDefault 2;
    cores = lib.mkDefault 4;
  };
}
