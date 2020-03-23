#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/common.sh

if ! prepare_project "gnustep-base" "https://github.com/gnustep/libs-base.git"; then
  exit 0
fi

. "${ROOT_DIR}"/env/toolchain.sh

echo "### Source GNUstep.sh"
. "${INSTALL_PREFIX}"/share/GNUstep/Makefiles/GNUstep.sh

OPTIONS=
if [[ "$ABI_NAME" != *"64"* ]]; then
  # remove _FILE_OFFSET_BITS definition for 32-bit
  # see https://android.googlesource.com/platform/bionic/+/master/docs/32-bit-abi.md
  OPTIONS=--disable-largefile
fi

echo -e "\n### Running configure"
./configure \
  --host=${ANDROID_TARGET} \
  --enable-nxconstantstring \
  --disable-tls \
  --with-cross-compilation-info=${ROOT_DIR}/config/gnustep-base-cross.config \
  --with-default-config=${ROOT_DIR}/config/gnustep-base-default.config \
  --with-config-file=/ \
  --disable-environment-config-file \
  ${OPTIONS}

echo -e "\n### Building"
# use -nopie to avoid ld error: https://lists.gnu.org/archive/html/discuss-gnustep/2015-09/msg00057.html
make LDFLAGS="${LDFLAGS} -nopie" -j${MAKE_JOBS} ${GNUSTEP_MAKE_OPTIONS}

echo -e "\n### Installing"
make install
