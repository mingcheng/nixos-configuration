{ config, lib, ... }:
let
  swaps = config.swapDevices;
in
{
  boot.resumeDevice =
    if
      builtins.length swaps == 1
      && lib.hasPrefix "/dev/" (builtins.head swaps).device
      && !(builtins.head swaps).randomEncryption.enable
    then
      (builtins.head swaps).device
    else
      throw "Hibernation requires exactly one swap partition under /dev/ without random encryption, defined in hardware-configuration.nix.";
}
