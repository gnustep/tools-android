#!/bin/sh

echo "### Setting SDK environment"

# Android SDK
export ANDROID_ROOT=${HOME}/Library/Android
export ANDROID_HOME=${ANDROID_ROOT}/sdk
export ANDROID_NDK_HOME=${ANDROID_HOME}/ndk-bundle
export ANDROID_SYSROOT=${ANDROID_NDK_HOME}/sysroot
export ANDROID_INCLUDE=${ANDROID_SYSROOT}/usr/include
export ANDROID_LIB=${ANDROID_SYSROOT}/usr/lib
export ANDROID_CMAKE_ROOT=${ANDROID_HOME}/cmake/3.10.2.4988404
export ANDROID_PLATFORM_TOOLS=${ANDROID_HOME}/platform-tools

# CMake
export CMAKE=${ANDROID_CMAKE_ROOT}/bin/cmake
export CMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake

# Ninja
export NINJA=${ANDROID_CMAKE_ROOT}/bin/ninja

# Directories
export SRCROOT=${ROOT_DIR}/src
export INSTALL_PREFIX=${ANDROID_ROOT}/GNUstep
export SYSTEM_LIBRARY_DIR=${INSTALL_PREFIX}/lib
export SYSTEM_HEADERS_DIR=${INSTALL_PREFIX}/include

# Target
export HOST_TAG=darwin-x86_64
export ABI_NAME=armeabi-v7a
export ANDROID_API_LEVEL=21
export ANDROID_TARGET=armv7a-linux-androideabi
export BUILD_TYPE=Release
export ANDROID_TARGET_BINUTILS=arm-linux-androideabi
