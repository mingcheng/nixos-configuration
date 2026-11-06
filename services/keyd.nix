#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: keyd.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 1970-01-01 08:00:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-06 22:47:26
##

{ lib, ... }:
let
  commonSettings = {
    main.capslock = "overload(caps_control, esc)";

    # Remap navigation only while holding Caps Lock; physical Ctrl is unchanged.
    "caps_control:C" = {
      b = "left";
      e = "end";
      f = "right";
      n = "down";
      p = "up";
    };
  };
in
{
  services.keyd = {
    enable = true;
    keyboards = {
      "0001-0001" = {
        ids = [
          "0001:0001"
          "1fc9:e8d8"
        ];
        settings = commonSettings;
      };
      "0fac-0ade" = {
        ids = [
          "3151:4003"
          "0fac:0ade"
        ];
        settings = lib.recursiveUpdate commonSettings {
          main = {
            leftalt = "layer(meta)";
            rightalt = "rightmeta";
            leftmeta = "layer(alt)";
            rightmeta = "layer(altgr)";
          };
        };
      };
    };
  };
}
