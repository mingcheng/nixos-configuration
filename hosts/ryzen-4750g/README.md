# Ryzen 7 PRO 4750G 台式工作站 (`ryzen-4750g`)

面向 **ASUS ROG STRIX B450-I GAMING + AMD Ryzen 7 PRO 4750G + Radeon Pro WX 4100** 的主力台式开发与虚拟化工作站配置（`NIX_BUILD_HOST=ryzen-4750g`）。基于 [profiles/workstation.nix](../../profiles/workstation.nix) 与 [profiles/develop.nix](../../profiles/develop.nix)，运行 KDE Plasma 6（Wayland）、PipeWire、Fcitx5/Rime 与 KVM/Libvirt，并针对 Renoir Zen 2 APU、Polaris 11 专业独显在 B450 ITX 平台上的 PCIe 链路与电源稳定性做了专门调优。

通用仓库结构、通道说明与自定义选项请参阅根目录 [README.md](../../README.md)。

## 硬件规格与驱动支持

| 组件       | 硬件型号 / 规格                                                 | 配置与驱动策略                                                                                                                                     |
| ---------- | --------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| 主板与固件 | ASUS ROG STRIX B450-I GAMING（BIOS `5102`）                     | 启用 UEFI `systemd-boot`、`services.fwupd.enable`，显式加载 `asus_wmi_sensors` 并屏蔽误匹配的笔记本 `eeepc_wmi`/`asus_wmi` 模块                    |
| 处理器     | AMD Ryzen 7 PRO 4750G（Renoir Zen 2 APU，8C/16T，65 W）         | 启用 `hardware.cpu.amd.updateMicrocode`、`amd_pstate=active`（`amd-pstate-epp`）、`k10temp` 与 `kvm-amd`，由 `power-profiles-daemon` 管理能效档位  |
| 内存       | 32 GiB DDR4                                                     | 启用 25% `zstd` `zramSwap`（约 7.8 GiB 压缩交换，优先级 `100`），仅支持内存挂起（S3），不依赖物理休眠 swap 分区                                    |
| 存储       | WD PC SN810 1 TB NVMe SSD（`15b7:5011`，PCIe 3.0 x4 链路）      | 1 GiB FAT32 EFI（`/boot`，`fmask=0077,dmask=0077`）+ F2FS 根分区，启用 `fstrim` 并设 `nvme_core.default_ps_max_latency_us=20000` 规避 PS4 唤醒超时 |
| 独立显卡   | Dell OEM AMD Radeon Pro WX 4100（Polaris 11，4 GiB GDDR5）      | PCI ID `1002:67e3`（子系统 `1028:0b0d`，32 W TDP，运行于 Renoir PCIe 3.0 x8 桥），initrd 预加载 `amdgpu` 并配置 SMU7/DCE 稳定性参数                |
| 网络与蓝牙 | Intel I211 千兆有线（`igb`）+ Intel Wi-Fi 6E AX210（`iwlwifi`） | 启用 `enableRedistributableFirmware` 与 `hardware.bluetooth.enable`，由 NetworkManager 统一管理有线与无线连接                                      |
| 虚拟化     | AMD-V + AMD-Vi IOMMU + KVM/QEMU                                 | 导入 [services/libvirtd.nix](../../services/libvirtd.nix)，BIOS 开启 IOMMU 后由内核自动初始化 AMD-Vi 并通过 `iommu=pt` 启用宿主机直通域            |

## 模块组成

| 文件                                                             | 职责说明                                                                                                 |
| ---------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| [default.nix](default.nix)                                       | 主机入口：组合 `workstation` + `develop`、`boot.nix`、`libvirtd.nix`、`sshd.nix`，声明 `mingcheng` 账户  |
| [kernel.nix](kernel.nix)                                         | 锁定 `linuxPackages_6_12` LTS 内核，配置 `amdgpu` 早期 KMS、Renoir/Polaris 11 稳定性内核参数、微码与固件 |
| [tuning.nix](tuning.nix)                                         | 配置 AMD 电源策略（PPD + 禁用 `thermald`）、S3 睡眠、`zramSwap`、F2FS 脏页写回、构建并发与压测监控工具集 |
| [tests/hosts/ryzen-4750g.nix](../../tests/hosts/ryzen-4750g.nix) | 主机配置纯求值回归测试（内核版本、AMDGPU 参数、Wayland 桌面、用户级包路由、zram、防火墙与代理继承等）    |

