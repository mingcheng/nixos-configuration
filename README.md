# 明城的 NixOS 配置文件


https://nixos.wiki/wiki/NixOS_on_ARM/NanoPC-T4

https://mirrors.tuna.tsinghua.edu.cn/help/nix/
https://nixos.wiki/wiki/Storage_optimization

https://nixos.wiki/wiki/Overview_of_the_Nix_Language
https://learnxinyminutes.com/docs/nix/

https://cheat.readthedocs.io/en/latest/nixos/nix_lang.html
.

nix-shell -p nixos-generators
.
sudo NIX_BUILD_HOST=farlion nixos-rebuild boot

nix-shell -p nixfmt --run "find . -iname '*.nix' -exec nixfmt {} \;"

