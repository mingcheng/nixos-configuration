/*
  * File: docker.nix
  * Author: Ming Cheng<mingcheng@outlook.com>
  * 
  * Created Date: Monday, August 15th 2022, 10:59:12 am
  * Last Modified: Monday, August 15th 2022, 10:36:38 pm
  * 
  * http://www.opensource.org/licenses/MIT
*/

{ pkgs, ... }: {
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      "debug" = false;
      "experimental" = false;
      "exec-opts" = [ "native.cgroupdriver=systemd" ];
      "registry-mirrors" = [
        "https://053a453cb38026130fb6c00bb532d7c0.mirror.swr.myhuaweicloud.com"
        "https://bobm60dq.mirror.aliyuncs.com"
      ];
      "insecure-registries" = [
        "localhost:5000"
      ];
    };
    autoPrune = {
      enable = true;
      flags = [ "--all" ];
    };
    liveRestore = false;
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
