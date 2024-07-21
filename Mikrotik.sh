#!/bin/bash -e

echo
echo "=== MikroTik CHR Installer by mr3zas ==="
echo

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
gunzip -c chr.img.zip > chr.img && \
mount -o loop,offset=512 chr.img /mnt && \
ADDRESS=`ip addr show eth0  | grep global | cut -d' ' -f 6 | head -n 1` && \
GATEWAY=`ip route list | grep default | cut -d' ' -f 3` && \
echo "/ip address add address=$ADDRESS interface=[/interface ethernet find where name=ether1]
/ip route add gateway=$GATEWAY
/ip service disable telnet
/user set 0 name=root password=xxxxxx" > /mnt/rw/autorun.scr && \
echo u > /proc/sysrq-trigger && \
dd if=chr.img bs=1024 of=/dev/sda && \
echo "sync disk" && \
echo s > /proc/sysrq-trigger && \
echo "Sleep 5 seconds" && \
sleep 5 && \
echo "Ok, reboot" && \
echo b > /proc/sysrq-trigger
