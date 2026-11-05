{ pkgs, ... }:
{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      expat
      freeglut
      glib
      libcap
      libffi
      libxslt
      nghttp2
    ];
  };
}
