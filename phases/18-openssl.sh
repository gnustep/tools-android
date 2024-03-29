#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/../scripts/common.sh

PROJECT=openssl
GITHUB_REPO=KDAB/android_openssl

# load environment and prepare project
if ! prepare_project $PROJECT $GITHUB_REPO; then
  exit 0
fi

echo -e "\n### Installing headers"

cp -Rf ssl_3/include/ ${INSTALL_PREFIX}/include

echo -e "\n### Installing libraries"

cp -f ssl_3/$ABI_NAME/*.so ${INSTALL_PREFIX}/lib

# create version-less symlinks for libcrypto/libssl.so to versioned libraries
libraries=`ls ssl_3/$ABI_NAME/*.so`
cd ${INSTALL_PREFIX}/lib
for lib in $libraries; do
  libname=`basename $lib`
  if [[ $libname =~ ([a-z]+)[0-9\_]+.so ]]; then
    ln -sf $libname ${BASH_REMATCH[1]}.so
  fi
done

echo -e "\n### Downloading CA bundle (must be installed into Android app bundle)"
mkdir -p "$CACHE_ROOT"
cd "$CACHE_ROOT"
ETAG="cacert-etag.txt"
[ -f $ETAG ] && ETAG_COMPARE="--etag-compare $ETAG"
curl --show-error --fail-with-body --remote-name --etag-save $ETAG $ETAG_COMPARE https://curl.se/ca/cacert.pem
mkdir -p ${INSTALL_PREFIX}/etc/ssl/
cp -f cacert.pem ${INSTALL_PREFIX}/etc/ssl/
