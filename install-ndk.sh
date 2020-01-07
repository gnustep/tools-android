#!/bin/bash
#
# Downloads the specified NDK, and integrates a Clang prebuilt from Google into
# the NDK by performing the same steps as Clang.install() in checkbuild.py:
# https://android.googlesource.com/platform/ndk/+/master/ndk/checkbuild.py
#

set -e # make any subsequent failing command exit the script

cd `dirname $0`
ROOT_DIR=`pwd`

case "$OSTYPE" in
  darwin*)
    ANDROID_ROOT=${HOME}/Library/Android
    HOST_TAG=darwin-x86_64
    ;;
  linux*)
    ANDROID_ROOT=${HOME}/Android
    HOST_TAG=linux-x86_64
    ;;
  *)
    echo "Error: Unsupported OS \"$OSTYPE\"."
    exit 1
esac

display_usage() {
  echo "Usage: $0 -n <NDK_VERSION> -c <CLANG_VERSION>"
  echo "  -r, --rev NDK_REVISION     NDK revision (required, e.g. 'n20')"
  echo "  -c, --clang CLANG_VERSION  Clang prebuilt release (required, e.g. 'r353983c1')"
  echo "  -d, --dest ANDROID_ROOT    Installation destination (default: $ANDROID_ROOT)"
  echo "  -h, --help                 Print usage information and exit"
  echo ""
  echo "A list of available Clang prebuilt versions can be found here:"
  echo "https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/master/README.md#prebuilt-versions"
}

# silence pushd/popd
pushd () {
  command pushd "$@" > /dev/null
}
popd () {
  command popd "$@" > /dev/null
}

# handle command-line options
# adapted from https://stackoverflow.com/a/31024664/1534401
while [[ $# > 0 ]]
do
  key="$1"
  while [[ ${key+x} ]]
  do
    case $key in
      -r|--rev)
        export NDK_VERSION=$2
        shift # option has parameter
        ;;
      -c|--clang)
        export CLANG_VERSION=$2
        shift # option has parameter
        ;;
      -d|--dest)
        export ANDROID_ROOT=$2
        shift # option has parameter
        ;;
      -h|--help)
        display_usage
        exit 0
        ;;
      *)
        # unknown option
        echo Unknown option: $key
        display_usage
        exit 1
        ;;
    esac
    # prepare for next option in this key, if any
    [[ "$key" = -? || "$key" == --* ]] && unset key || key="${key/#-?/-}"
  done
  shift # option(s) fully processed, proceed to next input argument
done

if [[ -z "$NDK_VERSION" || -z "$CLANG_VERSION" ]]; then
  display_usage
  exit 1
fi

# define download URLs for NDK and Clang

NDK_URL=https://dl.google.com/android/repository/android-ndk-$NDK_VERSION-$HOST_TAG.zip
CLANG_URL=https://android.googlesource.com/platform/prebuilts/clang/host/${HOST_TAG/_64/}/+archive/master/clang-$CLANG_VERSION.tar.gz
CLANG_TARGET_BINARIES_URL=https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/master/clang-$CLANG_VERSION/lib64/clang.tar.gz
CLANG_TARGET_RUNTIMES_URL=https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/master/clang-$CLANG_VERSION/runtimes_ndk_cxx.tar.gz

# define paths

TMP_DIR=/tmp/android-ndk-$NDK_VERSION-clang-$CLANG_VERSION
NDK_ROOT=$ANDROID_ROOT/android-ndk-$NDK_VERSION-clang-$CLANG_VERSION
CLANG_DEST=$NDK_ROOT/toolchains/llvm/prebuilt/$HOST_TAG
CLANG_PREBUILT=$TMP_DIR/clang-$CLANG_VERSION

if [ "$HOST_TAG" == "linux-x86_64" ]; then
  CLANG_TARGET_RUNTIMES=$CLANG_PREBUILT/runtimes_ndk_cxx
else
  CLANG_TARGET_BINARIES=$TMP_DIR/clang
  CLANG_TARGET_RUNTIMES=$TMP_DIR/runtimes_ndk_cxx
fi

echo "Download directory: $TMP_DIR"

# download and extract archives

mkdir -p $ANDROID_ROOT
mkdir -p $TMP_DIR

pushd $TMP_DIR

  if [ "$HOST_TAG" == "linux-x86_64" ]; then
    # no need to download target binaries and runtimes on Linux (already included in Clang)
    URLS=($CLANG_URL $NDK_URL)
  else
    URLS=($CLANG_URL $CLANG_TARGET_BINARIES_URL $CLANG_TARGET_RUNTIMES_URL $NDK_URL)
  fi
  
  for URL in ${URLS[@]}; do
    FILE=${URL##*/}
    
    if [ ! -f "$FILE" ]; then
      echo "Downloading $URL:"
      curl -O -# $URL
    fi
    
    if [ "${FILE#*.}" == "tar.gz" ]; then
      mkdir -p clang-$CLANG_VERSION
      echo "Extracting $FILE..."
      FOLDER=${FILE%%.*}
      rm -rf $FOLDER
      mkdir $FOLDER
      tar -xzf $FILE -C $FOLDER
    fi
  done
  
  # extract NDK
  NDK_ARCHIVE=${NDK_URL##*/}
  echo "Extracting $NDK_ARCHIVE..."
  rm -rf $NDK_ROOT
  rm -rf android-ndk-$NDK_VERSION
  unzip -q $NDK_ARCHIVE
  mv android-ndk-$NDK_VERSION $NDK_ROOT

popd

# perform equivalent steps to Clang.install() in checkbuild.py
# https://android.googlesource.com/platform/ndk/+/master/ndk/checkbuild.py

echo "Installing Clang $CLANG_VERSION into NDK $NDK_VERSION..."

pushd $CLANG_PREBUILT

  # remove CXX include directory
  rm -rf include

  pushd bin
  
    # unwrap the compiler symlinks
    cp -f clang.real clang
    cp -f clang++.real clang++
    rm -f clang.real
    rm -f clang++.real

    # remove clang-MAJ.MIN binary
    rm -f clang-?

    # remove lld duplicates and leave ld.lld
    if [[ -h ld.lld ]]; then
      mv -f `readlink ld.lld` ld.lld
    fi
    rm -f ld64.lld
    rm -f lld
    rm -f lld-link
    
  popd

  # copy target binaries from Linux prebuilt
  if [ "$HOST_TAG" != "linux-x86_64" ]; then
    rm -rf lib64/clang
    mv $CLANG_TARGET_BINARIES lib64/
  fi

  # get platform toolchain libraries from runtimes_ndk_cxx
  for VERSION in lib64/clang/*; do
    rm -rf $VERSION/lib/linux
    cp -R $CLANG_TARGET_RUNTIMES/ $VERSION/lib/linux
  done
  
  # clean up target binaries and runtimes
  if [ "$HOST_TAG" != "linux-x86_64" ]; then
    rm -rf $CLANG_TARGET_BINARIES
  fi
  rm -rf $CLANG_TARGET_RUNTIMES

popd

# remove target binaries directory from destination in case versions differ
rm -rf $CLANG_DEST/lib64/clang

# copy clang prebuilt directory over NDK clang
cp -Rf $CLANG_PREBUILT/* $CLANG_DEST

# clean up
rm -rf $CLANG_PREBUILT
rm -rf $TMP_DIR

echo "Done"
