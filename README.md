# 明城的 NixOS 配置

![Screenshot of X1 Carbon 8th Gen](screenshot.png)

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

这些命令会替换 **root 的同名通道**；普通用户的通道与 root 独立。

也可使用 [nixconfig.sh](scripts/nixconfig.sh)，从任意工作目录登记并更新指定通道：

```bash
sudo bash /etc/nixos/scripts/nixconfig.sh          # 默认只更新 nixos
sudo bash /etc/nixos/scripts/nixconfig.sh unstable # 桌面另需 unstable
```

脚本读取 [sources.nix](sources.nix)，不会覆盖用户的 `nix.conf`，也不会更新其他通道；出错时立即停止。[channel.sh](scripts/channel.sh) 使用相同参数，但只登记通道、不更新。

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
| 所有主机共用的策略           | [profiles/base.nix](profiles/base.nix)                                    |
| 系统设置、可选服务、程序配置 | [system/](system/)、[services/](services/)、[packages/](packages/)       |
| 通道地址与系统二进制缓存     | [sources.nix](sources.nix)；修改通道地址后需重新执行 `nix-channel --add` |

通过 `imports` 按需引入模块，文件存在不代表服务已启用。可选服务带有个人环境的默认值，启用前请核对账户、监听地址、端口、数据目录和访问权限。

需要 SSH 时可导入 [services/sshd.nix](services/sshd.nix)：仅允许公钥认证，禁止 root 远程登录，请先为自己的账户配置公钥。

X1 默认使用 `http://127.0.0.1:7890` 代理。只需配置 `networking.proxy`，NixOS 会将其传递给登录会话和 `nix-daemon`，不要另外重复设置守护进程代理。若不使用该本地代理，在本机配置中加入：

```nix
networking.proxy = {
  default = null;
  noProxy = "";
};
```

## 测试与维护

测试按职责拆分，不依赖仓库中被忽略的本机配置：

| 层次 | 位置 | 验证内容 |
| ---- | ---- | -------- |
| 模块 | [tests/modules/](tests/modules/) | 系统策略、镜像与代理、swap 边界、程序与可选服务、GUI/输入法、PAM |
| 主机 | [tests/hosts/](tests/hosts/) | 三种主机的完整配置求值及各自主机策略 |
| 入口 | [tests/selection.nix](tests/selection.nix) | 未设置、空值、未知主机、路径绕过及主机测试是否齐全 |
| 脚本 | [tests/scripts/](tests/scripts/) | 通道来源、路径兼容、配置保留、磁盘布局、swap 容量、安全检查、错误传播与挂载顺序 |

需要 Nix、GNU Make、Bash，以及可通过 `<nixpkgs>` 访问的稳定通道；完整测试和 GUI/X1 测试还需要 `<unstable>`。测试通道属于运行命令的用户，请留意它们与 root 通道的区别。

```bash
make check                               # 全部语法、模块、主机与脚本测试
make check-modules                       # 仅模块
make check-hosts                         # 仅主机及入口
make check-scripts                       # 仅脚本
make check-module-swap check-module-docker
make check-host-vm-image check-host-usb-boot-stick
```

[公共测试夹具](tests/lib.nix) 使用虚拟磁盘标签求值真实 NixOS 模块，检查系统断言、警告和顶层 derivation；不构建或切换系统，也不启动服务。无桌面测试将 `<unstable>` 替换为禁止导入的夹具，保证 VM、USB 和无 GUI 场景不依赖它。脚本测试模拟通道和挂载命令，不修改真实通道、不访问磁盘设备。

本机配置需要单独检查；以下命令默认读取仓库中的 `configuration.nix`，不会注入测试硬件：

```bash
NIX_BUILD_HOST=x1-carbon-8th make check-local
# 检查其他位置的本机配置：
NIX_BUILD_HOST=x1-carbon-8th make check-local LOCAL_CONFIG=/etc/nixos/configuration.nix
```

这些是**求值和脚本回归测试**，不能替代实际构建、启动及硬件测试。首次安装或调整驱动后，仍需按前文构建并验证网络、输入法、音频和睡眠恢复。

[VS Code 任务](.vscode/tasks.json) 提供模块、主机、脚本、全量和本机检查入口。新增 `tests/modules/*.nix`、`tests/hosts/*.nix` 或 `tests/scripts/*.sh` 会由 [Makefile](Makefile) 自动发现；新增主机时还需更新 [入口测试](tests/selection.nix) 的主机列表。`make fmt` 格式化仓库配置及 Nix 测试，不处理被忽略的本机配置。

## 新安装

可使用 [disk-init.sh](scripts/disk-init.sh) 创建 GPT、1 GiB FAT32 EFI 分区和 F2FS 根分区；添加 `--hibernate` 会预留不少于内存 1.2 倍的 swap。**初始化会清空指定磁盘，必须核对目标并确认。** 参数与脚本介绍见 [scripts/README.md](scripts/README.md)。

将分区挂载到 `/mnt`；如果创建了 swap，先执行 `sudo swapon /dev/disk/by-label/swap`，再运行 `sudo nixos-generate-config --root /mnt`。将仓库文件放入 `/mnt/etc/nixos`，保留生成的本机配置，按上面的步骤添加导入、配置通道，并设置自己的账户及登录凭据。

确认磁盘、引导和账户配置后执行：

```bash
sudo env NIX_BUILD_HOST=x1-carbon-8th nixos-install --root /mnt
```

X1 默认使用 `/boot` 挂载 EFI 分区，USB 配置使用 `/efi`；挂载布局必须与硬件配置一致。VM 需另行配置适合目标磁盘的引导器。分区和安装细节请参阅 [NixOS 手册](https://nixos.org/manual/nixos/stable/#sec-installation)。

[mount.sh](scripts/mount.sh) 将 `nixos`、`EFI` 标签对应的分区挂载到 `/mnt` 和 `/mnt/boot`，适用于 X1 的默认布局，不负责分区或启用 swap。USB 布局需改为将 EFI 挂载到 `/mnt/efi`；任何一步失败都会停止，已成功的挂载不会自动撤销。

## 使用提醒

- **X1 休眠**：硬件配置必须声明且仅声明一个 `/dev/` 下、未启用随机加密的 swap 分区；zram 不能替代它。固件需选择 Linux/S3 睡眠模式。
- **管理权限**：`wheel` 组可免密码 sudo。共享配置的 Nix trusted-users 包含 `root` 和 `@wheel`；X1 收紧为 `root` 和 `mingcheng`。这些权限只应授予可信账户。
- **秘密信息**：不要把密码、令牌等写入 Nix 表达式，它们可能进入其他用户可读的 Nix store。

## 参考

- [NixOS 手册](https://nixos.org/manual/nixos/stable/)
- [NixOS 选项查询](https://search.nixos.org/options)
- [NixOS Wiki](https://wiki.nixos.org/)