## ROG STRIX B450-I GAMING BIOS / UEFI 最佳设置备忘（面向 Linux 平台）

开机出现 ROG / ASUS 徽标时按 `Del` 或 `F2` 进入 UEFI BIOS Utility（当前固件版本 `5102`），按 `F7` 切换至 **Advanced Mode（高级模式）**。针对 **NixOS 6.12 LTS + Plasma Wayland + KVM/Libvirt + Radeon Pro WX 4100** 的硬件特性，建议按菜单逐项核对以下配置：

### 1. PCIe 链路、M.2 存储与显卡稳定性（最关键）

Renoir APU（Ryzen 7 PRO 4750G）向主插槽仅提供 **PCIe 3.0 x8** 通道，且 CPU 侧根端口（`00:01.1`）不支持 ASPM。为避免 WX 4100 在高负载或动态切速时出现 `BadTLP`/`BadDLLP` 链路校验错包或降速至 Gen1（`2.5 GT/s`）：

| BIOS 菜单路径                              | 选项名称                         | 推荐设置                       | 作用与 Linux 适配说明                                                                                                                                                                 |
| :----------------------------------------- | :------------------------------- | :----------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `Advanced → Onboard Devices Configuration` | **PCIEX16_1 Mode（Link Speed）** | **`Gen3`**                     | **必调**：锁定主插槽为 PCIe 3.0（`8.0 GT/s`），防止 `Auto` 在高负载或瞬态抖动下协商降级为 Gen1                                                                                        |
| `Advanced → Onboard Devices Configuration` | **M.2_1 Link Mode**              | **`Gen3`**                     | 正面 `M.2_1`（散热装甲下）直连 CPU 专用 4x NVMe 通道且不拆分显卡通道，主系统盘应装于 `M.2_1` 并固定 Gen3                                                                              |
| `Advanced → PCI Subsystem Settings`        | **ASPM Support**                 | **`Disabled`**                 | **必调**：硬件层关闭主板 PCIe ASPM（含 `AMD PBS` 下的 ASPM 项），与内核 `amdgpu.aspm=0` 配合杜绝 `BadTLP`/`BadDLLP`                                                                   |
| `Advanced → PCI Subsystem Settings`        | **Above 4G Decoding**            | **`Enabled`**                  | 允许 64-bit PCIe 设备分配大于 4 GiB 的物理地址空间（开启 Re-Size BAR 的前置条件）                                                                                                     |
| `Advanced → PCI Subsystem Settings`        | **Re-Size BAR Support**          | **`Enabled` / `Auto`**         | 使 WX 4100 的 4 GiB GDDR5 完整映射为 CPU 可直访的 4096M BAR（`Detected VRAM RAM=4096M, BAR=4096M`），消除 256M 窗口瓶颈                                                               |
| `Advanced → PCI Subsystem Settings`        | **SR-IOV Support**               | **`Enabled`**                  | 为 KVM/Libvirt 虚拟化预留 PCIe SR-IOV 能力                                                                                                                                            |
| `Advanced → NB Configuration`              | **Primary Video Device**         | **`PCIE Video`**               | 优先初始化 PCIe 独显（WX 4100）作为主显示输出                                                                                                                                         |
| `Advanced → NB Configuration`              | **Integrated Graphics**          | **`Disabled`**（仅独显输出时） | 若显示器仅接在 WX 4100 上，设为 `Disabled` 可回收划分给 Vega 8 核显的 UMA 内存，并防止 Linux DRM `card0`/`card1` 编号漂移及 KWin 跨卡拷贝；需主板 HDMI/DP 核显交叉排查时再改回 `Auto` |

