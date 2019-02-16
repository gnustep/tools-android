#!/bin/sh

PROJECT=$1

if [ ! -e GNUstep ]; then
    ${SCRIPT_DIR}/setup.sh
fi

export ROOT_DIR=`pwd`
export SCRIPT_DIR=${ROOT_DIR}/scripts

. ${SCRIPT_DIR}/sdkenv.sh
. ${SCRIPT_DIR}/toolchain.sh
. ${SCRIPT_DIR}/makeenv.sh

cd ${PROJECT}
make -j6 all
