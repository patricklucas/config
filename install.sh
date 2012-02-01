#!/bin/bash

set -e

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

# Disable root ssh login
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
service ssh restart
