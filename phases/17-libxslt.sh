#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/../scripts/common.sh

PROJECT=libxslt
GITHUB_REPO=GNOME/libxslt
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
  --without-crypto \
  --disable-shared \
  `# specify include dir to enable finding libiconv and ICU (from libxml headers)` \
  `# -fPIC required to remove unsupported text relocations` \
  CFLAGS="${CFLAGS} -I${INSTALL_PREFIX}/include -fPIC" \

echo -e "\n### Building"
make -j${MAKE_JOBS}

echo -e "\n### Installing"
make install
