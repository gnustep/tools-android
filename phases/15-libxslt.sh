#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/common.sh

latest_release_tag=`curl -s https://api.github.com/repos/GNOME/libxslt/tags | grep '"name":' | sed -E 's/.*"([^"]+)".*/\1/' | egrep '^v\d+\.\d+(\.\d+)?$' | head -n 1`

prepare_project "libxslt" "https://github.com/GNOME/libxslt.git" $latest_release_tag

. "${ROOT_DIR}"/env/toolchain.sh

echo -e "\n### Running autogen"
NOCONFIGURE=1 ./autogen.sh

echo -e "\n### Running configure"
./configure \
  --host=${ANDROID_TARGET} \
  --prefix="${INSTALL_PREFIX}" \
  --with-libxml-prefix="${INSTALL_PREFIX}" \
  --disable-shared \
  --without-crypto \
  CFLAGS="${CFLAGS} -fPIC" `# required to remove unsupported text relocations` \

echo -e "\n### Building"
make

echo -e "\n### Installing"
make install
