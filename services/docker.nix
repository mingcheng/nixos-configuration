# File: docker.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Monday, August 15th 2022, 10:59:12 am
# Last Modified: Monday, August 15th 2022, 10:36:38 pm
#
# http://www.opensource.org/licenses/MIT

{ pkgs, ... }: {
  # https://iq.opengenus.org/failed-to-solve-with-frontend-dockerfile-v0/
  environment.variables = {
    DOCKER_BUILDKIT = "0";
    COMPOSE_DOCKER_CLI_BUILD = "0";
  };

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      "debug" = false;
      "experimental" = false;
      "features" = { "buildkit" = false; };
      "exec-opts" = [ "native.cgroupdriver=systemd" ];
      #"registry-mirrors" = [ "https://bobm60dq.mirror.aliyuncs.com" ];
      #"insecure-registries" = [ "localhost:5000" ];
    };
    autoPrune = {
      enable = true;
      flags = [ "--all" ];
    };
    liveRestore = false;
  };

  environment.systemPackages = with pkgs; [ docker-compose minikube ];
}
