# Ryzen 7 PRO 4750G 台式工作站 (`ryzen-4750g`)

面向 **ASUS ROG STRIX B450-I GAMING + AMD Ryzen 7 PRO 4750G + Radeon Pro WX 4100** 的台式开发与虚拟化工作站配置（`NIX_BUILD_HOST=ryzen-4750g`）。开箱提供 KDE Plasma 6（Wayland）、PipeWire、Fcitx5/Rime、KVM/Libvirt、OpenSSH 与开发工具链。

通用仓库结构、通道说明与自定义选项请参阅根目录 [README.md](../../README.md)。

[kernel.nix](kernel.nix) 使用稳定通道的 `linuxPackages_6_18`；AMDGPU 参数保留当前稳定性测试基线（包括屏蔽 SRAM 浅睡眠位的 `cg_mask` 时钟门控、默认 BACO 重置、跳过软恢复及长任务超时），仅作用于此主机，不改变笔记本内核。仍只启用 S3 挂起而不启用磁盘休眠；重启后需在本机验证显卡负载与唤醒，配置求值不能证明硬件稳定性。

- [硬件概览](#硬件概览)
- [BIOS / UEFI 设置清单](#bios--uefi-设置清单)
- [安装与日常维护](#安装与日常维护)
  - [全新安装](#全新安装)
  - [构建、更新与回退](#构建更新与回退)
- [常用工具与使用说明](#常用工具与使用说明)
  - [硬件监控与压力测试](#硬件监控与压力测试)
  - [家目录快照与备份](#家目录快照与备份)
  - [状态快速自检](#状态快速自检)
  - [使用注意事项](#使用注意事项)

## 硬件概览

| 组件       | 硬件型号                                           | 系统支持说明                                                         |
| ---------- | -------------------------------------------------- | -------------------------------------------------------------------- |
| 主板与固件 | ASUS ROG STRIX B450-I GAMING                       | UEFI `systemd-boot` 引导，支持 `fwupd` 固件更新与主板传感器监控      |
| 处理器     | AMD Ryzen 7 PRO 4750G（8C/16T，65 W）              | 启用 `amd-pstate-epp` 自动调频，支持在 KDE 电源面板直接切换能效档位  |
| 内存       | 32 GiB DDR4                                        | 启用 25% `zstd` `zramSwap`（约 7.8 GiB），支持 S3 内存睡眠，无休眠盘 |
| 存储       | WD PC SN810 1 TB NVMe SSD                          | 1 GiB FAT32 EFI（`/boot`）+ F2FS 根分区，默认开启定期 `fstrim`       |
| 家目录盘   | Micron 2200 512 GB NVMe SSD                        | 整盘 Btrfs `@home` 子卷挂载 `/home`，Snapper 每小时快照              |
| 备份盘     | 1 TB 2.5" HDD（`sda`）                             | 整盘 Btrfs（卷标 `backup`），btrbk 每日增量备份 `/home`              |
| 独立显卡   | AMD Radeon Pro WX 4100（4 GiB GDDR5）              | `amdgpu` 早期 KMS 驱动，针对 4K Wayland 与长时 Vulkan/3D 负载调优    |
| 网络与蓝牙 | Intel I211 千兆有线 + Intel Wi-Fi 6E AX210（蓝牙） | 由 NetworkManager 统一管理有线、无线与蓝牙连接                       |
| 虚拟化     | AMD-V + AMD-Vi IOMMU                               | 预装 KVM/QEMU + Libvirt（`virt-manager`）与 Docker                   |

## BIOS / UEFI 设置清单

开机按 `Del` 或 `F2` 进入 BIOS，按 `F7` 切换至 **Advanced Mode**。首次安装或升级/重置 BIOS 后，请核对以下关键设置：

| BIOS 菜单路径                                                   | 选项名称                                               | 推荐设置                             | 说明                                                            |
| --------------------------------------------------------------- | ------------------------------------------------------ | ------------------------------------ | --------------------------------------------------------------- |
| `Advanced → Onboard Devices Configuration`                      | `PCIEX16_1 Mode` / `M.2_1 Link Mode`                   | `Gen3`                               | 固定显卡与正面主 NVMe 为 PCIe 3.0，避免高负载动态切速掉速       |
| `Advanced → PCI Subsystem Settings`                             | `ASPM Support`                                         | `Disabled`                           | 关闭主板 PCIe 节能，保障独显与 NVMe 链路稳定                    |
| `Advanced → PCI Subsystem Settings`                             | `Above 4G Decoding` / `Re-Size BAR Support`            | `Enabled` / `Auto`                   | 启用 4 GiB 完整显存映射（需虚拟化扩展时可同时开启 `SR-IOV`）    |
| `Advanced → NB Configuration`                                   | `Primary Video Device` / `Integrated Graphics`         | `PCIE Video` / `Disabled`            | 仅独显接显示器时关闭核显，回收共享内存并避免多显卡序号漂移      |
| `Advanced → AMD CBS → NBIO Common Options → SMU Common Options` | `CPPC` / `CPPC Preferred Cores`                        | `Enabled`                            | 启用 Linux `amd-pstate-epp` 调频与首选高频核调度                |
| `Advanced → AMD CBS → CPU Common Options`                       | `Global C-state Control` / `Power Supply Idle Control` | `Enabled` / `Typical Current Idle`   | 保持待机省电，防止 Linux 深度空闲电流过低触发电源保护断电       |
| `Extreme Tweaker`                                               | `Ai Overclock Tuner` / `Precision Boost Overdrive`     | `D.O.C.P. Standard` / `Disabled`     | 启用内存标准频率（FCLK 保持 1:1 同步），维持 65 W 原生功耗上限  |
| `Advanced → CPU Configuration`                                  | `SVM Mode`                                             | `Enabled`                            | 开启 AMD-V 硬件虚拟化                                           |
| `Advanced → AMD CBS → NBIO Common Options`                      | `IOMMU` / `ACS Enable`                                 | `Enabled`                            | 显式开启 AMD-Vi（勿留 `Auto`），供 KVM/Libvirt 虚拟化与直通使用 |
| `Advanced → AMD fTPM configuration`                             | `Firmware TPM switch`                                  | `Disable`                            | 未启用磁盘 TPM 加密时建议关闭，避免 fTPM 轮询造成偶发微卡顿     |
| `Boot → CSM` / `Secure Boot` / `Boot Configuration`             | `Launch CSM` / `OS Type` / `Fast Boot`                 | `Disabled` / `Other OS` / `Disabled` | 纯 UEFI 无安全启动引导 `systemd-boot`，确保重启时完整初始化硬件 |

## 安装与日常维护

### 全新安装

本机使用 `zramSwap`，无需划分磁盘休眠 swap 分区：

```bash
# 1. 分区并格式化（清空目标磁盘：创建 1 GiB EFI 与 F2FS 根分区）
sudo bash scripts/disk-init.sh /dev/nvme0n1

# 2. 挂载分区并生成本机硬件配置
sudo bash scripts/mount.sh
sudo nixos-generate-config --root /mnt

# 3. 将仓库放入 /mnt/etc/nixos，在 configuration.nix 中引入 ./main.nix 后配置通道与缓存
sudo bash /mnt/etc/nixos/scripts/nixconfig.sh

# 4. 执行安装
sudo env NIX_BUILD_HOST=ryzen-4750g nixos-install --root /mnt
```

> 默认创建 `mingcheng` 账户（加入 `wheel`、`libvirtd`、`docker`、`networkmanager` 等用户组）并启用 OpenSSH 服务端（仅允许公钥登录），首次安装后请配置用户密码与 SSH 公钥。

### 构建、更新与回退

`sudo` 会剥离环境变量，执行 `nixos-rebuild` 时需通过 `sudo env NIX_BUILD_HOST=ryzen-4750g` 传入主机名：

```bash
# 仅构建验证（不切换系统）
sudo env NIX_BUILD_HOST=ryzen-4750g nixos-rebuild build

# 构建并立即切换配置
sudo env NIX_BUILD_HOST=ryzen-4750g nixos-rebuild switch

# 更新软件通道并切换
sudo nix-channel --update
sudo env NIX_BUILD_HOST=ryzen-4750g nixos-rebuild switch

# 回退到上一代配置
sudo env NIX_BUILD_HOST=ryzen-4750g nixos-rebuild switch --rollback

# 运行主机配置求值检查与本机配置检查
make check-host-ryzen-4750g
NIX_BUILD_HOST=ryzen-4750g make check-local LOCAL_CONFIG=/etc/nixos/configuration.nix
```

## 常用工具与使用说明

### 硬件监控与压力测试

系统已为 `mingcheng` 账户预装常用监控与稳定性测试工具：

```bash
# AMDGPU 实时状态监控（终端 TUI / 图形界面）
amdgpu_top
amdgpu_top --gui

# CPU 频率、温度、功耗曲线监控与烤机
s-tui
stress-ng --cpu 16 --cpu-method matrixprod --vm 4 --vm-bytes 75% --timeout 10m --metrics-brief

# Wayland OpenGL / Vulkan 图形与显存稳定性测试
systemd-inhibit --what=idle:sleep --why="glmark2" glmark2-wayland --run-forever --fullscreen
vkmark
memtest_vulkan
```

### 家目录快照与备份

[storage.nix](storage.nix) 为 `/home` 提供双重保护：

| 层级     | 服务          | 位置                             | 频率与保留策略                                     | 防护范围         |
| -------- | ------------- | -------------------------------- | -------------------------------------------------- | ---------------- |
| 本地快照 | Snapper       | `/home/.snapshots`（同盘）       | 每小时；保留 12 时 / 7 天 / 4 周 / 6 月            | 误删、误改、回滚 |
| 异盘备份 | btrbk         | `/mnt/backup/btrbk`（`sda` HDD） | 每日增量 `send/receive`；保留 14 天 / 8 周 / 12 月 | 家目录盘损坏     |
| 完整性   | `btrfs scrub` | `/home` 与 `/mnt/backup`         | 每月                                               | 静默数据损坏     |

`/home` 挂载参数由仓库统一管理（`compress=zstd:1`、`noatime`、`discard=async`、`space_cache=v2`），设备 UUID 仍来自本机 `hardware-configuration.nix`。首次切换前需为备份盘设置卷标（备份盘缺失时不会阻塞开机，但 btrbk 会报错退出）：

```bash
sudo btrfs filesystem label /dev/sda backup
sudo env NIX_BUILD_HOST=ryzen-4750g nixos-rebuild switch

# 立即执行一次首个（全量）备份并检查结果
sudo systemctl start btrbk-home.service
sudo btrbk -c /etc/btrbk/home.conf list all
```

日常使用：

```bash
# 查看与对比本地快照，恢复单个文件
snapper -c home list
snapper -c home status 10..11
snapper -c home undochange 10..11 ~/path/to/file

# 手动创建快照（例如大改动前）
snapper -c home create --description "before refactor"

# 从 HDD 备份恢复：备份为只读子卷，直接复制所需文件即可
ls /mnt/backup/btrbk/
```

### 状态快速自检

```bash
# 查看显卡实时功耗、频率与 DPM 状态
sudo cat /sys/kernel/debug/dri/1/amdgpu_pm_info

# 检查显卡 PCIe 链路速率（正常为 Speed 8GT/s, Width x8）与错误状态
sudo lspci -s 01:00.0 -vv | grep -E 'LnkSta:|UESta:|CESta:'

# 检查内核日志中是否存在显卡错误或重置记录
sudo dmesg -T | grep -Ei 'amdgpu.*(fault|timeout|reset|error)|\[drm\].*error'
```

### 使用注意事项

- **电源与睡眠**：本机启用 S3 内存睡眠，禁用磁盘休眠（Hibernation）。日常可通过 KDE 电源管理面板或 `powerprofilesctl set <power-saver|balanced|performance>` 切换能效档位，请勿同时启用 `tlp` 或 `tuned`。
- **按需开启 IPv6**：默认关闭 IPv6；若当前网络环境需要 IPv6，可在本机 `/etc/nixos/configuration.nix` 中添加：
  ```nix
  boot.kernel.sysctl."net.ipv6.conf.all.disable_ipv6" = lib.mkForce 0;
  ```
- **主板传感器已知误报**：运行 `sensors` 时，`asus_wmi_sensors` 显示的 `+12V: ~9.81 V`（WMI 换算比例偏差，实际电压可在 BIOS Monitor 中查看）与 `Tsensor 1: +216.0°C`（主板外置温控探头针脚悬空默认值）属于该主板固件已知现象，并非硬件故障。
