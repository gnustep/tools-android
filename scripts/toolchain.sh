#!/bin/sh

echo "### Set toolchain vars"

# Relevant documentation:
# https://developer.android.com/ndk/guides/other_build_systems
# https://android.googlesource.com/platform/ndk/+/master/docs/BuildSystemMaintainers.md

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

# NOTE: The following compiler and linker flags mirror the NDK's CMake toolchain file
# and are recommended by the Android Build System Maintainers Guide (see link above)

# - emit stack guards to protect against security vulnerabilities caused by buffer overruns
# - enable FORTIFY to try to catch incorrect use of standard functions
# - generate position-independent code (PIC) to remove unsupported text relocations
export CFLAGS="-fstack-protector-strong -D_FORTIFY_SOURCE=2 -fPIC"

# -L library search path required for some projects to find libraries (e.g. gnustep-corebase)
# -fuse-ld=lld require to enforce LLD, which is needed e.g. for --no-rosegment flag
# --build-id=sha1 required for Android Studio to locate debug information
# --no-rosegment required for correct unwinding on devices prior to API 29
# --gc-sections is recommended to decrease binary size
export LDFLAGS="-L${INSTALL_PREFIX}/lib -fuse-ld=lld -Wl,--build-id=sha1 -Wl,--no-rosegment -Wl,--gc-sections"

case $ABI_NAME in
  armeabi-v7a)
    # use Thumb instruction set for smaller code
    export CFLAGS="$CFLAGS -mthumb"
    # don't export symbols from libunwind
    export LDFLAGS="$LDFLAGS -Wl,--exclude-libs,libunwind.a"
    ;;
  x86)
    # properly align stacks for global constructors when targeting API < 24
    if [ "$ANDROID_API_LEVEL" -lt "24" ]; then
      export CFLAGS="$CFLAGS -mstackrealign"
    fi
    ;;
esac

export CXXFLAGS=$CFLAGS

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
