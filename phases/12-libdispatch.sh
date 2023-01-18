#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/../scripts/common.sh

PROJECT=libdispatch
GITHUB_REPO=apple/swift-corelibs-libdispatch

# load environment and prepare project
if ! prepare_project $PROJECT $GITHUB_REPO; then
  exit 0
fi

. "$ROOT_DIR"/scripts/toolchain.sh

echo -e "\n### Running cmake"
mkdir -p build-${ABI_NAME}
cd build-${ABI_NAME}

${CMAKE} .. \
  ${CMAKE_OPTIONS} \
  -DBUILD_SHARED_LIBS=YES \
  -DINSTALL_PRIVATE_HEADERS=YES \
  `# use blocks runtime from libobjc2 with libdispatch-own-blocksruntime.patch` \
  -DBlocksRuntime_INCLUDE_DIR="${INSTALL_PREFIX}/include" \
  -DBlocksRuntime_LIBRARIES="${INSTALL_PREFIX}/lib/libobjc.so" \

echo -e "\n### Building"
make -j${MAKE_JOBS}

echo -e "\n### Installing"
make install
