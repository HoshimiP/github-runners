# PXE 网络启动配置

## 简介

本工具用于自动部署基于 PXE 的测试固件加载服务。

## 快速开始

### 前置条件

确保 dnsmasq 主配置文件已启用子配置目录：

```bash
# 检查是否已启用
grep "^conf-dir=" /etc/dnsmasq.conf
```

如果上述命令无输出，请参考 [故障排查](#dnsmasq-主配置文件启用子配置目录) 部分进行配置。

### 初始化 PXE 服务

```bash
# 自动检测网络接口并配置 PXE 服务
./runner.sh pxe
```

该命令会：
1. 自动检测主机的默认网络接口
2. 安装 dnsmasq
3. 配置 DHCP/TFTP 服务
4. 下载并配置 iPXE 引导文件
5. 启动 dnsmasq 服务

### 清理 PXE 服务

```bash
# 停止并清理 PXE 配置
./runner.sh pxe cleanup
```

## 环境变量配置

可以通过设置环境变量来自定义 PXE 配置：

### 网络接口配置

```bash
# 指定网络接口（默认：自动检测）
export NETWORK_INTERFACE=eth0

# 指定 DHCP 服务监听的接口（默认：与 NETWORK_INTERFACE 相同）
export DHCP_INTERFACE=eth0
```

### 服务器配置

```bash
# PXE 服务器 IP（默认：192.168.1.200）
export PXE_SERVER_IP=192.168.1.200

# 网关地址（默认：192.168.1.1）
export GATEWAY=192.168.1.1

# DNS 服务器（默认：8.8.8.8）
export DNS_SERVER=8.8.8.8
```

### DHCP 配置

```bash
# DHCP 地址池起始地址（默认：192.168.1.100）
export DHCP_START=192.168.1.100

# DHCP 地址池结束地址（默认：192.168.1.150）
export DHCP_END=192.168.1.150

# DHCP 租约时间（默认：12h）
export DHCP_LEASE_TIME=12h
```

### TFTP 配置

```bash
# TFTP 根目录（默认：/var/lib/tftpboot）
export TFTP_ROOT=/var/lib/tftpboot

# iPXE 引导脚本路径（默认：$TFTP_ROOT/boot.ipxe）
export IPXE_SCRIPT=/var/lib/tftpboot/boot.ipxe
```

## 配置示例

### 示例 1：基本配置

```bash
# 使用默认配置启动 PXE 服务
./runner.sh pxe
```

### 示例 2：自定义网络配置

```bash
# 设置自定义网络配置
export NETWORK_INTERFACE=enp0s3
export DHCP_START=192.168.10.100
export DHCP_END=192.168.10.200
export GATEWAY=192.168.10.1

# 启动 PXE 服务
./runner.sh pxe
```

## 自定义 iPXE 引导脚本

默认的 iPXE 引导脚本位于 `$TFTP_ROOT/boot.ipxe`。可以根据需要修改此文件：

```bash
# 编辑 iPXE 脚本
sudo vim /var/lib/tftpboot/boot.ipxe
```

示例 iPXE 脚本：

```ipxe
#!ipxe

echo "PXE Boot Started"
echo "Server: ${next-server}"

echo "Loading kernel from TFTP..."
kernel tftp://${next-server}/kernel

boot
```

## 故障排查

### 检查服务状态

```bash
# 查看 dnsmasq 服务状态
sudo systemctl status dnsmasq

# 查看 dnsmasq 日志
sudo journalctl -u dnsmasq
```

### 检查配置文件

```bash
# 查看 PXE 配置
cat /etc/dnsmasq.d/pxe.conf

# 查看 iPXE 脚本
cat /var/lib/tftpboot/boot.ipxe
```

### 网络测试

```bash
# 检查网络接口
ip addr show

# 检查路由
ip route

# 测试 TFTP 服务
tftp localhost -c get undionly.kpxe
```

### 常见问题

1. **权限不足**
   - 解决方案：确保以 root 权限运行，或使用 sudo

2. **端口被占用**
   - 解决方案：检查是否有其他 DHCP 服务在运行
   ```bash
   sudo systemctl stop isc-dhcp-server
   sudo systemctl disable isc-dhcp-server
   ```

3. **网络接口未找到**
   - 解决方案：使用 `ip link show` 查看可用接口，手动设置 `NETWORK_INTERFACE`

4. **dnsmasq 主配置文件启用子配置目录**
   
   为了使 PXE 子配置文件 `/etc/dnsmasq.d/pxe.conf` 生效，需要确保 dnsmasq 主配置文件启用了子配置目录。

   **手动启用：**

   ```bash
   # 编辑 dnsmasq 主配置文件
   sudo vim /etc/dnsmasq.conf
   ```

   查找并取消注释以下行（通常在文件的后半部分）：

   ```bash
   # 取消注释这一行
   conf-dir=/etc/dnsmasq.d/,*.conf
   ```

   # 验证配置
   grep "^conf-dir=" /etc/dnsmasq.conf

   # 重启 dnsmasq 服务使配置生效
   sudo systemctl restart dnsmasq
   ```

   如果未启用子配置目录，`/etc/dnsmasq.d/pxe.conf` 中的配置将被忽略。

## 目录结构

```
pxe-setup/
├── common.sh           # 公共变量和日志函数
├── setup_env.sh        # 环境初始化脚本
├── configure_pxe.sh    # PXE 配置脚本
└── cleanup.sh          # 清理脚本
```

## 注意事项

1. PXE 服务需要 root 权限运行
2. 确保网络接口配置正确，避免与现有 DHCP 服务冲突
3. 修改配置后需要重新运行 `./runner.sh pxe` 以应用更改

## 参考资料

- [x86 架构测试方案](https://github.com/orgs/arceos-hypervisor/discussions/347)
