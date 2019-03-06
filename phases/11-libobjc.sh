#!/bin/bash

PROJECT=libobjc2

set -e # make any subsequent failing command exit the script

cd `dirname $0`/..
export ROOT_DIR=`pwd`

. "${ROOT_DIR}"/env/sdkenv.sh

echo -e "\n### Cloning project"
cd "${SRCROOT}"
rm -rf ${PROJECT}
git clone https://github.com/gnustep/libobjc2 ${PROJECT}
cd ${PROJECT}

for patch in "${ROOT_DIR}"/patches/${PROJECT}-*.patch; do
  if [ -f $patch ] ; then
    echo -e "\n### Applying `basename "$patch"`"
    patch -p1 < "$patch"
  fi
done

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
  -DCMAKE_C_FLAGS="-DDEBUG_EXCEPTIONS=1" `# debug exception throwing`

cd ${PROJECT}/build

echo -e "\n### Building"
${NINJA}

echo -e "\n### Installing"
${NINJA} install