### 2. CPU 调频（CPPC）、电源稳态与 Data Fabric

| BIOS 菜单路径                                                   | 选项名称                      | 推荐设置                   | 作用与 Linux 适配说明                                                                                                       |
| :-------------------------------------------------------------- | :---------------------------- | :------------------------- | :-------------------------------------------------------------------------------------------------------------------------- |
| `Advanced → AMD CBS → NBIO Common Options → SMU Common Options` | **CPPC**                      | **`Enabled`**              | **必调**：向 Linux ACPI 暴露 `_CPC` 寄存器，使 `amd_pstate=active`（`amd-pstate-epp`）生效                                  |
| `Advanced → AMD CBS → NBIO Common Options → SMU Common Options` | **CPPC Preferred Cores**      | **`Enabled`**              | 向内核调度器暴露 Zen 2 核心体质优先级（最高睿频核优先承接单线程/桌面交互负载）                                              |
| `Advanced → AMD CBS → CPU Common Options`                       | **Global C-state Control**    | **`Enabled`**              | 允许空闲核心进入深度 C6 省电，保障活跃核心睿频空间与待机低温                                                                |
| `Advanced → AMD CBS → CPU Common Options`                       | **Power Supply Idle Control** | **`Typical Current Idle`** | **必调（Zen 2 Linux 经典排障项）**：防止 CPU 在 Linux 深度空闲时电流过低触发 ATX/SFX 电源欠流保护或随机无日志死机           |
| `Advanced → AMD CBS → DF Common Options`                        | **DF Cstates**                | **`Disabled`**（可选）     | 若追求长时间高吞吐 PCIe DMA（如 `memtest_vulkan` / NVMe 高并发）下的最低延迟，可关闭 Data Fabric C-State 以避免总线唤醒抖动 |
| `Extreme Tweaker`                                               | **Ai Overclock Tuner**        | **`D.O.C.P. Standard`**    | 启用内存标准 XMP/DOCP 配置，建议运行于 `DDR4-3200` 或 `DDR4-3600` 稳定频点                                                  |
| `Extreme Tweaker`                                               | **FCLK Frequency**            | **与内存 1:1 同步**        | 例如 `DDR4-3200` 设 `1600MHz`、`DDR4-3600` 设 `1800MHz`，避免 Infinity Fabric 异步分频延迟与 SoC 电压偏高                   |
| `Extreme Tweaker → Precision Boost Overdrive`                   | **Precision Boost Overdrive** | **`Disabled` / `Auto`**    | 保持 4750G 原生 65 W TDP 封包上限，避免 ITX 机箱内 CPU 额外发热抬升单槽 WX 4100 的进风温度                                  |

### 3. 硬件虚拟化、IOMMU 分组与安全设备（fTPM）

| BIOS 菜单路径                              | 选项名称                          | 推荐设置      | 作用与 Linux 适配说明                                                                                                                    |
| :----------------------------------------- | :-------------------------------- | :------------ | :--------------------------------------------------------------------------------------------------------------------------------------- |
| `Advanced → CPU Configuration`             | **SVM Mode**                      | **`Enabled`** | 开启 AMD-V 硬件虚拟化（`kvm-amd` 模块必需）                                                                                              |
| `Advanced → CPU Configuration`             | **NX Mode**                       | **`Enabled`** | 开启数据执行保护（No-Execute Page Protection）                                                                                           |
| `Advanced → AMD CBS → NBIO Common Options` | **IOMMU**                         | **`Enabled`** | **必调（勿留 `Auto`）**：华硕部分 BIOS 下 `Auto` 不会完整生成 ACPI IVRS 表，显式设为 `Enabled` 以便内核自动启用 AMD-Vi 并配合 `iommu=pt` |
| `Advanced → AMD CBS → NBIO Common Options` | **ACS Enable / PCIe ARI Support** | **`Enabled`** | 开启 PCIe 访问控制服务（ACS），细化 IOMMU Group 硬件隔离粒度，便于 Libvirt/VFIO 设备直通                                                 |
| `Advanced → AMD fTPM configuration`        | **Firmware TPM switch**           | **`Disable`** | **推荐关闭**：本机 NixOS 使用未加密 F2FS 且无需 TPM2，关闭 AM4 固件 fTPM 可彻底规避 SPI 闪存轮询引起的系统/PipeWire 音频偶发微卡顿       |

