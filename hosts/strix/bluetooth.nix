{ config, lib, modulesPath, pkgs, ... }: {
  services.blueman.enable = true;
  environment.systemPackages = with pkgs; [ bluez ];
}
