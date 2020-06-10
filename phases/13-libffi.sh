#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/common.sh

latest_release_tag=`curl -s https://api.github.com/repos/libffi/libffi/tags | grep '"name":' | sed -E 's/.*"([^"]+)".*/\1/' | egrep '^v\d+\.\d+(\.\d+)?$' | head -n 1`

if ! prepare_project "libffi" "https://github.com/libffi/libffi.git" $latest_release_tag; then
  exit 0
fi

. "${ROOT_DIR}"/env/toolchain.sh

echo -e "\n### Running autogen"
./autogen.sh

echo -e "\n### Running configure"
./configure \
  --host=${ANDROID_TARGET} \
  --prefix="${INSTALL_PREFIX}" \
  --disable-shared \
  --disable-multi-os-directory `# fixes warning about unsupported -print-multi-os-directory with clang` \

echo -e "\n### Building"
make -j${MAKE_JOBS}

echo -e "\n### Installing"
make install
