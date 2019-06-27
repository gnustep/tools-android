#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/common.sh

prepare_project "gnustep-corebase" "https://github.com/gnustep/libs-corebase.git"

. "${ROOT_DIR}"/env/toolchain.sh

echo "### Source GNUstep.sh"
. "${INSTALL_PREFIX}"/share/GNUstep/Makefiles/GNUstep.sh

echo -e "\n### Running configure"
./configure \
  --host=${ANDROID_TARGET} \
  --prefix="${INSTALL_PREFIX}" \
  `# for some reason we need to manually specify the include and lib dir` \
  CFLAGS="${CCFLAGS} -I${INSTALL_PREFIX}/include" \
  CPPFLAGS="${CPPFLAGS} -I${INSTALL_PREFIX}/include" \
  LDFLAGS="${LDFLAGS} -L${INSTALL_PREFIX}/lib" \

echo -e "\n### Building"
make -j${MAKE_JOBS} debug=yes

echo -e "\n### Installing"
make install
