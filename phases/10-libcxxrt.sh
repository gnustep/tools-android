#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/common.sh

prepare_project "libcxxrt" "https://github.com/libcxxrt/libcxxrt.git"

echo -e "\n### Running cmake"
mkdir -p build-${ABI_NAME}

${CMAKE} \
  -H"${SRCROOT}"/${PROJECT} \
  -B"${SRCROOT}"/${PROJECT}/build-${ABI_NAME} \
  -G"Ninja" \
  -DCMAKE_MAKE_PROGRAM=${NINJA} \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} \
  -DANDROID_ABI=${ABI_NAME} \
  -DANDROID_NDK=${ANDROID_NDK_ROOT} \
  -DANDROID_PLATFORM=android-${ANDROID_API_LEVEL} \

cd build-${ABI_NAME}

echo -e "\n### Building"
${NINJA}

echo -e "\n### Installing"
mkdir -p "${INSTALL_PREFIX}/lib"
cp -v "${SRCROOT}"/${PROJECT}/build-${ABI_NAME}/lib/libcxxrt.so "${INSTALL_PREFIX}/lib"
mkdir -p "${INSTALL_PREFIX}/include"
cp -v "${SRCROOT}"/${PROJECT}/src/unwind*.h "${INSTALL_PREFIX}/include"
cp -v "${SRCROOT}"/${PROJECT}/src/cxxabi.h "${INSTALL_PREFIX}/include"
