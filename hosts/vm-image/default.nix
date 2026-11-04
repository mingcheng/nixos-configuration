# File: default.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Friday, August 26th 2022, 2:54:00 pm
# Last Modified: Friday, August 26th 2022, 3:03:24 pm
#
# http://www.opensource.org/licenses/MIT

{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{

  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./udev.nix
    ../../system/i18n.nix
    ../../system/networking.nix
    ../../system/sudo.nix
    ../../services/sshd.nix
  ];

  # WARNING! CHANGE IT BEFORE DEPLOYING IN PRODECT
  users.extraUsers.root.password = "root";

  #boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_6_6;
}
