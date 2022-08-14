{ config, lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    kubectl
    k9s
    cri-tools
    kubernetes-helm
  ];
}
