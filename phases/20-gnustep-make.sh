#!/bin/bash

set -e # make any subsequent failing command exit the script

cd `dirname $0`/..
export ROOT_DIR=`pwd`

. `dirname $0`/common.sh

prepare_project "gnustep-make" "https://github.com/gnustep/tools-make.git"

. "${ROOT_DIR}"/env/toolchain.sh

# copy user config file
mkdir -p "${INSTALL_PREFIX}"/etc/GNUstep
GNUSTEP_USER_CONFIG_FILE="${INSTALL_PREFIX}"/etc/GNUstep/GNUstep-user.conf
cp "${ROOT_DIR}"/config/gnustep-make-user.config "${GNUSTEP_USER_CONFIG_FILE}"

echo -e "\n### Running configure"
./configure \
  --host=${ANDROID_TARGET} \
  --prefix="${INSTALL_PREFIX}" \
  --with-library-combo=ng-gnu-gnu \
  --with-layout=fhs \
  --with-user-config-file="${GNUSTEP_USER_CONFIG_FILE}" \
  --enable-objc-arc \
  --enable-native-objc-exceptions

echo -e "\n### Installing"
${MAKE} install
