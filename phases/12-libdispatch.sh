#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/common.sh

prepare_project "libdispatch" "https://github.com/apple/swift-corelibs-libdispatch.git"

echo -e "\n### Running cmake"
mkdir -p build-${ABI_NAME}

${CMAKE} \
  -H"${SRCROOT}"/${PROJECT} \
  -B"${SRCROOT}"/${PROJECT}/build-${ABI_NAME} \
  -G"Ninja" \
  -DCMAKE_MAKE_PROGRAM=${NINJA} \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} \
  -DANDROID_ABI=${ABI_NAME} \
  -DANDROID_NDK=${ANDROID_NDK_ROOT} \
  -DANDROID_PLATFORM=android-${ANDROID_API_LEVEL} \
  -DBUILD_SHARED_LIBS=YES \
  -DINSTALL_PRIVATE_HEADERS=YES \

cd build-${ABI_NAME}

echo -e "\n### Building"
${NINJA}

echo -e "\n### Installing"
${NINJA} install
