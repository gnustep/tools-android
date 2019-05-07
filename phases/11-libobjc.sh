#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/common.sh

prepare_project "libobjc2" "https://github.com/gnustep/libobjc2.git"

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
  -DGNUSTEP_CONFIG= `# prevent cmake from finding gnustep-config in install root` \
  -DCMAKE_C_FLAGS="-DDEBUG_EXCEPTIONS=1" `# debug exception throwing` \
  -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY="BOTH" \
  -DCMAKE_LIBRARY_PATH="${INSTALL_PREFIX}"/lib \

cd ${PROJECT}/build

echo -e "\n### Building"
${NINJA}

echo -e "\n### Installing"
${NINJA} install
