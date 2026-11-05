# File: postgresql.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Wednesday, August 17th 2022, 9:52:10 am
# Last Modified: Wednesday, August 17th 2022, 9:52:10 am
#
# http://www.opensource.org/licenses/MIT

{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    dataDir = "/data/postgresql";
  };
}
