# 明城的 NixOS 配置

用于 ThinkPad X1 Carbon Gen 8、QEMU 虚拟机和 USB 启动盘的个人配置。当前面向 **NixOS 26.05 / x86_64-linux**，使用传统 channel，无需 flakes

## 选择主机

| `NIX_BUILD_HOST`                                     | 适用场景                                                                         |
| ---------------------------------------------------- | -------------------------------------------------------------------------------- |
| [`x1-carbon-8th`](hosts/x1-carbon-8th/default.nix)   | ThinkPad X1 Carbon Gen 8；Plasma Wayland 桌面、PipeWire 音频、Fcitx5/Rime 输入法 |
| [`vm-image`](hosts/vm-image/default.nix)             | QEMU 客户机基础配置，不是可直接启动的磁盘镜像                                    |
| [`usb-boot-stick`](hosts/usb-boot-stick/default.nix) | USB 启动盘；通用硬件支持、可移动 UEFI 引导、命令行维护工具                       |

构建时必须通过 `NIX_BUILD_HOST` 指定上述配置之一。系统主机名默认与其一致，可在本机配置中用 `networking.hostName` 修改。

## 快速开始

以下以**已安装 NixOS 的 X1** 为例，假设仓库位于 `/etc/nixos`。使用其他主机时，请替换命令中的 `x1-carbon-8th`。

### 1. 接入本机配置

先备份 `configuration.nix` 和 `hardware-configuration.nix`，再在 `configuration.nix` 的 `imports` 中加入 [main.nix](main.nix)：

```nix
imports = [
  ./hardware-configuration.nix
  ./main.nix
];
```

保留原有账户、登录凭据和其他必需配置；不要用此片段替换整个文件。两份本机文件已被 Git 忽略，不应复制其他机器的磁盘 UUID 或硬件配置。

`system.stateVersion` 是首次安装时的兼容基线，不是软件版本；更新 channel 时不要同步修改它。

### 2. 配置软件通道

以下地址与 [sources.nix](sources.nix) 一致。稳定通道用于系统和大部分软件，桌面的 VS Code 另需 `unstable`：

```bash
sudo nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-26.05 nixos
sudo nix-channel --update nixos

# 仅使用 VM 或 USB 配置时，可跳过以下两条命令。
sudo nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-unstable unstable
sudo nix-channel --update unstable
```

这些命令会替换 **root 的同名通道**；普通用户的通道与 root 独立。请使用上述命令，[旧初始化脚本](scripts/nixconfig.sh) 仍引用旧通道，并会覆盖用户 Nix 配置。

### 3. 构建并应用

先构建，确认配置能够正常生成；这一步不会切换运行中的系统：

```bash
sudo env NIX_BUILD_HOST=x1-carbon-8th nixos-rebuild build
```

构建成功后再应用：

```bash
sudo env NIX_BUILD_HOST=x1-carbon-8th nixos-rebuild switch
```

`switch` 会立即应用配置，并可能重启服务。内核等变更需重启后生效；首次切换或升级后，请检查网络、桌面、输入法和睡眠恢复。

## 更新与回退

| 操作         | 做法                                                                                                              |
| ------------ | ----------------------------------------------------------------------------------------------------------------- |
| 更新软件     | 执行 `sudo nix-channel --update nixos`；使用桌面时另执行 `sudo nix-channel --update unstable`，然后重新构建并应用 |
| 回退配置     | 执行 `sudo env NIX_BUILD_HOST=x1-carbon-8th nixos-rebuild switch --rollback`                                      |
| 无法正常启动 | 在启动菜单中选择仍保留的上一代配置                                                                                |

系统回退不能撤销数据库迁移等应用数据变更，重要数据仍需单独备份。

## 个性化配置

| 想调整什么                   | 修改位置                                                                 |
| ---------------------------- | ------------------------------------------------------------------------ |
| 账户、SSH 公钥、代理、主机名 | 本机 `configuration.nix`                                                 |
| 磁盘、swap、EFI 挂载点       | 本机生成的 `hardware-configuration.nix`                                  |
| 主机硬件策略、桌面和软件组合 | [hosts/](hosts/)                                                         |
| 系统设置、可选服务、程序配置 | [system/](system/)、[services/](services/)、[packages/](packages/)       |
| 通道地址与系统二进制缓存     | [sources.nix](sources.nix)；修改通道地址后需重新执行 `nix-channel --add` |

通过 `imports` 按需引入模块，文件存在不代表服务已启用。可选服务带有个人环境的默认值，启用前请核对账户、监听地址、端口、数据目录和访问权限。

需要 SSH 时可导入 [services/sshd.nix](services/sshd.nix)：仅允许公钥认证，禁止 root 远程登录，请先为自己的账户配置公钥。

## 新安装

先手动完成分区并挂载到 `/mnt`，再运行 `sudo nixos-generate-config --root /mnt`。将仓库文件放入 `/mnt/etc/nixos`，保留生成的本机配置，按上面的步骤添加导入、配置通道，并设置自己的账户及登录凭据。

确认磁盘、引导和账户配置后执行：

```bash
sudo env NIX_BUILD_HOST=x1-carbon-8th nixos-install --root /mnt
```

X1 默认使用 `/boot` 挂载 EFI 分区，USB 配置使用 `/efi`；挂载布局必须与硬件配置一致。VM 需另行配置适合目标磁盘的引导器。分区和安装细节请参阅 [NixOS 手册](https://nixos.org/manual/nixos/stable/#sec-installation)。

## 使用提醒

- **X1 休眠**：硬件配置必须声明且仅声明一个 `/dev/` 下、未启用随机加密的 swap 分区；zram 不能替代它。固件需选择 Linux/S3 睡眠模式。
- **管理权限**：`wheel` 组可免密码 sudo，并被列为 Nix trusted-users，只应加入可信账户。
- **秘密信息**：不要把密码、令牌等写入 Nix 表达式，它们可能进入其他用户可读的 Nix store。

## 参考

- [NixOS 手册](https://nixos.org/manual/nixos/stable/)
- [NixOS 选项查询](https://search.nixos.org/options)
- [NixOS Wiki](https://wiki.nixos.org/)
