#!/bin/bash
set -e
source "$(dirname "$0")/common.sh"

shell_info "Running configure_pxe..."

configure_dnsmasq() {
    shell_info "Configure dnsmasq DHCP/TFTP services..."

    # 创建 dnsmasq 配置目录
    mkdir -p /etc/dnsmasq.d

    # 生成 PXE 配置文件
    cat > /etc/dnsmasq.d/pxe.conf << EOF
port=0

interface=$DHCP_INTERFACE
bind-interfaces

dhcp-range=$DHCP_START,$DHCP_END,$DHCP_LEASE_TIME

dhcp-option=3,$GATEWAY
dhcp-option=6,$DNS_SERVER

dhcp-boot=undionly.kpxe

pxe-service=x86PC, "iPXE", boot.ipxe

enable-tftp
tftp-root=$TFTP_ROOT
EOF

    shell_info "Configuration completed"
    shell_info "Configuration file location: /etc/dnsmasq.d/pxe.conf"
}

download_ipxe() {
    shell_info "Downloading iPXE boot files..."
    mkdir -p "$TFTP_ROOT"
    wget -q -O "$TFTP_ROOT/undionly.kpxe" https://boot.ipxe.org/undionly.kpxe || shell_die "Failed to download iPXE boot files"
    chmod 644 "$TFTP_ROOT/undionly.kpxe"
    shell_info "iPXE boot files downloaded: $TFTP_ROOT/undionly.kpxe"
}

create_ipxe_script() {
    shell_info "Creating iPXE boot script..."

    cat > "$IPXE_SCRIPT" << 'EOF'
#!ipxe

echo "PXE Boot Started"
echo "Server: ${next-server}"

echo "Loading kernel from TFTP..."
kernel tftp://${next-server}/kernel

boot
EOF

    chmod 644 "$IPXE_SCRIPT"
    shell_info "iPXE boot script created: $IPXE_SCRIPT"
    shell_info ""
    shell_info "iPXE boot script content (modify as needed):"
    cat "$IPXE_SCRIPT"
}

start_services() {
    shell_info "Starting services..."

    systemctl stop dnsmasq 2>/dev/null || true

    systemctl start dnsmasq
    systemctl enable dnsmasq

    shell_info "Services started successfully"
}

configure_dnsmasq
download_ipxe
create_ipxe_script
start_services

shell_info "configure_pxe finished."