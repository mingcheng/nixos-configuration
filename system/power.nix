# File: power.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 11:09:16 am
# Last Modified: Thursday, August 18th 2022, 11:15:04 am
#
# http://www.opensource.org/licenses/MIT

{ config, lib, ... }: {
  powerManagement = {
    enable = true;

    # This will save you money and possibly your life!
    # cpuFreqGovernor = lib.mkDefault "powersave";
    cpuFreqGovernor = lib.mkDefault "performance";
  };
}
