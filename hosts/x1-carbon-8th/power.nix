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
# Last Modified: 2026-11-04 11:55:32
##

{ ... }: {
  powerManagement.enable = true;

  services = {
    power-profiles-daemon.enable = true;
    thermald.enable = true;

    # Plasma handles these events while its power manager is running.
    logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchDocked = "ignore";
    };
  };

  systemd.sleep.settings.Sleep = {
    AllowSuspend = true;
    AllowHibernation = true;
    AllowSuspendThenHibernate = true;
    HibernateDelaySec = "2h";
  };
}
