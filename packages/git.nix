/*
  * File: git.nix
  * Author: Ming Cheng<mingcheng@outlook.com>
  * 
  * Created Date: Sunday, August 14th 2022, 9:45:39 pm
  * Last Modified: Monday, August 15th 2022, 11:45:02 am
  * 
  * http://www.opensource.org/licenses/MIT
*/

{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    config = {
      aliases = {
        c = "commit";
        p = "push";
        st = "status";
      };

      pull = {
        ff = "only";
        rebase = true;
      };
      init = {
        defaultBranch = "main";
      };
      rebase = {
        autoStash = true;
        autoSquash = true;
      };

      # https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/javascript.section.md#git-protocol-error
      url = {
        "https://github.com" = {
          insteadOf = "git://github.com";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [ gitflow ];
}
