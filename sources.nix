#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: sources.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 1970-01-01 08:00:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-06 10:29:27
##

{
  channels = {
    nixos = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-26.05";
    unstable = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-unstable";
  };

  flathub = {
    repository = "https://flathub.org/repo/flathub.flatpakrepo";
    mirror = "https://mirrors.cernet.edu.cn/flathub";
  };

  development = {
    goProxy = "https://goproxy.cn,direct";
    npmRegistry = "https://registry.npmmirror.com";
    pypiIndex = "https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple";
    rustupDistServer = "https://rsproxy.cn";
    rustupUpdateRoot = "https://rsproxy.cn/rustup";
    cargoRegistry = "sparse+https://rsproxy.cn/index/";
  };

  substituters = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    "https://mirrors.cernet.edu.cn/nix-channels/store"
  ];
}
