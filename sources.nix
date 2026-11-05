{
  channels = {
    nixos = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-26.05";
    unstable = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-unstable";
  };

  substituters = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    "https://mirrors.cernet.edu.cn/nix-channels/store"
  ];
}
