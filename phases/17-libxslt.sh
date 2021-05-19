#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/common.sh

latest_release_tag=`curl -s https://api.github.com/repos/GNOME/libxslt/tags | grep '"name":' | sed -E 's/.*"([^"]+)".*/\1/' | egrep '^v\d+\.\d+(\.\d+)?$' | head -n 1`

if ! prepare_project "libxslt" "https://github.com/GNOME/libxslt.git" $latest_release_tag; then
  exit 0
fi

. "${ROOT_DIR}"/env/toolchain.sh

echo -e "\n### Running autogen"
NOCONFIGURE=1 ./autogen.sh

echo -e "\n### Running configure"
./configure \
  --host=${ANDROID_TARGET} \
  --prefix="${INSTALL_PREFIX}" \
  --without-crypto \
  --disable-shared \
  `# specify include dir to enable finding libiconv and ICU (from libxml headers)` \
  `# -fPIC required to remove unsupported text relocations` \
  CFLAGS="${CFLAGS} -I${INSTALL_PREFIX}/include -fPIC" \

echo -e "\n### Building"
make -j${MAKE_JOBS}

echo -e "\n### Installing"
make install
