#!/usr/bin/env bash
dd if=/dev/zero of=encrypted_container.img bs=1M count=2048
LOOP_DEV=$(losetup -f)
losetup $LOOP_DEV encrypted_container.img
cryptsetup luksFormat $LOOP_DEV
cryptsetup luksOpen $LOOP_DEV exfat_crypt
mkfs.exfat /dev/mapper/exfat_crypt
mkdir -p /mnt/encrypted_exfat
mount /dev/mapper/exfat_crypt /mnt/encrypted_exfat
chown $(id -u):$(id -g) /mnt/encrypted_exfat