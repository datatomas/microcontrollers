#!/usr/bin/env bash
set -e

echo "=== Installing required tools ==="
sudo apt update
sudo apt install -y ethtool net-tools lsb-release

echo "=== Listing network interfaces ==="
ip link

read -p "Enter your wired interface (e.g., enp7s0): " IFACE

echo "=== Current WoL state ==="
sudo ethtool "$IFACE" | grep Wake-on || true

echo "=== Enabling WoL via NetworkManager ==="
sudo nmcli connection modify "$IFACE" 802-3-ethernet.wake-on-lan magic

read -p "Enter SecureOn password (6-byte hex, leave blank to skip): " WOLPWD
if [ ! -z "$WOLPWD" ]; then
    sudo nmcli connection modify "$IFACE" 802-3-ethernet.wake-on-lan-password "$WOLPWD"
fi

echo "Restarting NetworkManager..."
sudo systemctl restart NetworkManager

echo "=== Creating persistent systemd service ==="
ETHTOOL_PATH=$(which ethtool)

sudo bash -c "cat >/etc/systemd/system/wol.service" <<EOF
[Unit]
Description=Enable Wake-on-LAN for $IFACE
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=$ETHTOOL_PATH -s $IFACE wol g

[Install]
WantedBy=multi-user.target
EOF

echo "=== Reloading systemd ==="
sudo systemctl daemon-reload

echo "=== Enabling and starting WoL service ==="
sudo systemctl enable --now wol.service

echo "=== Testing service ==="
sudo systemctl status wol.service --no-pager

echo "=== Verifying final WoL state ==="
sudo ethtool "$IFACE" | grep Wake-on

echo "Show Wol Password"
nmcli connection show "netplan-yourconnectionname" | grep wake-on-lan-password

#show password
nmcli connection show "netplan-enp7s0" | grep wake-on-lan-password

#set new password
sudo nmcli connection modify "netplan-enp7s0" 802-3-ethernet.wake-on-lan-password A1:B2:C3:D4:E5:F6

#restart
sudo systemctl restart NetworkManager


echo "=== All done! WoL is now persistent across reboots. ==="

