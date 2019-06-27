#!/bin/sh

echo "### Set toolchain vars"

# See https://developer.android.com/ndk/guides/other_build_systems

export TOOLCHAIN="${ANDROID_NDK_HOME}"/toolchains/llvm/prebuilt/${HOST_TAG}
export CC="${TOOLCHAIN}"/bin/${ANDROID_TARGET}${ANDROID_API_LEVEL}-clang
export CXX="${TOOLCHAIN}"/bin/${ANDROID_TARGET}${ANDROID_API_LEVEL}-clang++
export OBJC="${CC}"
export OBJCXX="${CXX}"
export LD="${CC}"
export AR="${TOOLCHAIN}"/bin/${ANDROID_TARGET_BINUTILS}-ar
export AS="${TOOLCHAIN}"/bin/${ANDROID_TARGET_BINUTILS}-as
export RANLIB="${TOOLCHAIN}"/bin/${ANDROID_TARGET_BINUTILS}-ranlib
export STRIP="${TOOLCHAIN}"/bin/${ANDROID_TARGET_BINUTILS}-strip
export CFLAGS="-I${ANDROID_INCLUDE}"
export CCFLAGS=""
export OBJCFLAGS=""
export LDFLAGS="-L${ANDROID_LIB} -Wl,-rpath-link,${INSTALL_PREFIX}/lib" # -rpath-link required for linker to find libcxxrt dependency of libobjc
