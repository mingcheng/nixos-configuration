# File: default.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Friday, August 26th 2022, 11:50:34 am
# Last Modified: Friday, August 26th 2022, 11:50:36 am
#
# http://www.opensource.org/licenses/MIT

{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../lenovo/default.nix
  ];

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_5_15;

  powerManagement = {
    enable = true;
    #cpuFreqGovernor = lib.mkForce "powersave";
    cpuFreqGovernor = lib.mkForce "performance";
  };

  networking.hostName = lib.mkForce "sharkbay";
  networking.interfaces."br0" = lib.mkForce {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "192.168.0.6";
        prefixLength = 23;
      }
    ];
  };

  networking.defaultGateway = "192.168.0.1";
  networking.nameservers = [ "192.168.0.1" ];
}
