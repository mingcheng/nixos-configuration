# File: nixconfig.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 9:45:39 pm
# Last Modified: Monday, August 15th 2022, 11:44:22 am
#
# http://www.opensource.org/licenses/MIT

{ ... }: {
  nix = {
    settings = {
      # https://nixos.wiki/wiki/Storage_optimization
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      keep-derivations = true;
      keep-outputs = true;
      substituters = [
        "https://mirrors.cernet.edu.cn/nix-channels/store"
      ];
      trusted-users = [ "root" "@wheel" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config.allowUnfree = true;
}
