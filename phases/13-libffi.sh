#!/bin/bash

set -e # make any subsequent failing command exit the script

cd `dirname $0`/..
export ROOT_DIR=`pwd`

. `dirname $0`/common.sh

prepare_project "libffi" "https://github.com/libffi/libffi.git"

. "${ROOT_DIR}"/env/toolchain.sh

echo -e "\n### Running autogen"
./autogen.sh

echo -e "\n### Running configure"
./configure \
  --host=${ANDROID_TARGET} \
  --prefix="${INSTALL_PREFIX}" \
  --disable-shared \

echo -e "\n### Building"
make

echo -e "\n### Installing"
make install
