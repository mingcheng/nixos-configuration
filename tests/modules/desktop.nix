let
  t = import ../lib.nix;
  inherit (t) lib pkgs;
  config = t.eval [
    ../../hosts/x1-carbon-8th/fonts.nix
    ../../hosts/x1-carbon-8th/input-method.nix
  ];
  inputMethod = config.i18n.inputMethod;
  rime = pkgs.fcitx5-rime.override { rimeDataPkgs = [ pkgs.rime-wanxiang ]; };
in
t.check "modules/desktop" {
  evaluates = t.validSystem config;
  input-method =
    inputMethod.enable && inputMethod.type == "fcitx5" && inputMethod.fcitx5.waylandFrontend;
  rime-schema = builtins.elem rime.outPath (map (package: package.outPath) inputMethod.fcitx5.addons);
  toolkit-integration =
    config.environment.sessionVariables.GTK_IM_MODULE == "fcitx"
    && config.environment.sessionVariables.QT_IM_MODULE == "fcitx"
    && config.environment.sessionVariables.XMODIFIERS == "@im=fcitx"
    && config.environment.sessionVariables.SDL_IM_MODULE == "fcitx";
  kwin-launcher =
    config.environment.etc."xdg/kwinrc".text == ''
      [Wayland]
      InputMethod=${inputMethod.package}/share/applications/org.fcitx.Fcitx5.desktop
      VirtualKeyboardEnabled=true
    '';
  no-duplicate-autostart =
    lib.hasInfix "Hidden=true"
      config.environment.etc."xdg/autostart/org.fcitx.Fcitx5.desktop".text;
  font-packages = t.hasPackages config.fonts.packages [
    "noto-fonts-cjk-sans"
    "noto-fonts-color-emoji"
  ];
  font-fallback-order =
    config.fonts.fontconfig.defaultFonts.monospace == [
      "Noto Sans Mono CJK SC"
      "Sarasa Mono SC"
      "DejaVu Sans Mono"
    ];
}
