#!/bin/bash

set -e # make any subsequent failing command exit the script

. `dirname $0`/../scripts/common.sh

PROJECT=icu
GITHUB_REPO=unicode-org/icu
TAG=$(get_latest_github_release_tag $GITHUB_REPO release-)

# don't clean project for subsequent ABIs so that the build for the current
# machine is preserved, and because each ABI builds into separate directory
set -- $ABI_NAMES # splits space-separated ABI list into $1, $2 etc.
if [ "${ABI_NAME}" != "$1" ]; then
  NO_CLEAN=true
fi

# load environment and prepare project
if ! prepare_project $PROJECT $GITHUB_REPO $TAG; then
  exit 0
fi

# common configure options when building for either current machine or cross-compilation
CONFIGURE_OPTIONS=" \
  --disable-samples \
  --disable-extras \
  --disable-icuio \
  --disable-layoutex \
  --disable-tests \
"

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
    ${CONFIGURE_OPTIONS}

  echo -e "\n### Building for $BUILD_PLATFORM"
  make -j${MAKE_JOBS}
  
  cd ..
fi

# now cross-compile for Android

. "$ROOT_DIR"/scripts/toolchain.sh

mkdir -p build-${ABI_NAME}
cd build-${ABI_NAME}

echo -e "\n### Running configure"
../source/configure \
  --host=${ANDROID_TARGET} \
  --prefix="${INSTALL_PREFIX}" \
  --with-cross-build=$CROSS_BUILD_DIR \
  ${CONFIGURE_OPTIONS} \

echo -e "\n### Building for $ABI_NAME"
make -j${MAKE_JOBS}

echo -e "\n### Installing"
make install

cd ${INSTALL_PREFIX}/lib

# delete test libraries, so they don't end up bundled in the app
rm -f libicutest.so* libicutu.so*

# Modify SONAME and DT_NEEDED references of all libraries to remove version number, as
# they are not supported by the Android NDK. This is done hackily by replacing all
# occurrences of the versioned SONAMEs to overwrite the version number with zeros.
echo -e "\n### Modifying libraries SONAME"

LIBS=(libicu*.so.*.*)
SONAME_REPLACEMENTS=

for LIB in "${LIBS[@]}"; do # => libicuXXX.so.x.y
  LIB_SONAME=${LIB%.*}      # => libicuXXX.so.x
  LIB_NAME=${LIB%.*.*}      # => libicuXXX.so
  PADDING_LEN=$((${#LIB_SONAME} - ${#LIB_NAME}))
  PADDING=`printf '\\\000%.0s' $(seq 1 $PADDING_LEN)`
  SONAME_REPLACEMENTS="$SONAME_REPLACEMENTS s/${LIB_SONAME//./\.}/${LIB_NAME}$PADDING/g;"
  echo "- ${LIB_SONAME} => ${LIB_NAME}"
done

for LIB in "${LIBS[@]}"; do
  perl -pe "$SONAME_REPLACEMENTS" < $LIB > $LIB.new
  mv -f $LIB.new $LIB
done
