{ config, pkgs, ... }:
let
  # Keep the Rime engine and its schema data in one place.
  fcitx5Rime = pkgs.fcitx5-rime.override {
    rimeDataPkgs = [ pkgs.rime-wanxiang ];
  };
in
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        # Configuration UI and toolkit integration.
        fcitx5-fluent
        qt6Packages.fcitx5-configtool
        fcitx5-gtk
        qt6Packages.fcitx5-qt

        # Chinese input engines and Rime schema data.
        qt6Packages.fcitx5-chinese-addons
        librime
        librime-lua
        fcitx5Rime
      ];
    };
  };

  # Toolkit/XWayland compatibility; native Electron uses KWin's input method
  # connection instead of these GTK/Qt variables.
  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
  };

  # Plasma-specific integration: KWin must launch Fcitx to pass it the privileged
  # Wayland input-method socket. waylandFrontend alone does not select it.
  # User-level kwinrc settings can override this system default.
  environment.etc = {
    "xdg/kwinrc".text = ''
      [Wayland]
      InputMethod=${config.i18n.inputMethod.package}/share/applications/org.fcitx.Fcitx5.desktop
      VirtualKeyboardEnabled=true
    '';

    # Avoid a second instance started without KWin's Wayland socket.
    "xdg/autostart/org.fcitx.Fcitx5.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Fcitx 5
      Hidden=true
    '';
  };
}
