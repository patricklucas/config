#!/bin/bash

set -e

# Add Debian backports sources list
cat > /etc/apt/sources.list.d/backports.list << EOF
deb http://backports.debian.org/debian-backports squeeze-backports main
EOF

# Update package lists and upgrade outdated packages
apt-get update
apt-get upgrade -y

# Install common packages from packages.txt
packages=$(cat packages.txt | tr '\n' ' ')
apt-get install -y $packages

# Add prl user
adduser --quiet --disabled-password --gecos "Patrick Lucas,,," prl
usermod -a -G sudo prl

# Install ssh key
mkdir -p ~prl/.ssh
cp keys/id_dsa.pub ~prl/.ssh/authorized_keys
chmod 0600 ~prl/.ssh/authorized_keys
chown -R prl:prl ~prl/.ssh

# Tighten up sshd
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
service ssh restart

# Set up private IP
if [ -n "$PRIVATE_IP" ]; then
    sed -i 's/^auto \(.*\)$/auto \1 eth0:0/' /etc/network/interfaces
    cat >> /etc/network/interfaces << EOF

iface eth0:0 inet static
    address $PRIVATE_IP
    netmask 255.255.128.0
EOF
    ifup eth0:0
fi

# Set the hostname
if [ -n "$HOSTNAME" ]; then
    echo $HOSTNAME > /etc/hostname
    hostname -F /etc/hostname
    sed -i "s/^\(.*\)debian$/\1$HOSTNAME/" /etc/hosts
fi

# Disable screen welcome message
sed -i 's/^#startup_message off$/startup_message off/' /etc/screenrc
