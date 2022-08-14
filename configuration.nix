{ config, lib, modulesPath, ... }: {
  system.stateVersion = "22.05"; # Did you read the comment?

  #  imports = [ ./machines/farlion.nix ];
  imports = [ ./machines/chartman.nix ];
}
