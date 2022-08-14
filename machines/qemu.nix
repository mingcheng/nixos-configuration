{ config, pkgs, lib, ... }: {
  imports = [
    ../system/i18n.nix
    ../system/networking.nix
    ../system/sudo.nix
    ../system/user.nix
    ../services/openssh.nix
  ];

  users.extraUsers.root.password = "";
  system.stateVersion = "22.05"; # Did you read the comment?
}
