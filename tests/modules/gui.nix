let
  t = import ../lib.nix;
  unstable = import <unstable> {
    system = t.pkgs.stdenv.hostPlatform.system;
    config.allowUnfreePredicate = package: t.lib.getName package == "vscode";
  };
  gui =
    extra:
    t.eval (
      [
        ../../packages/gui.nix
        {
          workstation.users = [ "alice" ];
          users.users.alice.isNormalUser = true;
        }
      ]
      ++ extra
    );
  xorg = gui [ { services.xserver.enable = true; } ];
  wayland = gui [ { programs.sway.enable = true; } ];
  stable = import <nixpkgs> {
    system = t.pkgs.stdenv.hostPlatform.system;
    inherit (wayland.nixpkgs) config overlays;
  };
  displayManager = gui [ { services.displayManager.sddm.enable = true; } ];
  disabledFlatpak = gui [
    {
      programs.sway.enable = true;
      services.flatpak.enable = false;
    }
  ];
in
t.check "modules/gui" {
  xorg-evaluates = t.validSystem xorg;
  wayland-evaluates = t.validSystem wayland;
  xorg-detection =
    xorg.services.flatpak.enable && xorg.environment.sessionVariables.NIXOS_OZONE_WL == "1";
  session-detection =
    !wayland.services.xserver.enable
    && !wayland.services.displayManager.enable
    && wayland.services.flatpak.enable;
  display-manager-detection = displayManager.services.flatpak.enable;
  vscode = t.hasPackages wayland.users.users.alice.packages [ "vscode" ];
  vscode-not-global = !(t.hasPackages wayland.environment.systemPackages [ "vscode" ]);
  vscode-from-unstable = builtins.any (
    package: package.drvPath == unstable.vscode.drvPath
  ) wayland.users.users.alice.packages;
  cursor-remains-disabled =
    !(t.hasPackages wayland.users.users.alice.packages [ "cursor" ])
    && !(t.hasPackages wayland.environment.systemPackages [ "cursor" ]);
  no-fixed-account = !(wayland.users.users ? mingcheng);
  stable-unfree-remains-disabled = !(builtins.tryEval stable.vscode.drvPath).success;
  gtk-portals =
    wayland.xdg.portal.enable
    && wayland.xdg.portal.config.common.default == "gtk"
    && t.hasPackages wayland.xdg.portal.extraPortals [ "xdg-desktop-portal-gtk" ];
  flatpak-opt-out =
    !disabledFlatpak.services.flatpak.enable
    && !(disabledFlatpak.systemd.services ? flatpak-flathub)
    && !(disabledFlatpak.systemd.services ? flatpak-update)
    && !(disabledFlatpak.systemd.timers ? flatpak-update)
    && !(disabledFlatpak.systemd.user.services ? flatpak-flathub);
}
