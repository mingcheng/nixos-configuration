# 明城的 NixOS 配置

![Screenshot of X1 Carbon 8th Gen](screenshot.png)

适用于 ThinkPad X1 Carbon Gen 8、Surface Laptop 3、Ryzen 7 PRO 4750G 台式主机、QEMU 客户机与 USB 启动盘的个人配置。基于 **NixOS 26.05 / x86_64-linux**，使用传统 channel 管理，不依赖 flakes。

## 选择主机

| `NIX_BUILD_HOST`                                         | 适用场景                                                                                                                                     |
| -------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| [`x1-carbon-8th`](hosts/x1-carbon-8th/default.nix)       | ThinkPad X1 Carbon Gen 8（[设备说明](hosts/x1-carbon-8th/README.md)）：`laptop` + `develop`、Plasma Wayland、PipeWire、Fcitx5/Rime           |
| [`surface-laptop-3`](hosts/surface-laptop-3/default.nix) | Surface Laptop 3 (i5-1035G7 / 8G / 256G)：`laptop` 办公套件、主线 6.12 SAM 驱动、禁用触控屏                                                  |
| [`ryzen-4750g`](hosts/ryzen-4750g/default.nix)           | Ryzen 7 PRO 4750G + Radeon Pro WX 4100 台式工作站（[设备说明](hosts/ryzen-4750g/README.md)）：`workstation` + `develop`、AMDGPU、KVM/Libvirt |
| [`vm-image`](hosts/vm-image/default.nix)                 | QEMU/KVM 无头客户机镜像（[镜像说明](hosts/vm-image/README.md)）：随机主机名、Docker、国内镜像源与 SSH，可编译为 `qcow2` 磁盘镜像             |
| [`usb-boot-stick`](hosts/usb-boot-stick/default.nix)     | USB 启动盘：通用硬件支持、可移动 UEFI 引导、命令行维护工具                                                                                   |

构建时必须通过 `NIX_BUILD_HOST` 指定其中一项；系统主机名默认与之相同，可用 `networking.hostName` 覆盖。

## 快速开始

以下假设已安装 NixOS 且仓库位于 `/etc/nixos`，执行命令时请将 `<host>` 替换为上表中的目标主机名（例如 `x1-carbon-8th`）。

### 1. 接入本机配置

先备份 `configuration.nix` 与 `hardware-configuration.nix`，再在 `configuration.nix` 的 `imports` 中加入 [main.nix](main.nix)：

```nix
imports = [
  ./hardware-configuration.nix
  ./main.nix
];
```

保留原有账户与登录凭据，不要用此片段替换整个文件。这两份本机文件已被 Git 忽略，请勿复制其他机器的磁盘 UUID 或硬件配置。`system.stateVersion` 是首次安装时的兼容基线，更新 channel 时不要同步修改。

### 2. 配置软件通道

通道地址定义于 [sources.nix](sources.nix)。系统与大部分软件使用 `nixos`，桌面环境的 VS Code 另需 `unstable`；仅使用 VM 或 USB 配置时无需 `unstable`：

```bash
sudo nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-26.05 nixos
sudo nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-unstable unstable
sudo nix-channel --update
```

也可使用脚本配置二进制缓存（写入 `~/.config/nix/nix.conf`）并登记、更新通道，地址均取自 `sources.nix`：

```bash
sudo bash /etc/nixos/scripts/nixconfig.sh
```

不带参数默认同时处理 `nixos` 与 `unstable`（也可传入 `nixos` 或 `unstable` 仅处理指定通道）；[channel.sh](scripts/channel.sh) 参数相同，但只登记通道，不修改 `nix.conf` 也不更新通道。上述命令操作 root 的配置与通道，与普通用户相互独立。

### 3. 构建并应用

```bash
sudo env NIX_BUILD_HOST=<host> nixos-rebuild build
sudo env NIX_BUILD_HOST=<host> nixos-rebuild switch
```

`build` 仅生成配置、不切换系统；`switch` 会立即应用并可能重启服务。内核等变更需重启生效，首次切换后请检查网络、桌面、输入法与睡眠恢复。

## 全新安装

1. 分区。**初始化会清空目标磁盘，请核对设备路径并确认提示。** 按需选择其一：

