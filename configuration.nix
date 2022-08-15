{ config, lib, modulesPath, ... }: {
  system.stateVersion = "22.05"; # Did you read the comment?

  # WARNING! CHANGE IT BEFORE DEPLOYING IN PRODECT
  users.extraUsers.root.password = "root";

  imports = [ ./machines/farlion.nix ];
  #imports = [ ./machines/chartman.nix ];
  #imports = [ ./machines/qemu.nix ];
}
