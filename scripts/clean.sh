#!/bin/sh

echo "## Cleaning environment"
export ROOT_DIR=`pwd`
export SCRIPT_DIR=${ROOT_DIR}/scripts

. ${SCRIPT_DIR}/sdkenv.sh
. ${SCRIPT_DIR}/toolchain.sh
. ${SCRIPT_DIR}/makeenv.sh

echo "# Cleaning ${INSTALL_PREFIX}"
rm -rf ${INSTALL_PREFIX}
echo "# Cleaning ${SRCROOT}"
rm -rf ${SRCROOT}
echo "## Done"
