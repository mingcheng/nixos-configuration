# File: postgresql.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Wednesday, August 17th 2022, 9:52:10 am
# Last Modified: Wednesday, August 17th 2022, 9:52:10 am
#
# http://www.opensource.org/licenses/MIT

{ pkgs, lib, ... }: {
  #  https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/databases/postgresql.nix
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    enableTCPIP = true;

    dataDir = "/data/postgresql";
    settings.listen_addresses = lib.mkForce "192.168.0.11";
  };
}
