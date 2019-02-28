#!/bin/bash

PROJECT=gnustep-base

set -e # make any subsequent failing command exit the script

cd `dirname $0`/..
export ROOT_DIR=`pwd`

. "${ROOT_DIR}"/env/sdkenv.sh
. "${ROOT_DIR}"/env/toolchain.sh

echo "### Source GNUstep.sh"
. "${ANDROID_GNUSTEP_INSTALL_ROOT}"/share/GNUstep/Makefiles/GNUstep.sh

echo -e "\n### Cloning project"
cd "${SRCROOT}"
rm -rf ${PROJECT}
git clone https://github.com/gnustep/libs-base ${PROJECT}
cd ${PROJECT}

for patch in "${ROOT_DIR}"/patches/${PROJECT}-*.patch; do
  if [ -f $patch ] ; then
    echo -e "\n### Applying `basename "$patch"`"
    patch -p1 < "$patch"
  fi
done

echo -e "\n### Running configure"
./configure \
  --host=${ANDROID_TARGET} \
  --enable-nxconstantstring \
  --disable-invocations \
  --disable-iconv \
  --disable-tls \
  --disable-icu \
  --disable-xml \
  --disable-mixedabi \
  --disable-gdomap \
  --with-cross-compilation-info=${ROOT_DIR}/patches/gnustep-base-cross.config

echo -e "\n### Building"
# use -nopie to avoid ld error: https://lists.gnu.org/archive/html/discuss-gnustep/2015-09/msg00057.html
gnumake LDFLAGS="${LDFLAGS} -nopie" -j8

echo -e "\n### Installing"
gnumake install
