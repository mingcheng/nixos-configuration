{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./hardware/cpu_intel.nix
    # ./hardware/fs.nix
    # ./hardware/kernel.nix
    ./hardware/power.nix
  ];
}