### 4. 引导、板载外设与机箱散热曲线

| BIOS 菜单路径                               | 选项名称                  | 推荐设置                   | 作用与 Linux 适配说明                                                                               |
| :------------------------------------------ | :------------------------ | :------------------------- | :-------------------------------------------------------------------------------------------------- |
| `Boot → CSM (Compatibility Support Module)` | **Launch CSM**            | **`Disabled`**             | 纯 UEFI 引导，开启 Above 4G / Re-Size BAR 与内核 `simpledrm` 原生 4K 早期帧缓冲所必需               |
| `Boot → Secure Boot`                        | **OS Type**               | **`Other OS`**             | 关闭安全启动校验以直接引导 NixOS `systemd-boot`                                                     |
| `Boot → Boot Configuration`                 | **Fast Boot**             | **`Disabled`**             | 避免重启时跳过 PCIe 链路完整重训练（Link Equalization）与 USB 外设初始化                            |
| `Advanced → Onboard Devices Configuration`  | **LED Lighting**          | **`Stealth Mode`（按需）** | 关闭主板待机/运行 RGB 灯效，避免不必要的 I2C/SMBus 灯控芯片轮询                                     |
| `Monitor → Q-Fan Configuration`             | **Chassis Fan 1 Profile** | **`Standard` / `Turbo`**   | WX 4100 为 32 W 单槽涡轮散热（满载稳态约 83–84°C），调高 ITX 机箱风扇排风曲线可显著降低显卡进风温度 |

## 安装、构建与维护

### 1. 全新安装

本机为台式工作站（导入 [profiles/workstation.nix](../../profiles/workstation.nix)），使用 `zramSwap` 而不强制要求磁盘休眠 swap 分区：

```bash
# 1. 分区并格式化（清空磁盘：创建 1 GiB FAT32 EFI 与 F2FS 根分区）
sudo bash scripts/disk-init.sh /dev/nvme0n1

# 2. 挂载 /mnt、/mnt/boot（自动设置 umask=0077），生成本机硬件配置
sudo bash scripts/mount.sh
sudo nixos-generate-config --root /mnt

# 3. 将仓库放入 /mnt/etc/nixos，在 configuration.nix 中引入 ./main.nix 后配置通道与镜像
sudo bash /mnt/etc/nixos/scripts/nixconfig.sh

# 4. 执行系统安装
sudo env NIX_BUILD_HOST=ryzen-4750g nixos-install --root /mnt
```

### 2. 日常构建、更新与回退

`sudo` 默认会剥离环境变量，所有 `nixos-rebuild` 命令均需通过 `sudo env NIX_BUILD_HOST=ryzen-4750g` 显式传入主机标识：

```bash
# 仅构建验证（不切换当前系统）
sudo env NIX_BUILD_HOST=ryzen-4750g nixos-rebuild build

# 构建并立即切换系统配置
sudo env NIX_BUILD_HOST=ryzen-4750g nixos-rebuild switch

# 更新软件通道后重新构建并切换
sudo nix-channel --update
sudo env NIX_BUILD_HOST=ryzen-4750g nixos-rebuild switch

# 回退到上一代配置
sudo env NIX_BUILD_HOST=ryzen-4750g nixos-rebuild switch --rollback
```

### 3. 配置检查与测试

```bash
# 仅运行 ryzen-4750g 主机求值测试
make check-host-ryzen-4750g

# 验证本机忽略的 configuration.nix / hardware-configuration.nix
NIX_BUILD_HOST=ryzen-4750g make check-local
NIX_BUILD_HOST=ryzen-4750g make check-local LOCAL_CONFIG=/etc/nixos/configuration.nix
```

