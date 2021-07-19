#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/../scripts/common.sh

PROJECT=libxml2
GITHUB_REPO=GNOME/libxml2
TAG=$(get_latest_github_release_tag $GITHUB_REPO)

# load environment and prepare project
if ! prepare_project $PROJECT $GITHUB_REPO $TAG; then
  exit 0
fi

. "$ROOT_DIR"/scripts/toolchain.sh

echo -e "\n### Running autogen"
NOCONFIGURE=1 ./autogen.sh

echo -e "\n### Running configure"
./configure \
  --host=${ANDROID_TARGET} \
  --prefix="${INSTALL_PREFIX}" \
  --without-python \
  --without-lzma \
  --with-icu \
  --disable-shared \
  `# specify include dir to enable finding libiconv and ICU` \
  `# -fPIC required to remove unsupported text relocations` \
  CFLAGS="${CFLAGS} -I${INSTALL_PREFIX}/include -fPIC" \

echo -e "\n### Building"
make -j${MAKE_JOBS}

echo -e "\n### Installing"
make install
