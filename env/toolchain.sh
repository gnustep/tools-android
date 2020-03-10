#!/bin/sh

echo "### Set toolchain vars"

# See https://developer.android.com/ndk/guides/other_build_systems

export TOOLCHAIN="${ANDROID_NDK_ROOT}"/toolchains/llvm/prebuilt/${HOST_TAG}
export CC="${TOOLCHAIN}"/bin/${ANDROID_TARGET}${ANDROID_API_LEVEL}-clang
export CXX="${TOOLCHAIN}"/bin/${ANDROID_TARGET}${ANDROID_API_LEVEL}-clang++
export OBJC="${CC}"
export OBJCXX="${CXX}"
export LD="${CC}"
export AR="${TOOLCHAIN}"/bin/${ANDROID_TARGET_BINUTILS}-ar
export AS="${TOOLCHAIN}"/bin/${ANDROID_TARGET_BINUTILS}-as
export RANLIB="${TOOLCHAIN}"/bin/${ANDROID_TARGET_BINUTILS}-ranlib
export STRIP="${TOOLCHAIN}"/bin/${ANDROID_TARGET_BINUTILS}-strip

# -fuse-ld=gold required to work around BFD ld linker bugs on arm64 with gnustep-2.0 libobjc runtime
# -rpath-link required for linker to find libcxxrt dependency of libobjc
# --build-id=sha1 required for Android Studio to locate debug information
export LDFLAGS="-fuse-ld=gold -Wl,-rpath-link,${INSTALL_PREFIX}/lib -Wl,--build-id=sha1"

# ensure libraries link against shared C++ runtime library
export LIBS="-lc++_shared"
