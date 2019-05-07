#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/common.sh

prepare_project "libdispatch" "https://github.com/apple/swift-corelibs-libdispatch.git"

echo -e "\n### Running cmake"
cd "${SRCROOT}"
mkdir -p ${PROJECT}/build

${CMAKE} \
  -H"${SRCROOT}"/${PROJECT} \
  -B"${SRCROOT}"/${PROJECT}/build \
  -G"Ninja" \
  -DCMAKE_MAKE_PROGRAM=${NINJA} \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} \
  -DANDROID_ABI=${ABI_NAME} \
  -DANDROID_NDK=${ANDROID_NDK_HOME} \
  -DANDROID_PLATFORM=android-${ANDROID_API_LEVEL} \
  -DBUILD_SHARED_LIBS=YES \
  -DINSTALL_PRIVATE_HEADERS=YES \

cd ${PROJECT}/build

echo -e "\n### Building"
${NINJA}

echo -e "\n### Installing"
${NINJA} install
