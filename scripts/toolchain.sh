#!/bin/sh

echo "### Set toolchain vars"

# See https://developer.android.com/ndk/guides/other_build_systems

export TOOLCHAIN="${ANDROID_NDK_ROOT}"/toolchains/llvm/prebuilt/${HOST_TAG}
export CC="${TOOLCHAIN}"/bin/${ANDROID_TARGET}${ANDROID_API_LEVEL}-clang
export CXX="${TOOLCHAIN}"/bin/${ANDROID_TARGET}${ANDROID_API_LEVEL}-clang++
export OBJC="${CC}"
export OBJCXX="${CXX}"
export LD="${TOOLCHAIN}"/bin/ld.lld
export AR="${TOOLCHAIN}"/bin/llvm-ar
export AS="${CC}"
export RANLIB="${TOOLCHAIN}"/bin/llvm-ranlib
export STRIP="${TOOLCHAIN}"/bin/llvm-strip
export NM="${TOOLCHAIN}"/bin/llvm-nm
export OBJDUMP="${TOOLCHAIN}"/bin/llvm-objdump
export PKG_CONFIG_PATH="${INSTALL_PREFIX}/lib/pkgconfig"

# -L library search path required for some projects to find libraries (e.g. gnustep-corebase)
# --build-id=sha1 required for Android Studio to locate debug information
export LDFLAGS="-L${INSTALL_PREFIX}/lib -Wl,--build-id=sha1"

# ensure libraries link against shared C++ runtime library
export LIBS="-lc++_shared"

# common options for CMake-based projects
# CMAKE_FIND_USE_CMAKE_PATH=false fixes finding incorrect libraries in $TOOLCHAIN/lib[64] instead of $TOOLCHAIN/sysroot/usr/lib/$ANDROID_TARGET, e.g. for libc++abi.a for libobjc2.
CMAKE_OPTIONS=" \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} \
  -DCMAKE_FIND_USE_CMAKE_PATH=false \
  -DANDROID_ABI=${ABI_NAME} \
  -DANDROID_NDK=${ANDROID_NDK_ROOT} \
  -DANDROID_PLATFORM=android-${ANDROID_API_LEVEL} \
  -DANDROID_STL=c++_shared \
"