## 内核与 AMDGPU 稳定性调优说明（[kernel.nix](kernel.nix)）

针对 **Renoir PCIe 3.0 x8 根端口 + Dell OEM Radeon Pro WX 4100（Polaris 11 / GFX8 / SMU7）** 在 4K Wayland 桌面与长时间 3D/Compute 压测下的硬件特性，[kernel.nix](kernel.nix) 配置了以下关键内核参数：

| 内核参数                                        | 作用与根因说明                                                                                                                                                                                                                                                                                                                                                                                                    |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `amd_pstate=active`                             | 启用 Zen 2 CPPC 自主调频（`amd-pstate-epp`），配合 `power-profiles-daemon` 动态调节能效偏好                                                                                                                                                                                                                                                                                                                       |
| `preempt=full`                                  | 启用完全内核抢占，降低 KWin Wayland 合成器与 PipeWire 音频链路在高负载下的延迟                                                                                                                                                                                                                                                                                                                                    |
| `iommu=pt`                                      | BIOS 开启 IOMMU 后内核通过 ACPI IVRS 自动启用 AMD-Vi（注：Linux `amd_iommu=` 不接受 `on`，传入 `amd_iommu=on` 会触发 `AMD-Vi: Unknown option - 'on'`）；`iommu=pt` 将宿主机默认域设为 Passthrough，消除日常 DMA 转换开销并保留 KVM 直通分组                                                                                                                                                                       |
| `pcie_aspm=off`                                 | 全局禁用 OS 层 PCIe ASPM（避免通过 ACPI `_OSC` 接管或开启 B450 芯片组桥 ASPM），与 Renoir CPU 根端口（`00:01.1`/`00:02.1`/`00:02.2` 均不支持 ASPM）及 BIOS `ASPM Support = Disabled` 保持一致                                                                                                                                                                                                                     |
| `nvme_core.default_ps_max_latency_us=20000`     | 将 WD PC SN810 NVMe（`15b7:5011`）的 APST 最大允许切换延迟限制为 `20000 us`（20 ms），保留 100 ms 空闲进入的 `PS3` 低功耗态（`0.025 W`，进出总延迟 `15 ms`），屏蔽进出延迟达 `49.6 ms` 的深度断电态 `PS4`（`0.0035 W`），消除在 Renoir `00:02.2` 根端口上唤醒时的 PCIe `CESta: Timeout+`（Replay Timer Timeout）可纠正错包                                                                                        |
| `amdgpu.aspm=0`                                 | 禁用显卡侧 PCIe ASPM，与 Renoir 根端口（`00:01.1` `ASPM not supported`）对齐，消除 `BadTLP`/`BadDLLP` 可纠正链路错包                                                                                                                                                                                                                                                                                              |
| `amdgpu.runpm=0`                                | 禁用 BACO Runtime PM（`runtime pm is manually disabled`），防止台式机独显反复进出 BACO 状态引发 SMU7 固件失联                                                                                                                                                                                                                                                                                                     |
| `amdgpu.bapm=0`                                 | 禁用双向应用电源管理（BAPM）                                                                                                                                                                                                                                                                                                                                                                                      |
| `amdgpu.dcdebugmask=0x2`                        | 置位 `DC_DISABLE_STUTTER`（`0x2`），禁用 DCE 11.2 DMIF 显存接口 Stutter 模式，规避 4K 输出下 `dce_mi_free_dmif` 寄存器等待超时                                                                                                                                                                                                                                                                                    |
| `amdgpu.ppfeaturemask=0xfff5baf3`               | 在默认掩码 `0xfff7bfff` 基础上精确清除 `0x2050c`，保留 `SCLK_DPM`/`MCLK_DPM` 与 32 W `POWER_CONTAINMENT`，仅关闭易引发链路降速与锁死的 `PP_PCIE_DPM_MASK`（`0x4`）、`PP_SCLK_DEEP_SLEEP_MASK`（`0x8`）、`PP_ULV_MASK`（`0x100`）、`PP_CLOCK_STRETCH_MASK`（`0x400`）与 `PP_STUTTER_MODE`（`0x20000`）                                                                                                             |
| `amdgpu.lockup_timeout=60000,60000,10000,10000` | 将 `[GFX,Compute,SDMA,Video]` 超时设为 `60s,60s,10s,10s`。GFX8（Polaris）的 `ring gfx` 不支持命令缓冲区中段抢占（MCBP），而 Mesa RADV 默认将 Vulkan Compute 队列（如 `memtest_vulkan`）路由至 Queue Family 0（`ring gfx`）；将 `gfx_timeout` 从默认 `10000 ms` 提升至与 `compute_timeout` 一致的 `60000 ms`，可避免长耗时 Vulkan 计算批次（如 `memtest_vulkan` 5 分钟后的扩展测试）误触发 10.24 秒 TDR 看门狗中断 |

