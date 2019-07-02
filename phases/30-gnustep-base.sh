#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/common.sh

prepare_project "gnustep-base" "https://github.com/gnustep/libs-base"

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
  --disable-iconv \
  --disable-tls \
  --disable-mixedabi \
  --disable-gdomap \
  --with-cross-compilation-info=${ROOT_DIR}/config/gnustep-base-cross.config \
  ${OPTIONS}

echo -e "\n### Building"
# use -nopie to avoid ld error: https://lists.gnu.org/archive/html/discuss-gnustep/2015-09/msg00057.html
# use -static-libstdc++ to enable C++ support (for patches)
make LDFLAGS="${LDFLAGS} -nopie -static-libstdc++" -j${MAKE_JOBS} debug=yes

echo -e "\n### Installing"
make install
