{ config, lib, modulesPath, pkgs, ... }: {
  hardware.bluetooth.enable = true;
  services.blueman.enable = false;
  environment.systemPackages = with pkgs; [ bluez ];
}
