#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/../scripts/common.sh

PROJECT=libcurl
GITHUB_REPO=curl/curl
TAG=$(get_latest_github_release_tag $GITHUB_REPO curl-)

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
  -DBUILD_SHARED_LIBS=YES \
  -DBUILD_CURL_EXE=NO \
  -DCURL_CA_BUNDLE=NONE `# disable CA bundle path, needs to be read at runtime from app bundle` \
  -DUSE_LIBIDN2=NO `# Prevent accidental detection of an idn2 installation` \
  -DBUILD_LIBCURL_DOCS=NO \
  -DCURL_USE_LIBPSL=NO \
  -DBUILD_MISC_DOCS=NO \

echo -e "\n### Building"
make -j${MAKE_JOBS}

echo -e "\n### Installing"
make install
