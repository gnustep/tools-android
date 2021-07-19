#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/../scripts/common.sh

PROJECT=gnustep-make
GITHUB_REPO=gnustep/tools-make

# load environment and prepare project
if ! prepare_project $PROJECT $GITHUB_REPO; then
  exit 0
fi

. "$ROOT_DIR"/scripts/toolchain.sh

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
  --with-runtime-abi=gnustep-2.0 \

echo -e "\n### Installing"
make install
