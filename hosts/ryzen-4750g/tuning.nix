#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: tuning.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-09 18:26:43
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-09 18:26:43
##

{
  lib,
  pkgs,
  ...
}:
{
  # Ryzen 7 PRO 4750G (8C/16T, 65 W Renoir APU) + Radeon Pro WX 4100 (4 GiB GDDR5).
  # PPD drives amd-pstate-epp energy performance preference on Zen 2; thermald is
  # Intel-only and must stay disabled on AMD platforms.
  powerManagement.enable = true;
  services = {
    power-profiles-daemon.enable = true;
    thermald.enable = lib.mkForce false;
  };

  # Desktop sleeps to RAM without requiring a dedicated disk hibernation swap partition.
  systemd.sleep.settings.Sleep = {
    AllowSuspend = true;
    AllowHibernation = false;
    AllowSuspendThenHibernate = false;
  };

  # Compressed RAM swap allocated on demand; avoids disk swap wear and latency.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
    priority = 100;
  };

  # Prefer swapping cold anonymous pages into zram before evicting file cache,
  # disable multi-page swap readahead for zram, and bound dirty writeback spikes.
  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.page-cluster" = 0;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
  };

  # 8C/16T 65 W desktop envelope allows higher parallel Nix build concurrency than
  # a 15 W ultrabook while leaving headroom for interactive Plasma + VM workloads.
  nix.settings = {
    max-jobs = lib.mkDefault 4;
    cores = lib.mkDefault 8;
  };

  workstation.userPackages =
    with pkgs;
    lib.mkOrder 600 [
      amdgpu_top
      glmark2
      memtest_vulkan
      s-tui
      stress-ng
      vkmark
    ];
}
