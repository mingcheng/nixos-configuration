{ config, lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ bind inetutils netcat-gnu ];
}