## 故障排查历史与压力测试备忘

### 1. 现象与根因复盘

1. **安装环境（Linux `6.18.60`）与首次烤机挂死**：
   - 未调优前，在持续 `glmark2-wayland` 负载下出现 `ring gfx timeout`、`dce_mi_free_dmif` 超时及 `last message was failed ret is 0`（SMU7 固件无响应），连续数十次 BACO 重置后触发 `SMU Firmware start failed! / GPU Recovery Failed: -22`。
   - 检查 `lspci -s 01:00.0 -vv` 发现 PCIe AER 寄存器出现 `CESta: BadTLP+ BadDLLP+` 与 `Status: <MAbort+`，且链路从 `8 GT/s x8` 降级为 `2.5 GT/s x8`。
   - **解决效果**：应用 `amdgpu.aspm=0`、`amdgpu.runpm=0`、`amdgpu.bapm=0`、`amdgpu.dcdebugmask=0x2` 与 `amdgpu.ppfeaturemask=0xfff5baf3` 后，待机功耗由 23–26 W（72–76°C）降至 **13–14 W（56–58°C）**，满载稳定在 **31.2 W / 83–84°C**，PCIe 链路稳定保持 `8 GT/s x8`（`BadTLP- BadDLLP-`），在 `glmark2-wayland` + `memtest_vulkan` + `stress` 三项满载并发下连续运行 **超过 8.5 小时（完成 4,902 万+ 次 GFX fence 与 304,039 轮显存校验）零硬件错包**。
2. **三项压测并发时 `memtest_vulkan` 触发 `ring gfx timeout` 及假阳性报错（`487%` / `shader execution is broken`）的原因**：
   - `memtest_vulkan` 在 RADV 下通过 Queue Family 0（`ring gfx`）提交计算着色器，与 `glmark2-wayland` 的全屏 OpenGL 渲染共用同一个不支持中段抢占（MCBP）的 `ring gfx` 硬件队列，加之 `stress` 占满 CPU 调度。
   - 在默认 `gfx_timeout = 10000 ms`（`2560 jiffies = 10.24s`）下，当 `memtest_vulkan` 大工作量扩展轮次与 `glmark2-wayland` 并发排队超过 10.24 秒时被内核看门狗判定超时：
     - 首次超时触发一次 BACO Reset（在当前稳定性参数下仅耗时 1.45 秒即干净完成 `GPU reset(1) succeeded!`，未再发生 SMU 锁死，但重置会清空显存状态：`[drm] VRAM is lost due to GPU reset!`）；
     - 随后每隔精确的 **10.24 秒**（`31396.63s → 31406.87s → 31417.11s → 31427.35s`），看门狗触发 `gfx_v8_0_ring_soft_recovery`（向 `mmSQ_CMD` 发送波前终止指令），GPU 在 **230 微秒** 内立即终止波前并恢复（`ring gfx timeout, but soft recovered`）。
     - 由于 BACO Reset 清空了 VRAM 且 `mmSQ_CMD` 强行杀死了正在执行的计算着色器波前，`memtest_vulkan` 读回了被重置破坏的统计缓冲区（表现为错误率高达荒谬的 `487.03%`、越界地址 `0x3EF41E864`、乱码迭代号 `2310192855`），并最终由自检机制抛出 `Runtime error: unexpected calculated value, maybe shader execution is broken`。这并非 GDDR5 显存物理位翻转，而是 TDR 重置/波前强杀导致的着色器执行中断。
   - **解决措施**：新增 `amdgpu.lockup_timeout=60000,60000,10000,10000` 将 `ring gfx` 超时与 `ring comp`（60 秒）对齐，同时**压测时应将 `memtest_vulkan`（显存/Compute 满载）与 `glmark2-wayland`（OpenGL 渲染满载）分开独立运行**，避免在单一非抢占 `ring gfx` 队列上互相阻塞。

