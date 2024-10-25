#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/../scripts/common.sh

PROJECT=libxml2
GITHUB_REPO=GNOME/libxml2
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
  -DLIBXML2_WITH_LZMA=NO \
  -DLIBXML2_WITH_PYTHON=NO \
  -DLIBXML2_WITH_ZLIB=NO \
  -DLIBXML2_WITH_TESTS=NO \
  -DLIBXML2_WITH_PROGRAMS=NO \
  -DLIBXML2_WITH_ICU=YES \

echo -e "\n### Building"
make -j${MAKE_JOBS}

echo -e "\n### Installing"
make install
