#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: pipewire.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 1970-01-01 08:00:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-05 13:14:01
##

{
  services = {
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
  };
}
