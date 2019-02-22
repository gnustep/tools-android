#!/bin/sh

export ROOT_DIR=`pwd`
export SCRIPT_DIR=${ROOT_DIR}/scripts

. ${SCRIPT_DIR}/sdkenv.sh
. ${SCRIPT_DIR}/toolchain.sh
. ${SCRIPT_DIR}/makeenv.sh

rm -rf ${INSTALL_PREFIX}
rm -rf ${SRCROOT}
