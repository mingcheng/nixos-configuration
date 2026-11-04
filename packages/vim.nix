# File: vim.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 9:45:39 pm
# Last Modified: Monday, August 15th 2022, 10:30:08 pm
#
# http://www.opensource.org/licenses/MIT

{ pkgs, ... }: {
  environment.variables = {
    EDITOR = "vim";
  };
  environment.systemPackages = with pkgs; [ vim ];
}
