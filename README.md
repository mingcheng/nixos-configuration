# 明城的 NixOS 配置文件

NixOS 可以说是我今年看来碰到的最合适的 Linux 发行版，因为它解决了很多我在部署和配置上的问题（对，我个人是拿它来做服务器环境部署使用）。

## 目录说明

目录结构还是非常的简单，主要为以下的安排：

```
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

## 主机列表

备注：这个表格更新自 Sharkbay 项目的表格，主要是物理硬件的列表

| 主机名称   | 网络地址    | 硬件配置                                                             | 相关说明                                                             |
| ---------- | ----------- | -------------------------------------------------------------------- | -------------------------------------------------------------------- |
| strix      | 172.16.0.2  | AMD 4750G、32G DDR4、512G SATA SSD * 2、京造 512G NVME SSD、四口网卡 | 主要的开发生产主力机，All In One、扔在办公室                         |
| supermicro | 192.168.0.2 | Xeon E-2236 (12)、64G DDR4、2T SSD、四口英特尔350网卡                | 从 20220726 开始， strix 替换为志强 Xeon E-2236                      |
| chartman   | 192.168.0.3 | Xeon E-2288G(ES)、三星 32G ECC DDR4、1T 三星 NVME SSD                | 开发测试二机，主板和 supermirco 一致                                 |
| wooramel   | 192.168.0.4 | i7-4790T、8g DDR3、4T*4、HP Gen10 的定制机箱                         | 存放比较重要的数据、备份等，同时提供数据相关的中间件和以及数据库等等 |
| lantern    | 192.168.0.5 | AMD FX-8800P、8g DDR4、16T*2                                         | 娱乐相关的 NAS，主要存放小电影，同时也作 PT下载机                    |


然后是其他需要配置的镜像、虚拟机等系统的列表

| 主机名称  | 网络地址     | 硬件配置                                  | 相关说明                                                         |
| --------- | ------------ | ----------------------------------------- | ---------------------------------------------------------------- |
| farlion   | 192.168.0.11 |                                           | Homelab 的操作机，基于 Qemu 同时部署在 chartman 上               |
| snowflake | 172.16.0.201 |                                           | Office Lab 的操作机，基于 Qemu 部署在 strix 物理机上             |
| lenovo    | /            | i5 4690T、16G DDR3、256G SATA SSD、双网口 | 使用批量的配置，例如 kennedy skyler 等物理机都使用这个配置       |
| qemu      |              |                                           | 基础的 Qemu 虚拟机镜像，注意默认情况下还需要配置具体的虚拟机应用 |
| usb       |              |                                           | 针对 USB 的镜像（通常执行维护和安装使用）                        |


## 安装事项

### 分区

注意，分区起码要有两个分区，分别是根分区以及对应的 EFI 分区，同时需要在 fdisk 中指定 EFI 分区的类型；mkfs 的时候，需要设置对应的卷标为 nixos 以及 EFI（具体参考 `system/fs.nix`）文件的配置。

分别挂载到 /mnt 以及 /mnt/efi 目录下；然后执行（如果有需要的话）

```
nix-shell -p nixos-generators
```

参考生成的文件，修改 为 `configuration.nix` 这里主要固定版本号。

```nix
{ config, pkgs, ... }: {
  imports = [ ./main.nix ];
  system.stateVersion = "22.05"; # Did you read the comment?
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

```
NIX_BUILD_HOST=farlion nixos-install --verbose --root /mnt --channel tsinghua --no-root-password
```

如果一切没有问题，将安装完成。

## 使用事项

批量格式化可以使用以下命令

```
nix-shell -p nixfmt --run "find . -iname '*.nix' -exec nixfmt {} \;"
```

或者直接使用 `make fmt`

如果需要参考具体的包以及配置，需要了解具体的软件包定义，这块需要参考例如：

* https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/databases/redis.nix
* https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/databases/mongodb.nix

## 参考资源

* https://mirrors.tuna.tsinghua.edu.cn/help/nix/
* https://nixos.wiki/wiki/Storage_optimization
* https://nixos.wiki/wiki/Overview_of_the_Nix_Language
* https://learnxinyminutes.com/docs/nix/
* https://cheat.readthedocs.io/en/latest/nixos/nix_lang.html
