#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/../scripts/common.sh

PROJECT=gnustep-corebase
GITHUB_REPO=gnustep/libs-corebase

# load environment and prepare project
if ! prepare_project $PROJECT $GITHUB_REPO; then
  exit 0
fi

. "$ROOT_DIR"/scripts/toolchain.sh

echo "### Source GNUstep.sh"
. "$INSTALL_PREFIX"/share/GNUstep/Makefiles/GNUstep.sh

echo -e "\n### Running configure"
./configure \
  --host=${ANDROID_TARGET} \
  --prefix="${INSTALL_PREFIX}" \
  `# specify include dir to enable finding ICU` \
  CFLAGS="${CFLAGS} -I${INSTALL_PREFIX}/include" \
  CPPFLAGS="${CPPFLAGS} -I${INSTALL_PREFIX}/include" \

echo -e "\n### Building"
make -j${MAKE_JOBS} ${GNUSTEP_MAKE_OPTIONS}

echo -e "\n### Installing"
make install
