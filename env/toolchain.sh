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
export PKG_CONFIG_PATH="${INSTALL_PREFIX}/lib/pkgconfig"

# -fuse-ld=gold required to work around BFD ld linker bugs on arm64 with gnustep-2.0 libobjc runtime
# -rpath-link required for linker to find libcxxrt dependency of libobjc
# --build-id=sha1 required for Android Studio to locate debug information
export LDFLAGS="-L${INSTALL_PREFIX}/lib -fuse-ld=gold -Wl,-rpath-link,${INSTALL_PREFIX}/lib -Wl,--build-id=sha1"

# ensure libraries link against shared C++ runtime library
export LIBS="-lc++_shared"

# common options for CMake-based projects
CMAKE_OPTIONS=" \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} \
  -DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=gold `# required to link test executables` \
  -DANDROID_ABI=${ABI_NAME} \
  -DANDROID_NDK=${ANDROID_NDK_ROOT} \
  -DANDROID_PLATFORM=android-${ANDROID_API_LEVEL} \
  -DANDROID_STL=c++_shared \
"