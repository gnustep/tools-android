export ANDROID_HOME=${HOME}/Library/Android/sdk
export ANDROID_NDK_HOME=${ANDROID_HOME}/ndk-bundle
export ANDROID_CMAKE_ROOT=${ANDROID_HOME}/cmake/3.10.2.4988404
export CMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake
export LOCAL_DISABLE_FATAL_LINKER_WARNINGS=true
export NINJA=${ANDROID_CMAKE_ROOT}/bin/ninja

rm -rf gnustep/libobjc2/build
rm -rf gnustep/libs-base/build
rm -rf gnustei/tools-make/build

${ANDROID_CMAKE_ROOT}/bin/cmake \
  -Hgnustep/libobjc2 \
  -Bgnustep/libobjc2/build \
  -G"Ninja" \
  -DANDROID_ABI=armeabi-v7a \
  -DANDROID_NDK=${ANDROID_NDK_HOME} \
  -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=gnustep/libobjc2/build \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_MAKE_PROGRAM=${ANDROID_CMAKE_ROOT}/bin/ninja \
  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} \
  -DANDROID_NATIVE_API_LEVEL=23 \
  -DANDROID_TOOLCHAIN=clang

cd gnustep/libobjc2/build/CMake/
pwd
sed 's/-Wl,--fatal-warnings//' build.ninja > build2.ninja && mv build2.ninja build.ninja
cat build.ninja
${NINJA} -j6
