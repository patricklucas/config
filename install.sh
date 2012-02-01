#!/bin/bash

set -e

function install_common() {
    packages=$(cat packages.txt | tr '\n' ' ')
    aptitude install -y $packages
}

# Add prl user
adduser --quiet --disabled-password --gecos "Patrick Lucas,,," prl
usermod -a -G wheel prl

# Install ssh key
mkdir -p ~prl/.ssh
cp keys/id_dsa.pub ~prl/.ssh/authorized_keys
chmod 0600 ~prl/.ssh/authorized_keys

# Disable root ssh login
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
service ssh restart
