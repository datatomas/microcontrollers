# List USB devices to confirm the Pico is detected
lsusb

# Show block devices and mountpoints (helps find the RPI-RP2 drive in BOOTSEL mode)
lsblk -o NAME,SIZE,MODEL,MOUNTPOINT

# Flash the Pico by copying the UF2 firmware to the RPI-RP2 mountpoint
cp "pathtoyourfile/RPI_PICO_W-20250911-v1.26.1.uf2" /media/user/RPI-RP2

# Check recent kernel messages to see if the device mounted correctly
dmesg | tail

# Find the serial port (used by Thonny/mpremote). Usually /dev/ttyACM0
dmesg | grep -i tty

# Add your user to the 'dialout' group so you can access /dev/ttyACM0 without sudo
sudo usermod -aG dialout $USER

# Confirm that you're in the dialout group (you MUST log out and back in first)
groups
