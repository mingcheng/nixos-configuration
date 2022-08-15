{ config, pkgs, ... }: {
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
