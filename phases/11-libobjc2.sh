#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/common.sh

prepare_project "libobjc2" "https://github.com/gnustep/libobjc2.git"

echo -e "\n### Running cmake"
mkdir -p build-${ABI_NAME}
cd build-${ABI_NAME}

${CMAKE} .. \
  ${CMAKE_OPTIONS} \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
  -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY="BOTH" \
  -DCMAKE_C_FLAGS="-DDEBUG_EXCEPTIONS=1" `# debug exception throwing` \
  -DGNUSTEP_CONFIG= `# prevent cmake from finding gnustep-config in install root` \
  -DOLDABI_COMPAT=false `# we're using gnustep-2.0 ABI, which may not be mixed with earlier versions'` \

echo -e "\n### Building"
${NINJA}

echo -e "\n### Installing"
${NINJA} install
