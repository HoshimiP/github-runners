#!/bin/bash
set -e
source "$(dirname "$0")/common.sh"

check_interface() {
    if ! ip link show "$NETWORK_INTERFACE" > /dev/null 2>&1; then
        shell_info "Available interfaces:"
        ip link show | grep "^[0-9]" | awk '{print "  - " $2}'
        shell_die "Network interface $NETWORK_INTERFACE does not exist"
    fi
}

set_tap_interface() {
    if [ "$QEMU" = "true" ]; then
        if ! ip link show tap-runner-pxe > /dev/null 2>&1; then
            shell_info "Creating tap-runner-pxe interface for QEMU..."
            ip tuntap add dev tap-runner-pxe mode tap multi_queue user "$(whoami)"
            ip link set tap-runner-pxe up
            ip addr add "$PXE_SERVER_IP"/24 dev tap-runner-pxe
            shell_info "tap-runner-pxe interface created and set up."
        else
            shell_info "tap-runner-pxe interface already exists."
        fi
    fi
}

install_dependencies() {
    shell_info "Updating package list..."
    apt-get update

    shell_info "Installing dependencies..."
    apt-get install -y dnsmasq  > /dev/null 2>&1

    shell_info "Dependencies installed successfully"
}

setup_tftp_root() {
    shell_info "Creating TFTP root directory..."

    mkdir -p "$TFTP_ROOT"

    chmod 755 "$TFTP_ROOT"

    shell_info "TFTP root directory created: $TFTP_ROOT"
}

shell_info "Running setup_env..."
install_dependencies
setup_tftp_root
set_tap_interface
shell_info "setup_env finished."