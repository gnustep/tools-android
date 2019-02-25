#!/bin/sh

echo "### Set toolchain vars..."
export TOOLCHAIN="${ANDROID_NDK_HOME}"/toolchains/llvm/prebuilt/darwin-x86_64
export CC="${TOOLCHAIN}"/bin/clang
export CXX="${TOOLCHAIN}"/bin/clang++
export OBJC="${TOOLCHAIN}"/bin/clang
export LD="${CC}"
export CFLAGS="--gcc-toolchain=${TOOLCHAIN} --target=${ANDROID_TARGET}${ANDROID_API_LEVEL} -I${ANDROID_INCLUDE} -I${SYSTEM_HEADERS_DIR} -I${PNG_DIR}/jni"
export CCFLAGS="${CFLAGS}"
export OBJCFLAGS="${CFLAGS}"
export LDFLAGS="${CFLAGS} -L${ANDROID_LIBS} -L${SYSTEM_LIBRARY_DIR}"
