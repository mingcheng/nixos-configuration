{ pkgs, ... }:
{
  # Keep desktop-only features together; locale/timezone live in system/i18n.nix.
  imports = [
    ../../packages/gui.nix
    ./fonts.nix
    ./input-method.nix
  ];

  services = {
    desktopManager.plasma6.enable = true;
    displayManager = {
      defaultSession = "plasma";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

    libinput.enable = true;
    printing.enable = true;
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  security.rtkit.enable = true;

  users.users.mingcheng.packages = [ pkgs.kdePackages.kate ];
}
