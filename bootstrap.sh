#!/bin/sh

ts=`date +%Y%m%d%H%M%S`
lv="arch-bootstrap-$ts"
vg=vg0
lv_size=3G
lv_dev="/dev/$vg/$lv"
raw_file_size=3G
raw_file="./$lv"

truncate -s $raw_file_size $raw_file
mkfs.ext4 -L root $raw_file

mount -o loop $raw_file /mnt

pacstrap /mnt base base-devel

genfstab -p /mnt >> /mnt/etc/fstab
perl -pi -e 's/\/dev\/loop\d+/LABEL=root/' /mnt/etc/fstab

echo "arch-minimal" > /mnt/etc/hostname
echo "127.0.1.1	arch-minimal" >> /mnt/etc/hosts
echo "::1	arch-minimal" >> /mnt/etc/hosts

arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

#
# LOCALES
#
echo "de_DE.UTF-8" >> /mnt/etc/locale.gen
echo "en_US.UTF-8" >> /mnt/etc/locale.gen

arch-chroot /mnt locale-gen

echo "LANG=de_DE.UTF-8" > /mnt/etc/locale.conf
cat > /mnt/etc/vconsole.conf <<EOF
KEYMAP=de-latin1
FONT=lat9w-16
EOF

#
# MAKE SURE WE CAN BOOT FROM AN LVM VOLUME
#
perl -pi -e 's/(HOOKS=.+)"/$1 lvm2"/' /mnt/etc/mkinitcpio.conf

arch-chroot /mnt mkinitcpio -p linux

#
# SYSLINUX BOOT LOADER
#
arch-chroot /mnt pacman -Syy --noconfirm syslinux
cp -av /mnt/usr/lib/syslinux/bios/* /mnt/boot/syslinux/
arch-chroot /mnt extlinux --install /boot/syslinux/
cp boot/arch.png boot/syslinux.cfg /mnt/boot/syslinux/

cat > /mnt/etc/netctl/ens3 <<EOF
Interface=ens3
Connection=ethernet
IP=dhcp
EOF

#
# FINISH THINGS UP WITH A CHROOT RUN
#
install -d /mnt/bootstrap
cp chroot.sh /mnt/bootstrap/
cp -a vim /mnt/bootstrap/

chmod 755 /mnt/bootstrap/chroot.sh
arch-chroot /mnt /bootstrap/chroot.sh
