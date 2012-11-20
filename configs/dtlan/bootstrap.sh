#!/bin/bash -e

export CONFIG_BRANCH="multi_config_refactor" # XXX
export CONFIG_NAME="dtlan"
apt-get install -y curl
curl -s "https://raw.github.com/patricklucas/config/$CONFIG_BRANCH/bootstrap.sh" | bash
