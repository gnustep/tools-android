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
export CFLAGS="--gcc-toolchain=${TOOLCHAIN} --target=${ANDROID_TARGET}${ANDROID_API_LEVEL} -I${ANDROID_INCLUDE} -I${SYSTEM_HEADERS_DIR}"
export CCFLAGS=""
export OBJCFLAGS=""
export LDFLAGS="${CFLAGS} -L${ANDROID_LIB} -L${SYSTEM_LIBRARY_DIR}"
