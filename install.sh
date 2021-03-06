#!/bin/bash -e

if [ -n "$CONFIG_BACKPORTS" ]; then
    # Add Debian backports sources list
    cat > /etc/apt/sources.list.d/backports.list << EOF
deb http://backports.debian.org/debian-backports $CONFIG_RELEASE-backports main
EOF
fi

# Install packages
xargs < common_packages.txt apt-get install -y

config_packages="configs/$CONFIG_NAME/packages.txt"
if [ -e "$config_packages" ]; then
    xargs < "$config_packages" apt-get install -y
fi

# Add prl user if doesn't already exist
if [ -z "$CONFIG_NO_CREATE_USER" ]; then
    adduser --quiet --disabled-password --gecos "Patrick Lucas,,," prl
fi

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
if [ -n "$CONFIG_PRIVATE_IP" ]; then
    sed -i 's/^auto \(.*\)$/auto \1 eth0:0/' /etc/network/interfaces
    cat >> /etc/network/interfaces << EOF

iface eth0:0 inet static
    address $CONFIG_PRIVATE_IP
    netmask 255.255.128.0
EOF
    ifup eth0:0
fi

# Set the hostname
if [ -n "$CONFIG_HOSTNAME" ]; then
    echo $CONFIG_HOSTNAME > /etc/hostname
    hostname -F /etc/hostname
    sed -i "s/^\(.*\)debian$/\1$CONFIG_HOSTNAME/" /etc/hosts
fi

# Disable screen welcome message
sed -i 's/^#startup_message off$/startup_message off/' /etc/screenrc

# Execute optional post-install script
post_install="configs/$CONFIG_NAME/postinstall.sh"
if [ -x "$post_install" ]; then
    ./$post_install
fi
