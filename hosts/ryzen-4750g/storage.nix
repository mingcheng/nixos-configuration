#!#
# Copyright (c) 2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: storage.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-16 21:50:58
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-16 21:50:58
##

{ lib, pkgs, ... }:
let
  homeSnapshots = "/home/.snapshots";
  btrbkSnapshots = "/home/.btrbk_snapshots";
  backupMount = "/mnt/backup";
  backupTarget = "${backupMount}/btrbk";
in
{
  fileSystems = {
    # Dedicated Micron 2200 NVMe holding the `@home` subvolume. The machine-local
    # hardware configuration supplies the UUID; the repository owns the mount tuning.
    "/home" = {
      device = lib.mkDefault "/dev/disk/by-label/home";
      fsType = "btrfs";
      options = lib.mkForce [
        "subvol=@home"
        "noatime"
        # Level 1 keeps NVMe throughput high while still saving space on source trees.
        "compress=zstd:1"
        "ssd"
        "discard=async"
        "space_cache=v2"
      ];
    };

    # Whole-disk btrfs on the 1 TB HDD; label it `backup` once. `nofail` keeps
    # boot working if the disk is absent, and btrbk then fails instead of writing to /.
    ${backupMount} = {
      device = lib.mkDefault "/dev/disk/by-label/backup";
      fsType = "btrfs";
      options = [
        "noatime"
        "compress=zstd:3"
        "space_cache=v2"
        "nofail"
        "x-systemd.device-timeout=10s"
      ];
    };
  };

  # Local, hourly rollback points for /home (protects against mistakes, not disk loss).
  services.snapper = {
    persistentTimer = true;
    configs.home = {
      SUBVOLUME = "/home";
      FSTYPE = "btrfs";
      ALLOW_USERS = [ "mingcheng" ];
      SYNC_ACL = true;
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 12;
      TIMELINE_LIMIT_DAILY = 7;
      TIMELINE_LIMIT_WEEKLY = 4;
      TIMELINE_LIMIT_MONTHLY = 6;
      TIMELINE_LIMIT_QUARTERLY = 0;
      TIMELINE_LIMIT_YEARLY = 0;
    };
  };

  # Daily incremental `btrfs send/receive` of /home to the HDD for disk-failure recovery.
  services.btrbk = {
    ioSchedulingClass = "idle";
    instances.home = {
      onCalendar = "daily";
      settings = {
        # Run as root without sudo: system/sudo.nix restricts sudo to wheel.
        backend = "btrfs-progs";
        timestamp_format = "long";
        # Keep only the latest local snapshot as the incremental parent.
        snapshot_create = "onchange";
        snapshot_preserve_min = "latest";
        snapshot_preserve = "no";
        target_preserve_min = "no";
        target_preserve = "14d 8w 12m";
        subvolume."/home" = {
          snapshot_dir = btrbkSnapshots;
          snapshot_name = "home";
          target = backupTarget;
        };
      };
    };
  };

  # Scrub both the source and the backup disk to detect silent corruption.
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [
      "/home"
      backupMount
    ];
  };

  systemd.services = {
    # tmpfiles `v` only creates subvolumes when / is btrfs, but / is F2FS here.
    home-snapshot-dirs = {
      description = "Create /home snapshot subvolume and btrbk snapshot directory";
      unitConfig.RequiresMountsFor = [ "/home" ];
      before = [
        "snapper-timeline.service"
        "snapper-cleanup.service"
        "btrbk-home.service"
      ];
      requiredBy = [
        "snapper-timeline.service"
        "snapper-cleanup.service"
        "btrbk-home.service"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        if [ ! -e ${homeSnapshots} ]; then
          ${pkgs.btrfs-progs}/bin/btrfs subvolume create ${homeSnapshots}
        fi
        chmod 0750 ${homeSnapshots}
        install -d -m 0700 ${btrbkSnapshots}
      '';
    };

    btrfs-scrub-mnt-backup.unitConfig.RequiresMountsFor = [ backupMount ];

    btrbk-home = {
      unitConfig.RequiresMountsFor = [
        "/home"
        backupMount
      ];
      serviceConfig = {
        User = lib.mkForce "root";
        Group = lib.mkForce "root";
        ExecStartPre = "${pkgs.coreutils}/bin/install -d -m 0700 ${backupTarget}";
      };
    };
  };
}
