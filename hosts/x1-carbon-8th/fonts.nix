#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: fonts.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 1970-01-01 08:00:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-06 16:16:13
##

{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;

    fontDir.enable = true;
    packages = with pkgs; [
      # Desktop and programming fonts.
      adwaita-fonts
      inter
      source-sans
      source-serif
      source-code-pro
      hack-font
      jetbrains-mono
      maple-mono.variable

      # Metric-compatible alternatives to Calibri and Cambria.
      carlito
      caladea

      # Chinese coverage and emoji fallback.
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      source-han-sans
      source-han-serif
      sarasa-gothic
      lxgw-wenkai
      lxgw-wenkai-tc
      lxgw-neoxihei
      babelstone-han

      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
    ];

    fontconfig.enable = true;
    fontconfig.antialias = true;
    fontconfig.hinting = {
      enable = true;
      style = "slight";
    };
    # Avoid assuming the same subpixel layout on internal and external displays.
    fontconfig.subpixel.rgba = "none";
    fontconfig.useEmbeddedBitmaps = false;

    # These are font family names, not Nix package names. Order is significant.
    fontconfig.defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [
        "Noto Sans Mono CJK SC"
        "DejaVu Sans Mono"
        "Noto Color Emoji"
      ];
      sansSerif = [
        "Noto Sans CJK SC"
        "DejaVu Sans"
        "Noto Color Emoji"
      ];
      serif = [
        "Noto Serif CJK SC"
        "DejaVu Serif"
        "Noto Color Emoji"
      ];
    };
  };
}
