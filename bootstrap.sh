#!/bin/bash -e

REPO="git://github.com/patricklucas/config.git"

if [ -z "$CONFIG_NAME" ]; then
    echo >&2 "\$CONFIG_NAME unset!"
    exit 1
fi

apt-get install -y git

INSTALL_DIR=$(mktemp -d)

git clone $REPO $INSTALL_DIR

pushd $INSTALL_DIR > /dev/null

. configs/$CONFIG_NAME/config.sh

if [ -z "$CONFIG_RELEASE" ]; then
    export CONFIG_RELEASE="squeeze"
fi

./install.sh

popd > /dev/null

rm -rf $INSTALL_DIR
