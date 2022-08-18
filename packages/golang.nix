# File: golang.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 10:53:42 pm
# Last Modified: Monday, August 15th 2022, 10:36:15 pm
#
# http://www.opensource.org/licenses/MIT

{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ gnumake go ];
}
