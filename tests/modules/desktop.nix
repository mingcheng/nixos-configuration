let
  t = import ../lib.nix;
  inherit (t) lib pkgs;
  config = t.eval [
    ../../system/fonts.nix
    ../../system/input_method.nix
  ];
  plasma = t.eval [
    ../../system/input_method.nix
    { services.desktopManager.plasma6.enable = true; }
  ];
  nonWayland = t.eval [
    ../../system/input_method.nix
    {
      services.desktopManager.plasma6.enable = true;
      i18n.inputMethod.fcitx5.waylandFrontend = lib.mkForce false;
    }
  ];
  disabled = t.eval [
    ../../system/input_method.nix
    {
      services.desktopManager.plasma6.enable = true;
      i18n.inputMethod.enable = lib.mkForce false;
    }
  ];
  otherEngine = t.eval [
    ../../system/input_method.nix
    { i18n.inputMethod.type = lib.mkForce "ibus"; }
  ];
  inputMethod = config.i18n.inputMethod;
  rime = pkgs.fcitx5-rime.override { rimeDataPkgs = [ pkgs.rime-wanxiang ]; };
  noFcitxIntegration =
    cfg:
    !(cfg.environment.etc ? "xdg/kwinrc")
    && !(cfg.environment.etc ? "xdg/autostart/org.fcitx.Fcitx5.desktop");
  noFcitxVariables =
    cfg:
    lib.all (name: !(builtins.hasAttr name cfg.environment.sessionVariables)) [
      "GTK_IM_MODULE"
      "QT_IM_MODULE"
      "XMODIFIERS"
      "SDL_IM_MODULE"
    ];
in
t.check "modules/desktop" {
  evaluates = t.validSystem config;
  plasma-evaluates = t.validSystem plasma;
  non-wayland-evaluates = t.validSystem nonWayland;
  disabled-evaluates = t.validSystem disabled;
  other-engine-evaluates = t.validSystem otherEngine;
  input-method =
    inputMethod.enable && inputMethod.type == "fcitx5" && inputMethod.fcitx5.waylandFrontend;
  rime-schema = builtins.elem rime.outPath (map (package: package.outPath) inputMethod.fcitx5.addons);
  toolkit-integration =
    config.environment.sessionVariables.GTK_IM_MODULE == "fcitx"
    && config.environment.sessionVariables.QT_IM_MODULE == "fcitx"
    && config.environment.sessionVariables.XMODIFIERS == "@im=fcitx"
    && config.environment.sessionVariables.SDL_IM_MODULE == "fcitx";
  kwin-launcher =
    plasma.environment.etc."xdg/kwinrc".text == ''
      [Wayland]
      InputMethod=${plasma.i18n.inputMethod.package}/share/applications/org.fcitx.Fcitx5.desktop
      VirtualKeyboardEnabled=true
    '';
  no-duplicate-autostart =
    lib.hasInfix "Hidden=true"
      plasma.environment.etc."xdg/autostart/org.fcitx.Fcitx5.desktop".text;
  no-kwin-integration-without-plasma =
    !config.services.desktopManager.plasma6.enable && noFcitxIntegration config;
  no-kwin-integration-without-wayland =
    !nonWayland.i18n.inputMethod.fcitx5.waylandFrontend && noFcitxIntegration nonWayland;
  disabled-input-method-cleanup =
    !disabled.i18n.inputMethod.enable && noFcitxIntegration disabled && noFcitxVariables disabled;
  other-engine-cleanup =
    otherEngine.i18n.inputMethod.type == "ibus"
    && noFcitxIntegration otherEngine
    && noFcitxVariables otherEngine;
  font-packages = t.hasPackages config.fonts.packages [
    "noto-fonts-cjk-sans"
    "noto-fonts-color-emoji"
  ];
  font-fallback-order =
    config.fonts.fontconfig.defaultFonts.monospace == [
      "Noto Sans Mono CJK SC"
      "DejaVu Sans Mono"
      "Noto Color Emoji"
    ];
}