### 2. 预装压力测试与监控工具（[tuning.nix](tuning.nix)）

本机已通过 `workstation.userPackages` 为 `mingcheng` 账户预装以下开源压测与监控工具：

```bash
# 1. AMDGPU 实时功耗、频率、电压、温度与引擎负载监控（支持 TUI 与 GUI）
amdgpu_top
amdgpu_top --gui

# 2. Wayland OpenGL 连续渲染压力测试（长时烤机建议配合 systemd-inhibit 防止桌面自动休眠）
systemd-inhibit --what=idle:sleep --why="glmark2 burn-in" glmark2-wayland --run-forever --fullscreen

# 3. Vulkan 图形基准与压力测试
vkmark

# 4. Vulkan GDDR5 显存完整性压力测试（建议单独运行，前 5 分钟为标准测试，之后进入扩展测试）
memtest_vulkan

# 5. CPU / 内存综合压力测试与终端曲线监控
s-tui
stress-ng --cpu 16 --cpu-method matrixprod --vm 4 --vm-bytes 75% --timeout 10m --metrics-brief
```

### 3. 日常健康检查命令

```bash
# 核对内核参数与 AMDGPU 实时电源/时钟状态
cat /proc/cmdline
sudo cat /sys/kernel/debug/dri/1/amdgpu_pm_info

# 检查 PCIe 链路速率（应为 Speed 8GT/s, Width x8）与 AER 错误计数（CESta/UESta 应全为 -）
sudo lspci -s 01:00.0 -vv | grep -E 'Status:|DevSta:|LnkCap:|LnkSta:|UESta:|CESta:'

# 检查内核是否有任何 AMDGPU / DRM 超时或重置记录
sudo dmesg -T | grep -Ei 'amdgpu.*(fault|timeout|reset|error)|\[drm\].*error'
```

### 4. 主板 WMI 模块与传感器已知固件误报说明（`asus_wmi_sensors`）

ROG STRIX B450-I GAMING 的 BIOS 暴露了通用华硕 WMI GUID `ABBC0F72-8EA1-11D1-00A0-C90629100000`（`SFUN=0x0`），默认会误触发内核加载早期华硕笔记本热键驱动 `eeepc_wmi` 与 `asus_wmi`（衍生出无用的 `Eee PC WMI hotkeys` 输入设备与空白 `hwmon` 节点）。[kernel.nix](kernel.nix) 已通过 `boot.blacklistedKernelModules` 屏蔽 `eeepc_wmi` 与 `asus_wmi`，并显式加载仅依赖 `wmi` 的桌面主板传感器驱动 `asus_wmi_sensors`。

在执行 `sensors` 时，`asus_wmi_sensors-virtual-0` 显示的两项异常读数属于 **ROG STRIX B450-I GAMING 主板 WMI 固件接口的已知缺陷**（在 Windows HWiNFO / AIDA64 的 WMI 读数中同样存在），**并非电源或温度硬件故障**：

- `+12V Voltage: ~9.81 V`：主板 Super I/O 转换至 WMI 表时的比例因子错误，真实 +12V 供电可在 BIOS Monitor 页面直接查看（正常为 `12.0V–12.1V`）。
- `Tsensor 1 Temperature: +216.0°C`：主板 `T_SENSOR1` 2-pin 温控探头跳线未接物理热敏电阻时的悬空开路读数。
