# File: cpu_intel.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 11:05:23 am
# Last Modified: Thursday, August 18th 2022, 11:05:25 am
#
# http://www.opensource.org/licenses/MIT

{
  config,
  lib,
  ...
}:
{
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
