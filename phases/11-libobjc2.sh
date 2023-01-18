#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/../scripts/common.sh

PROJECT=libobjc2
GITHUB_REPO=gnustep/libobjc2

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
  -DGNUSTEP_CONFIG= `# prevent cmake from finding gnustep-config in install root` \
  -DOLDABI_COMPAT=false `# we're using gnustep-2.0 ABI, which may not be mixed with earlier versions'` \

echo -e "\n### Building"
make -j${MAKE_JOBS}

echo -e "\n### Installing"
make install
