#!#
# Copyright (c) 2026 mingcheng
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: power.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-04 11:02:22
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-04 15:13:46
##

{ config, lib, ... }:
let
  sleep = config.systemd.sleep.settings.Sleep;
  upower = config.services.upower;
  lidAction = if sleep.AllowSuspendThenHibernate then "suspend-then-hibernate" else "suspend";
in
{
  powerManagement.enable = lib.mkDefault true;

  services = {
    power-profiles-daemon.enable = lib.mkDefault true;
    thermald.enable = lib.mkDefault true;

    upower = {
      enable = lib.mkDefault true;
      usePercentageForPolicy = lib.mkDefault true;
      percentageLow = lib.mkDefault 20;
      percentageCritical = lib.mkDefault 10;
      percentageAction = lib.mkDefault 7;
      criticalPowerAction = lib.mkDefault "Hibernate";
    };

    # Plasma handles these events while its power manager is running.
    logind.settings.Login = {
      HandleLidSwitch = lib.mkDefault lidAction;
      HandleLidSwitchExternalPower = lib.mkDefault lidAction;
      HandleLidSwitchDocked = lib.mkDefault "ignore";
    };
  };

  systemd.sleep.settings.Sleep = {
    AllowSuspend = lib.mkDefault true;
    AllowHibernation = lib.mkDefault true;
    AllowSuspendThenHibernate = lib.mkDefault true;
    HibernateDelaySec = lib.mkDefault "2h";
    HibernateOnACPower = lib.mkDefault false;
  };

  # KConfig system defaults are overridable by each user's powerdevilrc.
  environment.etc."xdg/powerdevilrc" =
    lib.mkIf
      (
        config.services.desktopManager.plasma6.enable
        && sleep.AllowHibernation
        && sleep.AllowSuspendThenHibernate
        && upower.enable
      )
      {
        text = ''
          [BatteryManagement]
          BatteryLowLevel=${toString upower.percentageLow}
          BatteryCriticalLevel=${toString upower.percentageCritical}
          BatteryCriticalAction=2

          [AC][SuspendAndShutdown]
          SleepMode=3

          [Battery][SuspendAndShutdown]
          SleepMode=3

          [LowBattery][SuspendAndShutdown]
          SleepMode=3
        '';
      };
}
