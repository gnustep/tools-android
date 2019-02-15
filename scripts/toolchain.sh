#!/bin/sh

echo "### Set toolchain vars..."
export TOOLCHAIN="${ANDROID_NDK_HOME}"/toolchains/llvm/prebuilt/darwin-x86_64
export CC="${TOOLCHAIN}"/bin/clang
export CXX="${TOOLCHAIN}"/bin/clang++
export OBJC="${TOOLCHAIN}"/bin/clang
export LD="${CC}"
export CFLAGS="--gcc-toolchain=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64 --target=armv7-none-linux-androideabi23"
export OBJCFLAGS="${CFLAGS} -I${SYSTEM_HEADERS_DIR}"
export LDFLAGS="${CFLAGS} -L${SYSTEM_LIBRARY_DIR}"


