# 明城的 NixOS 配置文件

<!-- TOC depthfrom:2 -->

- [目录说明](#%E7%9B%AE%E5%BD%95%E8%AF%B4%E6%98%8E)
- [主机列表](#%E4%B8%BB%E6%9C%BA%E5%88%97%E8%A1%A8)
- [安装事项](#%E5%AE%89%E8%A3%85%E4%BA%8B%E9%A1%B9)
- [使用事项](#%E4%BD%BF%E7%94%A8%E4%BA%8B%E9%A1%B9)
- [参考资源](#%E5%8F%82%E8%80%83%E8%B5%84%E6%BA%90)

<!-- /TOC -->

NixOS 可以说是我至今为止碰到的最合适的 Linux 发行版，因为它解决了很多我在部署和配置上的问题（对，我个人是拿它来做服务器环境部署使用）。

## 目录说明

目录结构还是非常的简单，主要为以下的安排：

```text
.
├── hosts // 存放各个主机平台的配置
│   ├── chartman
│   ├── farlion
│   ├── qemu
│   ├── ...
│   └── usb
├── packages // 软件包相关的配置
├── scripts // Shell 脚本
├── services // 系统服务相关的配置
└── system // 系统相关的配置
```

## 物理机列表

备注：这个表格更新自 Sharkbay 项目的表格，主要是物理硬件的列表

| 主机名称           | 网络地址    | 硬件配置                                                             | 相关说明                                                             |
| ------------------ | ----------- | -------------------------------------------------------------------- | -------------------------------------------------------------------- |
| supermicro         | 192.168.0.2 | Xeon E-2236 (12)、64G DDR4、三星PM981a 1T SSD、四口英特尔350网卡     |                                                                      |
| jginyue            | 192.168.0.3 | JGINYUE H97I PLUS、i7-4790T、8g DDR3、WD SSD 256G                    | 家庭主力软路由，上面跑了 OpenWRT 以及 Clash 服务                     |
| chartman           | /           | Xeon E-2288G(ES)、三星 32G ECC DDR4 <del>1T 三星 NVME SSD</del>      | 开发测试二机，主板和 supermirco 一致（暂停使用）                     |
| wooramel           | 192.168.0.4 | Supermicro X10SDV-F、Xeon D-1521， 23G、4T*4、HP Gen8 的定制机箱     | 存放比较重要的数据、备份等，同时提供数据相关的中间件和以及数据库等等 |
| lantern            | 192.168.0.5 | AMD FX-8800P、8g DDR4、16T*2                                         | 娱乐相关的 NAS，主要存放小电影，同时也作 PT下载机                    |
| sharkbay           | 192.168.0.6 | i5-4590T、16G、美光 256G                                             | 备用路由器，同时提供 PT 服务的另外个 IP 出口                         |
| <del>strix</del>   | 172.16.0.2  | AMD 4750G、32G DDR4、512G SATA SSD * 2、京造 512G NVME SSD、四口网卡 | 主要的开发生产主力机，All In One、扔在办公室                         |
| <del>openwrt</del> | 192.168.0.1 | Intel NUC 赛扬、8g DDR3、128G                                        | 专门给开发环境配置和使用的软路由和代理                               |

## 安装事项

注意，分区起码要有两个分区，分别是根分区以及对应的 EFI 分区，同时需要在 fdisk 中指定 EFI 分区的类型；mkfs 的时候，需要设置对应的卷标为 nixos 以及 EFI（具体参考 `system/fs.nix`）文件的配置。

分别挂载到 /mnt 以及 /mnt/efi 目录下；然后执行（如果有需要的话）

```bash
nix-shell -p nixos-generators
```

参考生成的文件，修改 为 `configuration.nix` 这里主要固定版本号。

```nix
{ config, pkgs, ... }: {
  imports = [ ./main.nix ];
  system.stateVersion = "22.11"; # Did you read the comment?
}
```

同时，可以参考具体的配置重新定义主机名称以及网络地址，例如

```nix
networking.hostName = lib.mkForce "lenovo";
networking.interfaces = lib.mkForce {
  "br0" = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "192.168.0.7";
      prefixLength = 23;
    }];
  };
};

networking.defaultGateway = lib.mkForce {
  address = "192.168.0.1";
  interface = "br0";
};
networking.nameservers = lib.mkForce [ "192.168.0.1" ];
```

配置镜像源，参考 `scripts/nixconfig.sh` 文件，然后根据主机名称注入环境变量安装

```bash
NIX_BUILD_HOST=farlion nixos-install --root /mnt --no-root-password
```

如果一切没有问题，将安装完成。

## 使用事项

批量格式化可以使用以下命令

```bash
nix-shell -p nixfmt --run "find . -iname '*.nix' -exec nixfmt {} \;"
```

或者直接使用 `make fmt`

如果需要参考具体的包以及配置，需要了解具体的软件包定义，这块需要参考例如：

- <https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/databases/redis.nix>
- <https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/databases/mongodb.nix>

## 参考资源

- <https://mirrors.tuna.tsinghua.edu.cn/help/nix/>
- <https://nixos.wiki/wiki/Storage_optimization>
- <https://nixos.wiki/wiki/Overview_of_the_Nix_Language>
- <https://learnxinyminutes.com/docs/nix/>
- <https://cheat.readthedocs.io/en/latest/nixos/nix_lang.html>
