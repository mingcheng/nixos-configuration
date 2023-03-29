# File: docker.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Wednesday, March 29th 2023, 12:06:28 pm
# Last Modified: Wednesday, March 29th 2023, 12:06:55 pm
#
# https://opensource.org/licenses/MIT

{ config, lib, modulesPath, pkgs, ... }: {
  virtualisation.docker.daemon.settings = lib.mkForce {
    "debug" = true;
    "experimental" = true;
    "features" = { "buildkit" = true; };
    "exec-opts" = [ "native.cgroupdriver=systemd" ];
    "hosts" = [ "tcp://0.0.0.0:2375" "unix:///var/run/docker.sock" ];
    "registry-mirrors" = [
      "https://053a453cb38026130fb6c00bb532d7c0.mirror.swr.myhuaweicloud.com"
      "https://bobm60dq.mirror.aliyuncs.com"
    ];

    "insecure-registries" = [ "localhost:5000" ];
  };
}
