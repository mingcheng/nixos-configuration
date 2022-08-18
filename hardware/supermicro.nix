# File: supermicro.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Tuesday, August 16th 2022, 5:12:15 pm
# Last Modified: Tuesday, August 16th 2022, 5:12:15 pm
#
# http://www.opensource.org/licenses/MIT

# https://github.com/NixOS/nixos-hardware
{ pkgs, ... }: {
  boot.kernelModules = [ "ipmi_devintf" "ipmi_si" ];
  environment.systemPackages = [ pkgs.ipmitool ];
}
