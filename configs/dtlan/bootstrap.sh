#!/bin/bash -e

export CONFIG_NAME="dtlan"
export CONFIG_RELEASE="wheezy"
export CONFIG_HOSTNAME="dtlan"
export CONFIG_NO_CREATE_USER=1

curl -s https://raw.github.com/patricklucas/config/master/bootstrap.sh | sh
