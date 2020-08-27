#!/bin/sh

# Host
case "$OSTYPE" in
  darwin*)
    ANDROID_ROOT=${HOME}/Library/Android
    ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:-$ANDROID_ROOT/sdk}
    HOST_TAG=darwin-x86_64
    MAKE_JOBS=`sysctl -n hw.ncpu`
    ;;
  linux*)
    ANDROID_ROOT=${HOME}/Android
    ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:-$ANDROID_ROOT/Sdk}
    HOST_TAG=linux-x86_64
    MAKE_JOBS=`nproc`
    ;;
  *)
    echo "Error: Unsupported OS \"$OSTYPE\"."
    exit 1
esac

# Target (allow overrides)
ABI_NAMES=${ABI_NAMES:-armeabi-v7a arm64-v8a x86 x86_64}
ABI_NAME=${ABI_NAME:-armeabi-v7a}
ANDROID_API_LEVEL=${ANDROID_API_LEVEL:-21}
BUILD_TYPE=${BUILD_TYPE:-RelWithDebInfo}

# ABI-dependant properties
case $ABI_NAME in
  armeabi)
    ANDROID_TARGET=arm-linux-androideabi
    ;;
  armeabi-v7a)
    ANDROID_TARGET=armv7a-linux-androideabi
    ANDROID_TARGET_BINUTILS=arm-linux-androideabi
    ;;
  arm64-v8a)
    ANDROID_TARGET=aarch64-linux-android
    ;;
  x86)
    ANDROID_TARGET=i686-linux-android
    ;;
  x86_64)
    ANDROID_TARGET=x86_64-linux-android
    ;;
  *)
    echo "Error: Unsupported ABI \"$ABI_NAME\"."
    echo "Supported ABIs are: armeabi-v7a, arm64-v8a, x86, x86_64"
    exit 1
esac

if [ -z "$ANDROID_TARGET_BINUTILS" ]; then
  ANDROID_TARGET_BINUTILS=$ANDROID_TARGET
fi

# Phases
PHASE_GLOB="${ROOT_DIR}/phases/[0-9][0-9]-*.sh"
phase_name() {
  name=`basename -s .sh $1`
  echo ${name/[0-9][0-9]-/}
}

# Directories
SRCROOT=${SRCROOT:-$ROOT_DIR/src}
CACHE_ROOT=${CACHE_ROOT:-$ROOT_DIR/cache}
INSTALL_ROOT=${INSTALL_ROOT:-$ANDROID_ROOT/GNUstep}
INSTALL_PREFIX=$INSTALL_ROOT/$ABI_NAME
BUILD_TXT=${BUILD_TXT:-$INSTALL_ROOT/build.txt}
BUILD_LOG=${BUILD_LOG:-$INSTALL_ROOT/build.log}

# Android SDK
ANDROID_NDK_VERSION=${ANDROID_NDK_VERSION:-21.3.6528147}
ANDROID_NDK_ROOT=${ANDROID_NDK_ROOT:-$ANDROID_SDK_ROOT/ndk/$ANDROID_NDK_VERSION}
ANDROID_PLATFORM_TOOLS=${ANDROID_PLATFORM_TOOLS:-$ANDROID_SDK_ROOT/platform-tools}

# CMake
CMAKE=${CMAKE:-cmake}
CMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake

# GNUstep Make
case $BUILD_TYPE in
  Debug)
    GNUSTEP_MAKE_OPTIONS="$GNUSTEP_MAKE_OPTIONS debug=yes"
    ;;
  RelWithDebInfo)
    GNUSTEP_MAKE_OPTIONS="$GNUSTEP_MAKE_OPTIONS debug=yes OPTFLAG=-Os"
    ;;
  Release)
    GNUSTEP_MAKE_OPTIONS="$GNUSTEP_MAKE_OPTIONS OPTFLAG=-Os"
    ;;
  *)
    echo "Error: unknown build type \"$BUILD_TYPE\"."
    exit 1
esac
