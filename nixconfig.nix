/*
  * File: nixconfig.nix
  * Author: Ming Cheng<mingcheng@outlook.com>
  * 
  * Created Date: Sunday, August 14th 2022, 9:45:39 pm
  * Last Modified: Monday, August 15th 2022, 11:44:22 am
  * 
  * http://www.opensource.org/licenses/MIT
*/

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
