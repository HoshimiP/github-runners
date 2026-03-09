#!/bin/bash
set -e

shell_die() { echo "[ERROR] $*" >&2; exit 1; }
shell_info() { echo "[INFO] $*"; }
shell_warn() { echo "[WARN] $*" >&2; }

# 网络接口配置
NETWORK_INTERFACE="${NETWORK_INTERFACE:-eth0}"
DHCP_INTERFACE="${DHCP_INTERFACE:-$NETWORK_INTERFACE}"  # DHCP 服务监听的接口，默认使用主接口

# 服务器配置
PXE_SERVER_IP="${PXE_SERVER_IP:-192.168.1.200}"
GATEWAY="${GATEWAY:-192.168.1.1}"
DNS_SERVER="${DNS_SERVER:-8.8.8.8}"

# DHCP 配置
DHCP_START="${DHCP_START:-192.168.1.100}"
DHCP_END="${DHCP_END:-192.168.1.150}"
DHCP_LEASE_TIME="${DHCP_LEASE_TIME:-12h}"

# TFTP 配置
TFTP_ROOT="${TFTP_ROOT:-/var/lib/tftpboot}"
IPXE_SCRIPT="${IPXE_SCRIPT:-$TFTP_ROOT/boot.ipxe}"

# 是否加载内核到 QEMU 中进行测试
QEMU="${QEMU:-false}"