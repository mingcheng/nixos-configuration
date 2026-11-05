#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: fprintd.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 1970-01-01 08:00:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-05 15:34:43
##

{ config, lib, ... }:
{
  options.security.pam.services = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        fprintAuth = lib.mkDefault false;
      }
    );
  };

  config = {
    services.fprintd.enable = true;

    security.pam.services = {
      login = {
        fprintAuth = true;
        allowNullPassword = lib.mkForce false;
      };

      sddm = lib.mkIf config.services.displayManager.sddm.enable {
        # SDDM delegates to login, so fprintAuth = false alone cannot bypass its fingerprint rule.
        # Copy resolved args, not settings, which would expand those arguments a second time.
        rules.auth =
          lib.mapAttrs (_: rule: {
            inherit (rule)
              enable
              order
              control
              modulePath
              args
              ;
          }) (builtins.removeAttrs config.security.pam.services.login.rules.auth [ "fprintd" ])
          // {
            login.enable = false;
          };
      };

      kde = lib.mkIf config.services.desktopManager.plasma6.enable {
        fprintAuth = false;
        allowNullPassword = lib.mkForce false;
      };

      kde-fingerprint = lib.mkIf config.services.desktopManager.plasma6.enable {
        fprintAuth = true;
      };
    };

    security.polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "net.reactivated.fprint.device.enroll") {
            if (!subject.local || !subject.active) {
              return polkit.Result.NO;
            }
            return polkit.Result.AUTH_ADMIN;
          }
        });
      '';
    };
  };
}
