#!/bin/bash
set -e
source "$(dirname "$0")/common.sh"

cleanup() {
    shell_info "stopping dnsmasq..."
    systemctl stop dnsmasq 2>/dev/null || true
    systemctl disable dnsmasq 2>/dev/null || true

    # 移除配置文件
    shell_info "Removing dnsmasq configuration..."
    rm -f /etc/dnsmasq.d/pxe.conf
    
    shell_info "Removing tap interface if exists..."
    ip link delete tap-runner-pxe 2>/dev/null || true

    # 清理 TFTP 根目录
    # rm -rf "$TFTP_ROOT" 2>/dev/null || true
}

cleanup