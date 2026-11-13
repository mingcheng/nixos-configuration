# QEMU 虚拟机镜像 (`vm-image`)

面向 **QEMU / KVM / Libvirt** 虚拟化环境的无头（Headless）客户机配置（`NIX_BUILD_HOST=vm-image`）。基于 [profiles/network.nix](../../profiles/network.nix) 与 NixOS 官方 `qemu-guest.nix`、`disk-image.nix` 模块，可直接通过 [scripts/build-qcow2.sh](../../scripts/build-qcow2.sh) 编译为可引导的 `.qcow2` 磁盘镜像。

通用仓库结构、通道说明与自定义选项请参阅根目录 [README.md](../../README.md)。

## 默认配置概览

| 类别               | 默认策略与组件                                                                                                                                                 |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 镜像格式           | `qcow2`（`image.format = "qcow2"`），磁盘容量默认按闭包自适应（`virtualisation.diskSize = "auto"`），精简 HTML/Info 文档以缩减镜像体积                         |
| 引导与分区         | 默认 UEFI `systemd-boot`（ESP `/boot` `0700` 权限挂载 + `ext4` `/` 自动扩容 `boot.growPartition`，保留最近 5 个生成项）；支持切换为带串口菜单的 Legacy GRUB    |
| 主机名策略         | 默认留空静态主机名，首次启动由 `vm-random-hostname.service` 生成形如 `vm-<8位十六进制>` 的随机主机名并持久化至 `/etc/hostname`                                 |
| 虚拟化与容器       | 预加载 `virtio_*` 驱动并启用 `services.qemuGuest.enable`、`fstrim`；默认启用 [services/docker.nix](../../services/docker.nix) 与 `docker-compose`              |
| 软件源与非自由软件 | 允许非自由软件（`nixpkgs.config.allowUnfree = true`），默认配置中国大陆二进制缓存（TUNA/USTC/SJTU/CERNET）、TUNA 默认通道及 Go/npm/PyPI/uv/Cargo/Rustup 镜像源 |
| 控制台与网络       | 同时启用图形与串口控制台（`console=tty0`、`console=ttyS0,115200n8`），启用 BBR 拥塞控制、大陆 NTP 授时与快速 IPv4 DHCP（`noarp`，忽略容器虚拟网卡）            |
| 远程与工具         | 默认启用 [services/sshd.nix](../../services/sshd.nix)（仅公钥登录，严禁 root 与空密码 SSH 登录），预装 `git`、`neovim`、`tmux`、`bat`、网络调试工具集（`mtr`、`tcpdump`、`nmap`、`iperf3`、`socat`、`ethtool`、`dig`、`nc` 等）与系统诊断工具集（`htop`、`btop`、`lsof`、`sysstat`、`jq`、`yq`、`ripgrep`、`fd`、`pciutils` 等） |
| 账户与权限         | `root` 初始密码为空（仅限本地/串口控制台登录）；预置 `mingcheng` 普通账户（`wheel`、`docker` 组），严禁安装任何 GUI 软件                                       |

## 本地自定义配置（`local.nix`）

为避免将密码哈希、SSH 公钥等敏感信息提交至 Git，`hosts/vm-image/local.nix` 已被加入 [.gitignore](../../.gitignore)。当该文件存在时，[hosts/vm-image/default.nix](default.nix) 会自动将其导入（也可通过 `scripts/build-qcow2.sh --config <file>` 指定任意外部模块文件）。

示例 `hosts/vm-image/local.nix`：

```nix
{ ... }:
{
  # 为 mingcheng 账户配置 SSH 公钥与初始密码（用于串口/控制台登录）
  users.users.mingcheng = {
    initialPassword = "change-me-on-first-boot";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAA... mingcheng@workstation"
    ];
  };

  # 如需从宿主机或局域网通过 SSH 连接，放行防火墙 22 端口
  services.openssh.openFirewall = true;
}
```

## 编译 `qcow2` 镜像

镜像构建仅依赖 `nixos` 稳定通道，无需配置 `unstable` 通道。

### 使用脚本构建（推荐）

[scripts/build-qcow2.sh](../../scripts/build-qcow2.sh) 会自动设置 `NIX_BUILD_HOST=vm-image` 与 `NIXPKGS_ALLOW_UNFREE=1`：

