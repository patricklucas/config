#!/bin/bash

set -e

# Update aptitude and upgrade everything
aptitude update
aptitude safe-upgrade -y

# Install common packages from packages.txt
packages=$(cat packages.txt | tr '\n' ' ')
aptitude install -y $packages

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
if [ -n "$private_ip" ]; then
    sed -i 's/auto eth0/auto eth0 eth0:0/' /etc/network/interfaces
    cat >> /etc/network/interfaces << EOF

iface eth0:0 inet static
    address $private_ip
    netmask 255.255.128.0
EOF
    ifup eth0:0
fi

# Set the hostname
if [ -n "$hostname" ]; then
    echo $hostname > /etc/hostname
    sed -i "s/SET_HOSTNAME='yes'/#SET_HOSTNAME='yes'/" /etc/default/dhcpcd
fi
