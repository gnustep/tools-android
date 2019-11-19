#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/common.sh

# don't clean project for subsequent builds so that the build for the current
# machine is preserved, and because each ABI builds into separate directory
if [ "$NO_UPDATE" = true ]; then
  NO_CLEAN=true
fi

latest_release_tag=`curl -s https://api.github.com/repos/unicode-org/icu/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'`

prepare_project "icu" "https://github.com/unicode-org/icu" $latest_release_tag

case "$OSTYPE" in
  darwin*)
    BUILD_PLATFORM=MacOSX
    ;;
  linux*)
    BUILD_PLATFORM=Linux
    ;;
  *)
    echo "Error: Unsupported OS \"$OSTYPE\"."
    exit 1
esac

cd icu4c

CROSS_BUILD_DIR=`pwd`/build-$BUILD_PLATFORM

# build for current machine if needed (i.e. only once for all architectures)

if [ ! -d $CROSS_BUILD_DIR ]; then
  mkdir -p $CROSS_BUILD_DIR
  cd $CROSS_BUILD_DIR

  echo -e "\n### Running runConfigureICU"
  ../source/runConfigureICU $BUILD_PLATFORM \
    --prefix="${INSTALL_PREFIX}" \
    --enable-static \
    --disable-shared \
    --disable-samples \
    --disable-extras \
    --disable-tools \
    --disable-icuio \
    --disable-layoutex \
    --disable-tests \

  echo -e "\n### Building for $BUILD_PLATFORM"
  make -j${MAKE_JOBS}
  
  cd ..
fi

# now cross-compile for Android

. "${ROOT_DIR}"/env/toolchain.sh

mkdir -p build-${ABI_NAME}
cd build-${ABI_NAME}

echo -e "\n### Running configure"
../source/configure \
  --host=${ANDROID_TARGET} \
  --prefix="${INSTALL_PREFIX}" \
  --with-cross-build=$CROSS_BUILD_DIR \
  --enable-static \
  --disable-shared \
  --disable-samples \
  --disable-extras \
  --disable-tools \
  --disable-icuio \
  --disable-layoutex \
  --disable-tests \
  CFLAGS="${CFLAGS} -fPIC" `# required to remove unsupported text relocations` \
  CPPFLAGS="${CPPFLAGS} -fPIC" `# required to remove unsupported text relocations` \

echo -e "\n### Building for $ABI_NAME"
make -j${MAKE_JOBS}

echo -e "\n### Installing"
make install
