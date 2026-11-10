#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: tuning.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-10 11:40:39
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-10 11:40:39
##

{ lib, ... }:
{
  # Surface Laptop 3 (13.5" Intel): i5-1035G7 (4C/8T, 15 W Ice Lake), 8 GiB LPDDR4x,
  # 256 GiB NVMe, Iris Plus G7, AX201 Wi-Fi 6.
  # Keep thermald enabled for Ice Lake passive RAPL throttling and PPD for
  # surface_platform_profile + intel_pstate HWP; keep TLP disabled per linux-surface.
  services.tlp.enable = lib.mkForce false;

  # On an 8 GiB system, allocate 50% (~4 GiB logical) zstd compressed RAM swap
  # ahead of the NVMe hibernation swap partition to absorb desktop + browser spikes.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  # Prefer swapping cold anonymous pages into zram before reclaiming file cache,
  # disable multi-page swap readahead on zram, and bound dirty writeback spikes
  # on the 256 GiB NVMe SSD.
  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.page-cluster" = 0;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
  };

  # Bound local Nix build concurrency for an 8 GiB RAM / 4C8T 15 W ultrabook
  # so compiling or evaluating derivations does not trigger OOM pressure.
  nix.settings = {
    max-jobs = lib.mkDefault 1;
    cores = lib.mkDefault 4;
  };
}
