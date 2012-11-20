#!/bin/bash -e

# <udf name="config_hostname" LABEL="Hostname" />
# <udf name="config_private_ip" LABEL="Private IP Address" />

export CONFIG_NAME="linode_stackscript"
export CONFIG_RELEASE="squeeze"
export CONFIG_BACKPORTS=1

# StackScript config
export CONFIG_HOSTNAME
export CONFIG_PRIVATE_IP

curl -s https://raw.github.com/patricklucas/config/master/bootstrap.sh | sh
