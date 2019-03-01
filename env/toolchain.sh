#!/bin/sh

echo "### Set toolchain vars"

# See https://developer.android.com/ndk/guides/other_build_systems

export TOOLCHAIN="${ANDROID_NDK_HOME}"/toolchains/llvm/prebuilt/${HOST_TAG}
export CC="${TOOLCHAIN}"/bin/clang
export CXX="${TOOLCHAIN}"/bin/clang++
export OBJC="${TOOLCHAIN}"/bin/clang
export LD="${CC}"
export CFLAGS="--gcc-toolchain=${TOOLCHAIN} --target=${ANDROID_TARGET}${ANDROID_API_LEVEL} -I${ANDROID_INCLUDE} -I${SYSTEM_HEADERS_DIR}"
export CCFLAGS=""
export OBJCFLAGS=""
export LDFLAGS="${CFLAGS} -L${ANDROID_LIB} -L${SYSTEM_LIBRARY_DIR}"
