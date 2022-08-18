# File: udev.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 11:09:16 am
# Last Modified: Thursday, August 18th 2022, 11:15:33 am
#
# http://www.opensource.org/licenses/MIT

{ lib, pkgs, ... }:
{
  # Required for Ledger Live to detect Ledger Nano S via USB
  # services.udev.extraRules = ''
  #   SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1b7c", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
  # '';

  # services.udev.extraRules = lib.mkDefault ''
  #   SUBSYSTEM=="pci", KERNEL=="0000:00:14.0", ATTR{power/wakeup}="disabled"
  # '';
}
