{ config, pkgs, lib, ... }: {
  nix = {
    settings = {
      auto-optimise-store = true;
      substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"

      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    settings.trusted-users = [ "root" "@wheel" ];
  };

  nixpkgs.config = {
    allowUnfree = false;
    allowAliases = true;
  };

}
