#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/common.sh

if ! prepare_project "libdispatch" "https://github.com/apple/swift-corelibs-libdispatch.git"; then
  exit 0
fi

. "${ROOT_DIR}"/env/toolchain.sh

echo -e "\n### Running cmake"
mkdir -p build-${ABI_NAME}
cd build-${ABI_NAME}

${CMAKE} .. \
  ${CMAKE_OPTIONS} \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
  -DBUILD_SHARED_LIBS=YES \
  -DINSTALL_PRIVATE_HEADERS=YES \

echo -e "\n### Building"
make -j${MAKE_JOBS}

echo -e "\n### Installing"
make install
