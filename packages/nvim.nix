/*
  * File: nvim.nix
  * Author: Ming Cheng<mingcheng@outlook.com>
  * 
  * Created Date: Sunday, August 14th 2022, 9:45:39 pm
  * Last Modified: Monday, August 15th 2022, 10:30:15 pm
  * 
  * http://www.opensource.org/licenses/MIT
*/

{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    configure = {
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ fugitive vim-nix ];
      };
    };
  };
}
