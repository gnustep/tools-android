#!/bin/sh

export ANDROID_HOME="${HOME}"/Library/Android/sdk
export ANDROID_NDK_HOME=${ANDROID_HOME}/ndk-bundle
export ANDROID_CMAKE_ROOT=${ANDROID_HOME}/cmake/3.10.2.4988404
export CMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake
export NINJA=${ANDROID_CMAKE_ROOT}/bin/ninja
export ROOT_DIR=`pwd`
export GSROOT=${ROOT_DIR}/src
export INSTALL_PREFIX=${ROOT_DIR}/GNUstep
export ANDROID_GNUSTEP_INSTALL_ROOT="${INSTALL_PREFIX}"
export SYSTEM_LIBRARY_DIR=${INSTALL_PREFIX}/System/Library/Libraries
export SYSTEM_HEADERS_DIR=${INSTALL_PREFIX}/System/Library/Headers

