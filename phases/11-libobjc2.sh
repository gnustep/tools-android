#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/common.sh

# currently using older version of libc++ branch until the following PR is merged:
# https://github.com/gnustep/libobjc2/pull/152
if ! prepare_project "libobjc2" "https://github.com/gnustep/libobjc2.git" "d521f61e8d67c77420b1687e5c1cbaf25571b871"; then
  exit 0
fi

. "${ROOT_DIR}"/env/toolchain.sh

echo -e "\n### Running cmake"
mkdir -p build-${ABI_NAME}
cd build-${ABI_NAME}

${CMAKE} .. \
  ${CMAKE_OPTIONS} \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
  -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY="BOTH" \
  -DGNUSTEP_CONFIG= `# prevent cmake from finding gnustep-config in install root` \
  -DOLDABI_COMPAT=false `# we're using gnustep-2.0 ABI, which may not be mixed with earlier versions'` \

echo -e "\n### Building"
make -j${MAKE_JOBS}

echo -e "\n### Installing"
make install
