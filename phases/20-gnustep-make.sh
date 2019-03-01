#!/bin/bash

PROJECT=gnustep-make

set -e # make any subsequent failing command exit the script

cd `dirname $0`/..
export ROOT_DIR=`pwd`

. "${ROOT_DIR}"/env/sdkenv.sh
. "${ROOT_DIR}"/env/toolchain.sh

echo -e "\n### Cloning project"
cd "${SRCROOT}"
rm -rf ${PROJECT}
git clone https://github.com/gnustep/tools-make ${PROJECT}
cd ${PROJECT}

for patch in "${ROOT_DIR}"/patches/${PROJECT}-*.patch; do
  if [ -f $patch ] ; then
    echo -e "\n### Applying `basename "$patch"`"
    patch -p1 < "$patch"
  fi
done

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
gnumake install
