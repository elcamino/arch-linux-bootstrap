## Arch-Linux-Bootstrap: A Script to bootstrap an Arch Linux image

The scripts in this package can be used to generate a minimal disk image of Arch Linux, i.e.
as a base for virtual machines. The images are geared towards libvirt/kvm but it shouldn't be 
much of a problem to adapt the scripts for other environments.

### Features

The image includes a fully configured instance of vim with full syntax highlighting and 
auto-completion for Go, Ruby and many other programming languages supported by vim natively.

The vim setup also includes the airline package for a pretty status line.

Via command line flags the bootstrap script will install the Arch Linux base devel packages,
Go, Ruby and Git.

### Usage

In order to create an image you need to run `bootstrap.sh` as root in Arch Linux.

bootstrap.sh supports the following parameters:

- `--locales="de_DE.UTF-8 en_US.UTF-8"` The list of locales to install
- `--default-locale=de_DE.UTF-8` Use this locale as default locale
- `--console-keymap=de-latin1` Use this keymap as the console keymap
- `--console-font=lat9w-16` Use this font as the console font
- `--user=arch` bootstrap.sh creates one user with this login name
- `--password=arch` the password for the newly created user
- `--hostname=arch-minimal` the machine's hostname
- `--timezone="Europe/Berlin"` the machine's timezone
- `--with-go` install go and set up an environment for the newly created user (default: no)
- `--with-ruby` install ruby (default: no)
- `--with-git` install git (default: no)
- `--with-devel` install the base-devel packages for Arch Linux (default: no)

### Network setup

The default script assumes that the first network interface ist called `ens3` and that 
the interface is setup via dhcp.

If your setup is different, place your network configuration files in the network directory
and the bootstrap script will install and activate all networks you need.

### Partition Auto-Resizing

The image only consists of one filesystem on the entire disk. There are no partitions.

The system is configured to resize /dev/vda to its full extent every time it boots. If 
your hard disk has a different name, e.g. /dev/xvda, change /dev/vda to the actual name 
in `systemd/resize-rootfs.service`

### SSH Setup

SSH is enabled by default. Place all keys that need to be able to log into the machine
in ssh/authorized_keys.

### Example

```bash
sudo ./bootstrap.sh --locales="en_US.UTF-8 fr_FR.UTF-8" \
  --default-locale=en_US.UTF-8 \
  --user=bob \
  --password=bobspassword \
  --hostname=bearclaw.scw.systems \
  --timezone="America/Los_Angeles" \
  --with-go \
  --with-ruby \
  --with-devel \
  --with-git
```

### Copyright

Copyright @ 2016 Tobias Begalke. See LICENSE.txt for details.




