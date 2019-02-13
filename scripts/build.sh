# Script by Gregory Casamento & Ivan Vucica
#
# from android documentation:
# http://web.archive.org/web/20190210195102/
# https://developer.android.com/ndk/guides/cmake

export ANDROID_HOME="${HOME}"/Library/Android/sdk
export ANDROID_NDK_HOME=${ANDROID_HOME}/ndk-bundle
export ANDROID_CMAKE_ROOT=${ANDROID_HOME}/cmake/3.10.2.4988404
export CMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake
export NINJA=${ANDROID_CMAKE_ROOT}/bin/ninja
export ROOT_DIR=`pwd`
export GSROOT=${ROOT_DIR}/gnustep
export INSTALL_PREFIX=${ROOT_DIR}/android-gnustep
export ANDROID_GNUSTEP_INSTALL_ROOT="${INSTALL_PREFIX}"

cd $ROOT_DIR

echo "### Setup build for libobjc2"
rm -rf "${GSROOT}"
mkdir -p "${GSROOT}"
  
if [[ ! -e "${GSROOT}"/libobjc2 ]] ; then
  cd "${GSROOT}"
  git clone https://github.com/gnustep/libobjc2
  mkdir -p "${GSROOT}"/libobjc2/build
fi

echo "### Build libobjc2"
cd "${GSROOT}"
${ANDROID_CMAKE_ROOT}/bin/cmake \
  -H"${GSROOT}"/libobjc2 \
  -B"${GSROOT}"/libobjc2/build \
  -G"Ninja" \
  -DANDROID_ABI=armeabi-v7a \
  -DANDROID_NDK=${ANDROID_NDK_HOME} \
  -DCMAKE_LIBRARY_OUTPUT_DIRECTORY="${GSROOT}"/libobjc2/build \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_MAKE_PROGRAM=${NINJA} \
  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} \
  -DANDROID_NATIVE_API_LEVEL=23 \
  -DANDROID_TOOLCHAIN=clang \
  -DCMAKE_INSTALL_PREFIX="${ANDROID_GNUSTEP_INSTALL_ROOT}"

cd ${GSROOT}/libobjc2/build
pwd

sed 's/-Wl,--fatal-warnings//' build.ninja > build2.ninja && mv build2.ninja build.ninja
#sed 's/-stdlib=libc++//g' build.ninja > build2.ninja && mv build2.ninja build.ninja

${NINJA} -j6

if [ "$?" != "0" ]; then
    echo "### LIBOBJC2 BUILD FAILED!!!"
    exit 0
fi

echo "### Set toolchain vars..."
export TOOLCHAIN="${ANDROID_NDK_HOME}"/toolchains/llvm/prebuilt/darwin-x86_64
export CC="${TOOLCHAIN}"/bin/clang
export CXX="${TOOLCHAIN}"/bin/clang++
export OBJC="${TOOLCHAIN}"/bin/clang
export LD="${CC}"
export CFLAGS="--gcc-toolchain=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64 --target=armv7-none-linux-androideabi23"
export OBJCFLAGS="${CFLAGS}"
export LDFLAGS="${CFLAGS}"

echo "### Build make..."
cd "${GSROOT}"
git clone https://github.com/gnustep/tools-make
cd "${GSROOT}"/tools-make
./configure --host=arm-linux-androideabi --prefix="${ANDROID_GNUSTEP_INSTALL_ROOT}" OBJCFLAGS="${OBJCFLAGS} -integrated-as"
gnumake install
if [ "$?" != "0" ]; then
    echo "### MAKE BUILD FAILED!!!"
    exit 0
fi
. "${ANDROID_GNUSTEP_INSTALL_ROOT}"/share/GNUstep/Makefiles/GNUstep.sh


echo "### Setup build for base..."
cd "${GSROOT}"
git clone https://github.com/gnustep/libs-base
cd "${GSROOT}"/libs-base
configure it
./configure --host=arm-linux-androideabi \
  --enable-nxconstantstring \
  --disable-invocations \
  --disable-iconv \
  --disable-tls \
  --disable-icu \
  --disable-xml \
  --disable-openssl \
  --disable-mixedabi \
  --with-cross-compilation-info=./cross.config

echo "### Build base..."
sed 's/cross_objc2_runtime=0/cross_objc2_runtime=1/g' cross.config > cross.config2 && mv cross.config2 cross.config
gnumake LD="${LD}" LDFLAGS="${LDFLAGS} -nopie" -j6 messages=yes install
if [ "$?" != "0" ]; then
    echo "### BASE BUILD FAILED!!!"
    exit 0
fi
