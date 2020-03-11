#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/common.sh

prepare_project "libdispatch" "https://github.com/apple/swift-corelibs-libdispatch.git"

echo -e "\n### Running cmake"
mkdir -p build-${ABI_NAME}
cd build-${ABI_NAME}

${CMAKE} .. \
  ${CMAKE_OPTIONS} \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
  -DBUILD_SHARED_LIBS=YES \
  -DINSTALL_PRIVATE_HEADERS=YES \

echo -e "\n### Building"
${NINJA}

echo -e "\n### Installing"
${NINJA} install
