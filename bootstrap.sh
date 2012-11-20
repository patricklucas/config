#!/bin/bash -e

# Install git, clone the config repo, and run install.sh

INSTALL_DIR=$(mktemp -d)

apt-get install -y git

git clone git://github.com/patricklucas/config.git $INSTALL_DIR

pushd $INSTALL_DIR > /dev/null
./install.sh
popd > /dev/null

rm -rf $INSTALL_DIR
