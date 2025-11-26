#!/usr/bin/env bash
set -e

echo "Installing tools..."
sudo apt update
sudo apt install -y ethtool net-tools lsb-release

echo "Checking interface..."
ip link

read -p "Enter your wired interface (e.g., enp7s0): " IFACE

echo "Showing current WoL state:"
sudo ethtool $IFACE | grep Wake-on

echo "Enabling WoL via NetworkManager..."
sudo nmcli connection modify "$IFACE" 802-3-ethernet.wake-on-lan magic

echo "Optional: Add SecureOn password:"
read -p "Enter SecureOn password (6-byte hex, or empty to skip): " WOLPWD

if [ ! -z "$WOLPWD" ]; then
    sudo nmcli connection modify "$IFACE" 802-3-ethernet.wake-on-lan-password "$WOLPWD"
fi

echo "Restarting NetworkManager..."
sudo systemctl restart NetworkManager

echo "Final WoL config:"
nmcli connection show "$IFACE" | grep -i wake

echo "Done."
