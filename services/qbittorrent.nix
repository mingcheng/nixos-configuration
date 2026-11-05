# File: qbittorrent.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Wednesday, August 17th 2022, 4:20:31 pm
# Last Modified: Wednesday, August 17th 2022, 4:20:32 pm
#
# http://www.opensource.org/licenses/MIT
{ lib, ... }: {
  services.qbittorrent = {
    enable = true;
    user = lib.mkDefault "mingcheng";
    group = lib.mkDefault "users";
    profileDir = lib.mkDefault "/data/qbittorrent";
    webuiPort = lib.mkDefault 8080;
  };
}
