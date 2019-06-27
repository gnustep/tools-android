#!/bin/sh

# Host
case "$OSTYPE" in
  darwin*)
    ANDROID_ROOT=${HOME}/Library/Android
    ANDROID_HOME=${ANDROID_ROOT}/sdk
    HOST_TAG=${HOST_TAG:-darwin-x86_64}
    ;;
  linux*)
    ANDROID_ROOT=${HOME}/Android
    ANDROID_HOME=${ANDROID_ROOT}/Sdk
    HOST_TAG=${HOST_TAG:-linux-x86_64}
    ;;
  *)
    echo "Error: Unsupported OS \"$OSTYPE\"."
    exit 1
esac

# Target (allow overrides)
ABI_NAMES=${ABI_NAMES:-armeabi-v7a arm64-v8a x86 x86_64}
ABI_NAME=${ABI_NAME:-armeabi-v7a}
ANDROID_API_LEVEL=${ANDROID_API_LEVEL:-21}
BUILD_TYPE=${BUILD_TYPE:-Debug}

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
ANDROID_NDK_HOME=${ANDROID_HOME}/ndk-bundle
ANDROID_SYSROOT=${ANDROID_NDK_HOME}/sysroot
ANDROID_INCLUDE=${ANDROID_SYSROOT}/usr/include
ANDROID_LIB=${ANDROID_SYSROOT}/usr/lib
ANDROID_CMAKE_ROOT=${ANDROID_HOME}/cmake/3.10.2.4988404
ANDROID_PLATFORM_TOOLS=${ANDROID_HOME}/platform-tools

# CMake
CMAKE=${ANDROID_CMAKE_ROOT}/bin/cmake
CMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake

# Ninja
NINJA=${ANDROID_CMAKE_ROOT}/bin/ninja
