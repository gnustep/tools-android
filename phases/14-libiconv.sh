#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/common.sh

if ! prepare_project "libiconv" "https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz"; then
  exit 0
fi

. "${ROOT_DIR}"/env/toolchain.sh

echo -e "\n### Running configure"
./configure \
  --host=${ANDROID_TARGET} \
  --prefix="${INSTALL_PREFIX}" \
  --disable-shared

echo -e "\n### Building"
make -j${MAKE_JOBS}

echo -e "\n### Installing"
make install
