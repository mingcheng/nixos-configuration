{ ... }: {
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    # stateVersion = "22.05";
    channel = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-22.05";
  };
}
