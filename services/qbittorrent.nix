# File: qbittorrent.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Wednesday, August 17th 2022, 4:20:31 pm
# Last Modified: Wednesday, August 17th 2022, 4:20:32 pm
#
# http://www.opensource.org/licenses/MIT
{ pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [ qbittorrent-nox ];

  # add and enable systemd unit
  systemd = {
    packages = [ pkgs.qbittorrent-nox ];

    services."qbittorrent-nox@mingcheng" = {
      enable = true;
      serviceConfig = {
        Type = "simple";
        User = "mingcheng";
        ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --webui-port=8080 --profile=/data/qbittorrent";
      };
      wantedBy = [ "network-online.target" ];
    };
  };
}
