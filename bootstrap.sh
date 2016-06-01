#!/bin/sh

LOCALES="de_DE.UTF-8 en_US.UTF-8"
DEFAULT_LOCALE="de_DE.UTF-8"
CONSOLE_KEYMAP="de-latin1"
CONSOLE_FONT="lat9w-16"
WITH_DEVEL=0
WITH_GO=0
WITH_RUBY=0
WITH_GIT=0
USER="arch"
PASSWORD='ARUczHl9T8l4.' # arch
HOSTNAME="arch-minimal"
TIMEZONE="Europe/Berlin"

help() {
	echo "$0 usage:"
	echo "   --locales=\"de_DE.UTF-8 en_US.UTF-8\"   locales to use"
  echo "   --default-locale=de_DE.UTF-8          the default locale"
  echo "   --console-keymap=de-latin1            the console keymap"
  echo "   --console-font=lat9w-16               the console font"
  echo "   --user=arch                           create this user"
  echo "   --password=arch                       set this password for the created user"
  echo "   --hostname=arch-minimal               use this hostname"
  echo "   --timezone='Europe/Berlin'            use this time zone"
  echo "   --with-go                             install go"
  echo "   --with-ruby                           install ruby"
  echo "   --with-devel                          install the development packages"
  echo "   --with-git                            install git"
}

for i in "$@"; do
	case $i in
			-l=*|--locales=*)
			LOCALES="${i#*=}"
			shift
			;;
			-L=*|--default-locale=*)
			DEFAULT_LOCALE="${i#*=}"
			shift
			;;
			-k=*|--console-keymap=*)
			CONSOLE_KEYMAP="${i#*=}"
			shift
			;;
			-f=*|--console-font=*)
			CONSOLE_FONT="${i#*=}"
			shift
			;;
			-u=*|--user=*)
			USER="${i#*=}"
			shift
			;;
			-p=*|--password=*)
			PASSWORD="${i#*=}"
			shift
			;;
			-h=*|--hostname=*)
			HOSTNAME="${i#*=}"
			shift
			;;
			-t=*|--timezone=*)
			TIMEZONE="${i#*=}"
			shift
			;;
			--with-devel)
			WITH_DEVEL=1
			shift
			;;
			--with-go)
			WITH_GO=1
			shift
			;;
			--with-ruby)
			WITH_RUBY=1
			shift
			;;
			--with-git)
			WITH_GIT=1
			shift
			;;
			*)
			help
			exit
			;;
	esac
done


ts=`date +%Y%m%d%H%M%S`
lv="arch-bootstrap-$ts"
raw_file_size=2G
raw_file="./$lv"

truncate -s $raw_file_size $raw_file
mkfs.ext4 -L root $raw_file

mount -o loop $raw_file /mnt

if [ $WITH_DEVEL != 0 ]; then
	pacstrap /mnt base base-devel
else
  pacstrap /mnt base
fi

genfstab -p /mnt >> /mnt/etc/fstab
perl -pi -e 's/\/dev\/loop\d+/LABEL=root/' /mnt/etc/fstab

echo "$HOSTNAME" > /mnt/etc/hostname
echo "127.0.1.1	$HOSTNAME" >> /mnt/etc/hosts
echo "::1	$HOSTNAME" >> /mnt/etc/hosts

arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

#
# LOCALES
#
for l in $LOCALES; do
	echo "$l" >> /mnt/etc/locale.gen
done

arch-chroot /mnt locale-gen

echo "LANG=$DEFAULT_LOCALE" > /mnt/etc/locale.conf
cat > /mnt/etc/vconsole.conf <<EOF
KEYMAP=$CONSOLE_KEYMAP
FONT=$CONSOLE_FONT
EOF

#
# MAKE SURE WE CAN BOOT FROM AN LVM VOLUME
#
perl -pi -e 's/(HOOKS=.+)"/$1 lvm2"/' /mnt/etc/mkinitcpio.conf

#
# SYSLINUX BOOT LOADER
#
arch-chroot /mnt pacman -Syy --noconfirm syslinux
cp -av /mnt/usr/lib/syslinux/bios/* /mnt/boot/syslinux/
arch-chroot /mnt extlinux --install /boot/syslinux/
cp boot/arch.png boot/syslinux.cfg /mnt/boot/syslinux/

#
# NETWORK CONFIGURATION
#
for f in network/*; do 
  install -m 644 -o root -g root $f /mnt/etc/netctl/
done

#
# AUTOMATICALLY RESIZE THE ROOT FS
#
install -o root -g root -m 644 systemd/resize-rootfs.service /mnt/etc/systemd/system/

#
# DISPLAY THE MACHINE'S IP ADDRESS AT THE LOGIN PROMPT
#
install -o root -g root -m 644 issue/90-issuegen.rules /mnt/etc/udev/rules.d/
install -o root -g root -m 700 issue/issuegen /mnt/usr/local/sbin
install -o root -g root -m 644 issue/issuegen.service /mnt/etc/systemd/system/
install -o root -g root -m 755 -d /mnt/usr/local/share/issuegen
install -o root -g root -m 644 issue/issue-header.txt /mnt/usr/local/share/issuegen/

#
# FINISH THINGS UP WITH A CHROOT RUN
#
install -d /mnt/bootstrap
cp chroot.sh /mnt/bootstrap/
cp -a vim /mnt/bootstrap/
cp -a ssh /mnt/bootstrap/
cp -a network /mnt/bootstrap/

chmod 755 /mnt/bootstrap/chroot.sh
arch-chroot /mnt /bootstrap/chroot.sh \
  --with-go=$WITH_GO \
  --with-ruby=$WITH_RUBY \
  --with-git=$WITH_GIT \
  --password="$PASSWORD" \
  --user="$USER"

rm -rf /mnt/bootstrap

umount /mnt
