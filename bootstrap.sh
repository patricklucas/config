#!/bin/bash

set -e

apt-get install -y git

git clone git://github.com/patricklucas/config.git $HOME/config

pushd $HOME/config > /dev/null
./install.sh
popd > /dev/null

rm -rf $HOME/config
