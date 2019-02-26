#!/bin/sh

PROJECT=$1

export ROOT_DIR=`pwd`
export SCRIPT_DIR=${ROOT_DIR}/scripts

. ${SCRIPT_DIR}/sdkenv.sh
. ${SCRIPT_DIR}/toolchain.sh
. ${SCRIPT_DIR}/makeenv.sh

if [ ! -e ${ANDROID_GNUSTEP_INSTALL_ROOT} ]; then
    ${SCRIPT_DIR}/setup.sh
fi

# env

cd examples/${PROJECT}
make clean
make -j6 all

# install
rm *.unsigned.apk
${ADB} install *.apk
