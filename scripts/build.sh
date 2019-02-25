#!/bin/sh

PROJECT=$1

export ROOT_DIR=`pwd`
export SCRIPT_DIR=${ROOT_DIR}/scripts

if [ ! -e ${INSTALL_PREFIX}/GNUstep ]; then
    ${SCRIPT_DIR}/setup.sh
fi

. ${SCRIPT_DIR}/sdkenv.sh
. ${SCRIPT_DIR}/toolchain.sh
. ${SCRIPT_DIR}/makeenv.sh

cd ${PROJECT}
make clean
make -j6 all

# install
rm *.unsigned.apk
${ADB} install *.apk