```bash
sudo bash scripts/disk-init.sh /dev/nvme0n1
sudo bash scripts/disk-init.sh --hibernate /dev/nvme0n1
```

默认创建 GPT、1 GiB FAT32 EFI 与 F2FS 根分区；`--hibernate` 额外预留不少于内存 1.2 倍的休眠 swap。

2. 挂载分区并生成硬件配置：

```bash
sudo bash scripts/mount.sh
sudo nixos-generate-config --root /mnt
```

[mount.sh](scripts/mount.sh) 按桌面/笔记本主机的 `/boot` 布局挂载，并在检测到 `/dev/disk/by-label/swap` 时自动执行 `swapon`；USB 配置需改为将 EFI 挂载到 `/mnt/efi`。脚本详情见 [scripts/README.md](scripts/README.md)。

3. 将仓库放入 `/mnt/etc/nixos`，保留生成的本机配置，按上文添加 `imports`、配置通道并设置账户与登录凭据，然后安装：

```bash
sudo env NIX_BUILD_HOST=<host> nixos-install --root /mnt
```

挂载布局须与硬件配置一致：桌面/笔记本主机使用 `/boot`，USB 使用 `/efi`；`vm-image` 通过 `disk-image.nix` 自动生成分区与引导器（详见 [hosts/vm-image/README.md](hosts/vm-image/README.md)）。安装细节请参阅 [NixOS 手册](https://nixos.org/manual/nixos/stable/#sec-installation)。

### Surface Laptop 3 USB 启动备忘

Surface Laptop 3 使用 Microsoft 定制 UEFI 界面，通过 USB 安装盘或维护盘启动时请按以下步骤操作：

1. **进入 UEFI 设置**：完全关机后，**按住 `F4`（或音量+）不放**，点按电源键开机，待屏幕出现 Surface 徽标后松开按键即可进入 Surface UEFI。
2. **调整安全启动（Secure Boot）**：进入 **Security → Secure Boot → Change configuration**，选择 **None**（禁用安全启动，安装 NixOS 标准引导器时使用）或 **Microsoft & 3rd party CA**。若原 Windows 分区开启了 BitLocker，修改前请务必先挂起/解密或备份恢复密钥。
3. **配置引导顺序**：进入 **Boot configuration**，勾选启用 **Enable boot from USB devices**，并将 **USB Storage** 拖动到引导列表顶部（也可直接在该列表中向左滑动 **USB Storage** 立即从当前 U 盘启动）。
4. **使用快捷键直接从 USB 启动**：已开启 USB 启动且调优顺序后，关机状态下插好 U 盘，**按住 `F3`（或音量-）不放**，点按电源键开机，出现 Surface 徽标后松开，即可直接引导进入 USB 启动盘。
5. **外接键鼠提醒**：若使用的通用安装镜像未在 initrd 中内置 Surface Aggregator (`surface_aggregator` / `surface_hid`) 驱动，安装阶段内置键盘与触控板可能无法响应，建议准备外接 USB 键盘（或带 USB Hub）完成首次安装。

## 更新与回退

| 操作         | 命令                                                             |
| ------------ | ---------------------------------------------------------------- |
| 更新软件     | `sudo nix-channel --update` 后重新执行 `nixos-rebuild switch`    |
| 回退一代     | `sudo env NIX_BUILD_HOST=<host> nixos-rebuild switch --rollback` |
| 无法正常启动 | 在启动菜单中选择保留的上一代配置                                 |

系统回退不能撤销数据库迁移等应用数据变更，重要数据请单独备份。

## 个性化配置

| 调整内容                         | 位置                                                                            |
| -------------------------------- | ------------------------------------------------------------------------------- |
| 账户、SSH 公钥、代理、主机名     | 本机 `configuration.nix`                                                        |
| 磁盘、swap、EFI 挂载点           | 本机 `hardware-configuration.nix`                                               |
| 主机硬件策略与软件组合           | [hosts/](hosts/)                                                                |
| 分层共用策略                     | [profiles/](profiles/)（`base`、`network`、`desktop`、`laptop`、`develop`、`workstation`） |
| 系统设置、可选服务、程序配置     | [system/](system/)、[services/](services/)、[packages/](packages/)              |
| 通道地址、二进制缓存、在线 hosts | [sources.nix](sources.nix)                                                      |

模块通过 `imports` 按需启用，文件存在不代表服务已开启；可选服务带有个人环境的默认值，启用前请核对账户、监听地址、端口与数据目录。修改通道地址后需重新执行 `nix-channel --add`。

- **SSH**：导入 [services/sshd.nix](services/sshd.nix)（`ryzen-4750g` 已默认启用），仅允许公钥认证并禁止 root 登录，请先为账户配置公钥。
- **Flatpak**：图形环境默认启用 [services/flatpak.nix](services/flatpak.nix)，自动为系统级（`--system`）与用户级（`--user`）配置 [sources.nix](sources.nix) 中的 Flathub 镜像，并在系统级预装 `Firefox`、`VLC`、`LibreOffice` 及按周自动更新；可通过 `services.flatpak.packages` 或 `services.flatpak.update` 调整。


### 自定义 hosts

桌面配置通过 [system/network_hosts.nix](system/network_hosts.nix) 读取 [sources.nix](sources.nix) 的 `hosts` URL 列表，统一用 `builtins.fetchurl` 加入 `networking.hostFiles` 即可。

本机条目仍使用原生选项，也可追加本地文件：

```nix
networking.hosts."192.0.2.10" = [ "build.example.test" ];
networking.extraHosts = ''
  192.0.2.11 nas.example.test
'';
# networking.hostFiles = [ ./my_hosts ];
```

关闭任一来源时，从 [sources.nix](sources.nix) 的 `hosts` 列表中删除对应 URL 即可；设为 `[]` 会关闭全部远端注入，包括 StevenBlack，但不会删除本机条目。

## 测试与维护

测试按模块、主机、入口与脚本分层，只做配置求值，不会构建或切换系统：

```bash
make check
make check-modules
make check-hosts
make check-scripts
make fmt
```

依次为全部检查、仅模块、仅主机与入口、仅脚本，以及格式化 Nix 文件。需要 Nix、GNU Make、Bash 与可访问的 `<nixpkgs>`，完整测试及 GUI 主机另需 `<unstable>`；工具版本见 [mise.toml](mise.toml)。测试使用当前用户的通道，与 root 通道独立。

本机配置需单独检查：

```bash
NIX_BUILD_HOST=<host> make check-local
NIX_BUILD_HOST=<host> make check-local LOCAL_CONFIG=/etc/nixos/configuration.nix
```

[VS Code 任务](.vscode/tasks.json) 提供常用检查与本地构建入口。这些是求值与脚本回归测试，不能替代实际构建、启动及硬件验证。

## 使用提醒

- **休眠与硬件调优**：笔记本配置（`x1-carbon-8th`、`surface-laptop-3`，导入 `profiles/laptop.nix`）的硬件配置须声明且仅声明一个 `/dev/` 下、未启用随机加密的 swap 分区；zram 不能替代。ThinkPad X1 固件与睡眠配置详见 [hosts/x1-carbon-8th/README.md](hosts/x1-carbon-8th/README.md)，Surface Laptop 3 使用 S0ix 现代待机配合 `suspend-then-hibernate`；Ryzen 4750G + WX 4100 台式工作站的 ROG STRIX B450-I GAMING 主板 BIOS 设置与 AMDGPU 稳定性调优详见 [hosts/ryzen-4750g/README.md](hosts/ryzen-4750g/README.md)。
- **权限**：`wheel` 组可免密码 sudo；共享配置的 Nix `trusted-users` 为 `root` 与 `@wheel`，各物理主机（`x1-carbon-8th`、`surface-laptop-3`、`ryzen-4750g`）及 `vm-image` 收紧为 `root` 与 `mingcheng`，仅应授予可信账户。
- **秘密信息**：不要把密码、令牌写入 Nix 表达式，它们可能进入其他用户可读的 Nix store。

## 参考

- [NixOS 手册](https://nixos.org/manual/nixos/stable/)
- [NixOS 选项查询](https://search.nixos.org/options)
- [NixOS Wiki](https://wiki.nixos.org/)
