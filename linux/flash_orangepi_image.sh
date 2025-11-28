#!/usr/bin/env bash
#
# Flash an Orange Pi image to a microSD card using dd.
#
# Usage:
#   sudo ./flash_orangepi_image.sh /path/to/image.img /dev/sdX
#
# Example:
#   sudo ./flash_orangepi_image.sh Orangepi5pro_ubuntu_server.img /dev/sda
#
# WARNING: This will ERASE everything on the target device.

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: sudo $0 /path/to/image.img /dev/sdX"
  exit 1
fi

IMG="$1"
DEV="$2"

echo ">>> Listing block devices (before):"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT

echo
read -rp ">>> CONFIRM: Flash '$IMG' to '$DEV'? This will WIPE it. [yes/NO] " ans
[[ "$ans" == "yes" ]] || { echo "Aborted."; exit 1; }

echo ">>> Unmounting any mounted partitions on $DEV..."
sudo umount "${DEV}"* || true

echo ">>> Flashing image with dd..."
sudo dd if="$IMG" of="$DEV" bs=4M conv=fsync,status=progress

echo ">>> Forcing kernel to re-read partition table..."
sudo partprobe "$DEV" || true

echo ">>> Listing block devices (after):"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT "$DEV"

echo "Done. You can now eject the card and boot the Orange Pi from it."
