#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/../scripts/common.sh

PROJECT=libiconv
URL=https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz

# load environment and prepare project
if ! prepare_project $PROJECT $URL; then
  exit 0
fi

. "$ROOT_DIR"/scripts/toolchain.sh

echo -e "\n### Running configure"
./configure \
  --host=${ANDROID_TARGET} \
  --prefix="${INSTALL_PREFIX}" \
  --enable-shared \
  --disable-static \

echo -e "\n### Building"
make -j${MAKE_JOBS}

echo -e "\n### Installing"
make install
