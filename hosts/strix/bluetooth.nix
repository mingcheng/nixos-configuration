{ config, lib, modulesPath, pkgs, ... }: {
  hardware.bluetooth.enable = false;
  services.blueman.enable = false;
  environment.systemPackages = with pkgs; [ bluez ];
}
