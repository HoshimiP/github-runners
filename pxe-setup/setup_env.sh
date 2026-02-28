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
shell_info "setup_env finished."