#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/../scripts/common.sh

PROJECT=openssl
GITHUB_REPO=openssl/openssl
TAG=$(get_latest_github_release_tag $GITHUB_REPO)

# load environment and prepare project
if ! prepare_project $PROJECT $GITHUB_REPO; then
  exit 0
fi

BUILD_TARGET=
case $ABI_NAME in
  armeabi-v7a)
    BUILD_TARGET=android-arm
    ;;
  arm64-v8a)
    BUILD_TARGET=android-arm64
    ;;
  x86)
    BUILD_TARGET=android-x86
    ;;
  x86_64)
    BUILD_TARGET=android-x86_64
    ;;
  *)
esac

SSL_BUILD_TYPE=release
if [ "${BUILD_TYPE}" = "Debug" ]; then
  SSL_BUILD_TYPE=debug
fi

ANDROID_NDK_MAJOR=`basename $ANDROID_NDK_ROOT | cut -d. -f1`
ASM=
# Seems like there is a bug in the r26 ndk which prevents us from compiling some assembly
if [ "$ANDROID_NDK_MAJOR" = "26" ]; then
  ASM=no-asm
fi


echo -e "\n### Running configure"
PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/${HOST_TAG}/bin:$PATH
./Configure \
  shared \
  no-docs \
  no-apps \
  ${ASM} \
  ${BUILD_TARGET} \
  --prefix="${INSTALL_PREFIX}" \
  --${SSL_BUILD_TYPE} \
  -U__ANDROID_API__ \
  -D__ANDROID_API__="${ANDROID_API_LEVEL}" \

echo -e "\n### Building"
make -j${MAKE_JOBS}

echo -e "\n### Installing"
make install

echo -e "\n### Downloading CA bundle (must be installed into Android app bundle)"
mkdir -p "$CACHE_ROOT"
cd "$CACHE_ROOT"
ETAG="cacert-etag.txt"
[ -f $ETAG ] && ETAG_COMPARE="--etag-compare $ETAG"
curl --show-error --fail-with-body --remote-name --etag-save $ETAG $ETAG_COMPARE https://curl.se/ca/cacert.pem
mkdir -p ${INSTALL_PREFIX}/etc/ssl/
cp -f cacert.pem ${INSTALL_PREFIX}/etc/ssl/
