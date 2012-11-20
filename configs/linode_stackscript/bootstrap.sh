#!/bin/bash -e

export CONFIG_NAME="linode_stackscript"

# <udf name="config_hostname" LABEL="Hostname" />
# <udf name="config_private_ip" LABEL="Private IP Address" />

export CONFIG_HOSTNAME
export CONFIG_PRIVATE_IP

curl -s https://raw.github.com/patricklucas/config/master/bootstrap.sh | bash
