#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/common.sh

prepare_project "libxml2" "https://github.com/GNOME/libxml2.git"

if [ "$NO_UPDATE" != true ]; then
  # check out latest release
  echo -e "\n### Checking out latest release"
  latest_release_tag=`curl -s https://api.github.com/repos/GNOME/libxml2/tags | grep '"name":' | sed -E 's/.*"([^"]+)".*/\1/' | egrep '^v\d+\.\d+(\.\d+)?$' | head -n 1`
  echo -e "Release: $latest_release_tag\n"
  git fetch --tags
  git checkout -q $latest_release_tag
fi

. "${ROOT_DIR}"/env/toolchain.sh

echo -e "\n### Running autogen"
NOCONFIGURE=1 ./autogen.sh

echo -e "\n### Running configure"
./configure \
  --host=${ANDROID_TARGET} \
  --prefix="${INSTALL_PREFIX}" \
  --without-python \
  --without-lzma \
  --disable-shared \
  CFLAGS="${CFLAGS} -fPIC" `# required to remove unsupported text relocations` \

echo -e "\n### Building"
make

echo -e "\n### Installing"
make install
