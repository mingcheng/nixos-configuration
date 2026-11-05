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
# Last Modified: 2026-11-05 11:24:18
##

{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;

    fontDir.enable = true;
    packages = with pkgs; [
      # Desktop and programming fonts.
      adwaita-fonts
      source-code-pro
      hack-font
      jetbrains-mono
      maple-mono.variable

      # Chinese coverage and emoji fallback.
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      source-han-sans
      source-han-serif
      sarasa-gothic

      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
    ];

    # These are font family names, not Nix package names. Order is significant.
    fontconfig.defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [
        "Noto Sans Mono CJK SC"
        "Sarasa Mono SC"
        "DejaVu Sans Mono"
      ];
      sansSerif = [
        "Noto Sans CJK SC"
        "Source Han Sans SC"
        "DejaVu Sans"
      ];
      serif = [
        "Noto Serif CJK SC"
        "Source Han Serif SC"
        "DejaVu Serif"
      ];
    };
  };
}
