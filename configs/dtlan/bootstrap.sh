#!/bin/bash -e

export CONFIG_NAME="dtlan"
apt-get install -y curl
curl -s "https://raw.github.com/patricklucas/config/master/bootstrap.sh" | sh