```bash
# 1. 默认构建（UEFI 引导、自动容量），在当前目录生成 ./result 软链接并输出 Store 内 qcow2 路径
bash scripts/build-qcow2.sh

# 2. 构建并导出为可写的 qcow2 文件（权限 0644，可直接挂载至 QEMU / Libvirt 读写运行）
bash scripts/build-qcow2.sh -o ./nixos-vm.qcow2

# 3. 指定磁盘大小（单位 MiB，例如 16 GiB = 16384）并附加自定义模块
bash scripts/build-qcow2.sh --disk-size 16384 --config ./my-vm.nix -o ./nixos-vm.qcow2

# 4. 构建 Legacy BIOS（GRUB /dev/vda）镜像（无需 OVMF 固件即可在 QEMU 直接启动）
bash scripts/build-qcow2.sh --legacy -o ./nixos-vm-legacy.qcow2

# 5. 仅求值并生成 .drv 推导路径（不实际执行镜像构建）
bash scripts/build-qcow2.sh --dry-run
```

> **提示**：`/nix/store` 内的 `.qcow2` 文件为只读（`0444`）。用于 QEMU 或 Libvirt 启动前，建议使用 `-o ./nixos-vm.qcow2` 导出可写副本，或基于 Store 镜像创建增量后端镜像：
> ```bash
> qemu-img create -f qcow2 -F qcow2 -b "$(bash scripts/build-qcow2.sh)" ./nixos-vm-overlay.qcow2 20G
> ```

## 启动与导入虚拟机

### 1. 使用 QEMU 直接启动

- **Legacy BIOS 镜像**（使用 `--legacy` 构建，无需额外 UEFI 固件）：

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -m 2048 \
  -smp 2 \
  -nographic \
  -drive file=./nixos-vm-legacy.qcow2,format=qcow2,if=virtio \
  -netdev user,id=net0,hostfwd=tcp:127.0.0.1:2222-:22 \
  -device virtio-net-pci,netdev=net0
```

- **UEFI 镜像**（默认构建，需配合 OVMF 固件）：

```bash
OVMF_DIR=$(nix-build '<nixpkgs>' -A OVMF.fd --no-out-link)
cp "$OVMF_DIR/FV/OVMF_VARS.fd" ./ovmf_vars.fd
chmod +w ./ovmf_vars.fd

qemu-system-x86_64 \
  -enable-kvm \
  -machine q35 \
  -m 2048 \
  -smp 2 \
  -nographic \
  -drive if=pflash,format=raw,readonly=on,file="$OVMF_DIR/FV/OVMF_CODE.fd" \
  -drive if=pflash,format=raw,file=./ovmf_vars.fd \
  -drive file=./nixos-vm.qcow2,format=qcow2,if=virtio \
  -netdev user,id=net0,hostfwd=tcp:127.0.0.1:2222-:22 \
  -device virtio-net-pci,netdev=net0
```

启动后如果已在 `local.nix` 中开启 `services.openssh.openFirewall = true;` 并写入公钥，可在宿主机通过以下命令连接：

```bash
ssh -p 2222 mingcheng@127.0.0.1
```

### 2. 导入 Libvirt / Virt-Manager

在宿主机（NixOS 启用 [services/libvirtd.nix](../../services/libvirtd.nix)，或 Debian/Ubuntu 安装 `qemu-system-x86 libvirt-daemon-system virtinst ovmf`）上，可将导出的可写 `.qcow2` 镜像放入 `/var/lib/libvirt/images/`，并在 `virt-manager` 中选择 **Import existing disk image**（芯片组选 `Q35`，固件选非 Secure Boot 的 `UEFI x86_64`；若为 `--legacy` 镜像则选 `BIOS`），或使用 `virt-install`（显式关闭 `secure-boot` 以引导未签名的 `systemd-boot`）：

```bash
virt-install \
  --name nixos-vm \
  --memory 2048 \
  --vcpus 2 \
  --cpu host-passthrough \
  --os-variant nixos-unstable \
  --boot uefi,firmware.feature0.name=secure-boot,firmware.feature0.enabled=no \
  --disk path=/var/lib/libvirt/images/nixos-vm.qcow2,format=qcow2,bus=virtio,discard=unmap \
  --network bridge=br0,model=virtio \
  --graphics none \
  --console pty,target_type=serial \
  --import \
  --noautoconsole
```

## 测试与检查

```bash
# 运行 vm-image 主机配置求值检查（含無 unstable 依赖验证）
make check-host-vm-image

# 运行 build-qcow2.sh 脚本参数与行为单元测试
make check-script-build-qcow2
```
