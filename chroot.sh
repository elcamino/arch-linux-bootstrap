#!/bin/sh

WITH_GO=0
WITH_RUBY=0
WITH_GIT=0
USER="arch"
PASSWORD="rHDW5xp4hDyaU" # arch


for i in "$@"; do
	case $i in
			-u=*|--user=*)
			USER="${i#*=}"
			shift
			;;
			-p=*|--password=*)
			PASSWORD="${i#*=}"
			shift
			;;
			--with-go=*)
			WITH_GO="${i#*=}"
			shift
			;;
			--with-ruby=*)
			WITH_RUBY="${i#*=}"
			shift
			;;
			--with-git=*)
			WITH_GIT="${i#*=}"
			shift
			;;
			*)
							# unknown option
			;;
	esac
done



pacman -S --noconfirm vim htop lsof linux-lts sudo ntp openssh lua
pacman -R --noconfirm linux

if [ $WITH_GO != 0 ]; then
  pacman -S --noconfirm go go-tools
fi

if [ $WITH_RUBY != 0 ]; then
	pacman -S --noconfirm ruby
fi

if [ $WITH_GIT != 0 ]; then
	pacman -S --noconfirm git
fi


#
# USERS
#
user=$USER

echo "root:root" | chpasswd

useradd -m -G wheel -U -p eCxS1fXJO8oqQ $user
echo "$user:$user" | chpasswd

#
# VIM
#
cp -a /bootstrap/vim/.vimrc /home/$user/
cp -a /bootstrap/vim/.vim /home/$user/

chown -R $user:$user /home/$user/.vim*


#
# GO
#
if [ $WITH_GO != 0 ]; then
	install -d -o $user -g $user -m 775 /home/$user/go/src
	chown -R $user:$user /home/$user/go
	printf "\nGOPATH=/home/$user/go\nexport GOPATH\nPATH=\"\$GOPATH/bin:$PATH\"\n" >> /home/$user/.bashrc

	env GOPATH=/home/$user/go PATH="/home/$user/go/bin:$PATH" go get github.com/nsf/gocode
fi

#
# SUDO
#
perl -pi -e 's/#\s*(%wheel.+NOPASSWD)/$1/' /etc/sudoers


#
# SERIAL CONSOLE
#
systemctl enable serial-getty@ttyS0.service

#
# SSH
#
install -d -o $user -g $user -m 700 /home/$user/.ssh
install -m 600 -o $user -g $user /bootstrap/ssh/authorized_keys /home/$user/.ssh/

systemctl enable sshd

#
# NTP
#
systemctl enable ntpd

#
# RESIZE THE ROOT FILESYSTEM
#
systemctl enable resize-rootfs

#
# ENABLE NETWORK
#

for f in /bootstrap/network/*; do
	interface=`basename $f`
	netctl enable $interface
done

#
# LOCK DOWN THE ROOT LOGIN
#
passwd -l root
