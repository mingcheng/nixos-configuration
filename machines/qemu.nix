{ config, pkgs, lib, ... }: {
  imports = [
    ../system/i18n.nix
    ../system/networking.nix
    ../system/sudo.nix
    ../system/user.nix
    ../services/openssh.nix
  ];
}
