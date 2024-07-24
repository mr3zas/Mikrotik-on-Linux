##!/bin/bash -e

# Clear Page
clear


# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo
echo -e "${RED}=== ${GREEN}MikroTik${RED} CHR Installer ${GREEN}by mr3zas ${NC}==="
echo




# Prompt user for MikroTik CHR download link
read -p "Please enter the MikroTik CHR download link or press Enter to install default version: " download_link

# Use the default link if none is provided
if [ -z "$download_link" ]; then
    download_link="https://download.mikrotik.com/routeros/7.8/chr-7.8.img.zip"
fi

echo "Using download link: $download_link"

sleep 3

# Download the specified or default link
wget "$download_link" -O chr.img.zip
if [ $? -ne 0 ]; then
    echo "Failed to download the image."
    exit 1
fi

# Unzip the downloaded file
gunzip -c chr.img.zip > chr.img
if [ $? -ne 0 ]; then
    echo "Failed to unzip the image."
    exit 1
fi

# Setup loop device
loopdev=$(losetup -f --show chr.img)
if [ $? -ne 0 ]; then
    echo "Failed to setup loop device."
    exit 1
fi

# Map partitions
kpartx -av $loopdev
if [ $? -ne 0 ]; then
    echo "Failed to map partitions."
    losetup -d $loopdev
    exit 1
fi

# Mount the first partition of the image
mount /dev/mapper/$(basename $loopdev)p1 /mnt
if [ $? -ne 0 ]; then
    echo "Failed to mount the image."
    kpartx -dv $loopdev
    losetup -d $loopdev
    exit 1
fi

# List the contents of the mounted image
echo "Listing contents of the mounted image:"
ls -l /mnt

# Get the IP address and gateway
# Adjusting interface name check for OVH
ADDRESS=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -n 1)
GATEWAY=$(ip route | grep default | awk '{print $3}')

if [ -z "$ADDRESS" ] || [ -z "$GATEWAY" ]; then
    echo "Failed to retrieve network information."
    umount /mnt
    kpartx -dv $loopdev
    losetup -d $loopdev
    exit 1
fi

# Create the autorun script
AUTORUN_PATH="/mnt/rw/autorun.scr"
if [ ! -d "/mnt/rw" ]; then
    AUTORUN_PATH="/mnt/autorun.scr"
fi

cat <<EOF > $AUTORUN_PATH
/ip address add address=$ADDRESS interface=[/interface ethernet find where name=ether1]
/ip route add gateway=$GATEWAY
/ip service disable telnet
/user set 0 name=root password=xxxxxx
EOF

if [ $? -ne 0 ]; then
    echo "Failed to create autorun script."
    umount /mnt
    kpartx -dv $loopdev
    losetup -d $loopdev
    exit 1
fi

# Sync and write the image to the disk
echo u > /proc/sysrq-trigger
dd if=chr.img bs=1024 of=/dev/sda
if [ $? -ne 0 ]; then
    echo "Failed to write the image to disk."
    umount /mnt
    kpartx -dv $loopdev
    losetup -d $loopdev
    exit 1
fi

echo "sync disk"
sync

# Unmount the image
umount /mnt

# Clean up
kpartx -dv $loopdev
losetup -d $loopdev

# Trigger reboot
echo s > /proc/sysrq-trigger
echo "Sleeping for 5 seconds..."
sleep 5
echo "Rebooting..."
echo b > /proc/sysrq-trigger
