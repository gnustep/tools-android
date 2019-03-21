#!/bin/bash

PROJECT=libxml2

set -e # make any subsequent failing command exit the script

cd `dirname $0`/..
export ROOT_DIR=`pwd`

. "${ROOT_DIR}"/env/sdkenv.sh
. "${ROOT_DIR}"/env/toolchain.sh

echo -e "\n### Cloning project"
cd "${SRCROOT}"
rm -rf ${PROJECT}
git clone https://github.com/GNOME/libxml2.git ${PROJECT}
cd ${PROJECT}

for patch in "${ROOT_DIR}"/patches/${PROJECT}-*.patch; do
  if [ -f $patch ] ; then
    echo -e "\n### Applying `basename "$patch"`"
    patch -p1 --forward < "$patch" || [ $? -eq 1 ]
  fi
done

echo -e "\n### Running autogen"
NOCONFIGURE=1 ./autogen.sh

echo -e "\n### Running configure"
./configure \
  --host=${ANDROID_TARGET} \
  --prefix="${INSTALL_PREFIX}" \
  --without-python \
  --without-lzma \
  --disable-shared \
  CFLAGS="${CFLAGS} -fPIC" `# required to remove unsupported text relocations` \

echo -e "\n### Building"
make

echo -e "\n### Installing"
make install
