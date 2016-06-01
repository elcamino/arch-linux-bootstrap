#!/bin/sh

pacman -S --noconfirm vim htop lsof linux-lts sudo ntp openssh ruby go go-tools git lua

#
# USERS
#
user="jay"

echo "root:root" | chpasswd

useradd -m -G wheel -U -p eCxS1fXJO8oqQ $user

#
# VIM
#
cp -a /bootstrap/vim/.vimrc /home/$user/
cp -a /bootstrap/vim/.vim /home/$user/

chown -R $user:$user /home/$user/.vim*


#
# GO
#
install -d -o $user -g $user -m 775 /home/$user/go/src
chown -R $user:$user /home/$user/go
printf "\nGOPATH=/home/$user/go\nexport GOPATH\nPATH=\"\$GOPATH/bin:$PATH\"\n" >> /home/$user/.bashrc

env GOPATH=/home/$user/go PATH="/home/$user/go/bin:$PATH" go get github.com/nsf/gocode

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
cat > /home/$user/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDC/5Envdwo+ZzMQyE0179R3Ohl082rK2XFXrqW871oKmjUQVwmlGj7qi42hFkNld0T2Q9yJdleNHZAwUIkIVAEo2GcZ3T7OXfvKe7HpcmN9Gt1IHLBzSbKaG9LuBA4VFCRjI5p5SBerrOreVJOwKGFjSMkUqtHOvykKsAQA6gfzQg6/nJSvrhVDPdVnRz6iocICjzsLBL5G4hJefJN+YCSd6PgCjeAqivrZ/lJCL5mbECdgZbDGpm8yhj0yJPMKpsGIT+/yAfSI6VwleovL33BohT0MUCBvHOR95BTcQNjCx9qTrlmOXeBso4P4ujzXqa+PzX6LVGhrDipKvTRl+v3 jay
EOF

chown $user:$user /home/$user/.ssh/authorized_keys
chmod 600 /home/$user/.ssh/authorized_keys

systemctl enable sshd

#
# NTP
#
systemctl enable ntpd

#
# ENABLE NETWORK
#
netctl enable ens3

passwd -l root
