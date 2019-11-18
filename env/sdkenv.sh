#!/bin/sh

# Host
case "$OSTYPE" in
  darwin*)
    ANDROID_ROOT=${HOME}/Library/Android
    ANDROID_HOME=${ANDROID_ROOT}/sdk
    HOST_TAG=darwin-x86_64
    MAKE_JOBS=`sysctl -n hw.ncpu`
    ;;
  linux*)
    ANDROID_ROOT=${HOME}/Android
    ANDROID_HOME=${ANDROID_ROOT}/Sdk
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

# Directories
SRCROOT=${ROOT_DIR}/src
INSTALL_ROOT=${ANDROID_ROOT}/GNUstep
INSTALL_PREFIX=${INSTALL_ROOT}/${ABI_NAME}
BUILD_TXT=${INSTALL_ROOT}/build.txt
BUILD_LOG=${INSTALL_ROOT}/build.log

# Android SDK
ANDROID_NDK_VERSION=${ANDROID_NDK_VERSION:-r20}
ANDROID_CLANG_VERSION=${ANDROID_CLANG_VERSION:-r353983d}
ANDROID_NDK_HOME=${ANDROID_NDK_HOME:-$ANDROID_ROOT/android-ndk-$ANDROID_NDK_VERSION-clang-$ANDROID_CLANG_VERSION}
ANDROID_SYSROOT=${ANDROID_NDK_HOME}/sysroot
ANDROID_INCLUDE=${ANDROID_SYSROOT}/usr/include
ANDROID_LIB=${ANDROID_SYSROOT}/usr/lib
ANDROID_CMAKE_ROOT=${ANDROID_HOME}/cmake/3.10.2.4988404
ANDROID_PLATFORM_TOOLS=${ANDROID_HOME}/platform-tools

# CMake
CMAKE=${CMAKE:-cmake}
CMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake

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

# Ninja
NINJA=${ANDROID_CMAKE_ROOT}/bin/ninja
