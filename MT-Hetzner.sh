#!/bin/bash -e

# Clear Page
clear

echo
echo "=== MikroTik CHR Installer by mr3zas ==="
echo

#

# Ask the user to enter the new download link
read -p "Please enter the MikroTik CHR download link or press Enter to install default version : " download_link

# If no link is entered, use the default link
if [ -z "$download_link" ]; then
    download_link="https://download.mikrotik.com/routeros/7.8/chr-7.8.img.zip"
fi

echo "Using download link: $download_link"

sleep 3

# Download the specified or default link
wget "$download_link" -O chr.img.zip && \
gunzip -c chr.img.zip > chr.img

# Verify the image was extracted correctly
if [ ! -f chr.img ]; then
    echo "Error: chr.img file not found after extraction."
    exit 1
fi

# Set network interface and disk device based on provided information
INTERFACE="eth0"
DISK="/dev/sda"

# Identify IP address
ADDRESS=$(ip addr show $INTERFACE | grep 'inet ' | awk '{print $2}' | head -n 1)

# Verify the IP address was found
if [ -z "$ADDRESS" ]; then
    echo "Error: No IP address found for interface $INTERFACE."
    exit 1
fi

# Identify gateway
GATEWAY=$(ip route list | grep default | awk '{print $3}')

# Verify the gateway was found
if [ -z "$GATEWAY" ]; then
    echo "Error: No default gateway found."
    exit 1
fi

# Set up the loop device
LOOP_DEVICE=$(losetup -f --show chr.img)

# Verify the loop device was created
if [ -z "$LOOP_DEVICE" ]; then
    echo "Error: Failed to set up loop device."
    exit 1
fi

# Calculate the offset for the first partition
OFFSET=$((34 * 512))

# Attempt to mount the first partition
mount -o loop,offset=$OFFSET $LOOP_DEVICE /mnt

# Verify the mount was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to mount the loop device."
    losetup -d $LOOP_DEVICE
    exit 1
fi

# Debugging: Check the contents of the mounted directory
echo "Mounted directory contents:"
ls -l /mnt

# Clean up mount point
umount /mnt
losetup -d $LOOP_DEVICE

# Write the image directly to the disk
echo "Writing image to disk $DISK"
dd if=chr.img bs=1024 of=$DISK

# Ensure the disk is synced
echo "Syncing disk"
sync

# Notify about reboot
echo "Image written to $DISK. Rebooting now..."

# Reboot the system
reboot
