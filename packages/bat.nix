{ config, pkgs, ... }: {
  programs.bat = {
    config = { theme = "ansi-dark"; };
    enable = true;
  };
}
