{ config, pkgs, lib, ... }: {
  imports = [
    ./udev.nix
    ../../system/i18n.nix
    ../../system/networking.nix
    ../../system/sudo.nix
    ../../system/user.nix
    ../../services/openssh.nix
  ];
}
