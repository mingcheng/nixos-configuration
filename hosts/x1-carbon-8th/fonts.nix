{ pkgs, ... }:
{
  fonts = {
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
      noto-fonts-color-emoji
      source-han-sans
      source-han-serif
      sarasa-gothic
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
