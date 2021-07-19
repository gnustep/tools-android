#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/../scripts/common.sh

PROJECT=libffi
GITHUB_REPO=libffi/libffi
TAG=$(get_latest_github_release_tag $GITHUB_REPO)

# load environment and prepare project
if ! prepare_project $PROJECT $GITHUB_REPO $TAG; then
  exit 0
fi

. "$ROOT_DIR"/scripts/toolchain.sh

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
