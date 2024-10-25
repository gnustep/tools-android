#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/../scripts/common.sh

PROJECT=libxslt
GITHUB_REPO=GNOME/libxslt
TAG=$(get_latest_github_release_tag $GITHUB_REPO)

# load environment and prepare project
if ! prepare_project $PROJECT $GITHUB_REPO $TAG; then
  exit 0
fi

. "$ROOT_DIR"/scripts/toolchain.sh

echo -e "\n### Running cmake"
mkdir -p build-${ABI_NAME}
cd build-${ABI_NAME}

${CMAKE} .. \
  ${CMAKE_OPTIONS} \
  -DBUILD_SHARED_LIBS=NO \
  -DLIBXSLT_WITH_PYTHON=NO \
  -DLIBXSLT_WITH_TESTS=NO \
  -DLIBXSLT_WITH_PROGRAMS=NO \

echo -e "\n### Building"
make -j${MAKE_JOBS}

echo -e "\n### Installing"
make install
