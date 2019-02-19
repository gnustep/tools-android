# Script by Gregory Casamento & Ivan Vucica
#
# from android documentation:
# http://web.archive.org/web/20190210195102/
# https://developer.android.com/ndk/guides/cmake

export ROOT_DIR=`pwd`

. ${ROOT_DIR}/scripts/sdkenv.sh

cd $ROOT_DIR

echo "###### SETTING UP GNUSTEP ANDROID BUILD SYSTEM"
echo "### Setup build for libobjc2"
rm -rf "${GSROOT}"
mkdir -p "${GSROOT}"
rm -rf ${INSTALL_PREFIX}
mkdir ${INSTALL_PREFIX}
 
cd "${GSROOT}"
git clone https://github.com/gnustep/libobjc2
mkdir -p "${GSROOT}"/libobjc2/build

echo " "
echo "### Build libobjc2"
cd "${GSROOT}"
${ANDROID_CMAKE_ROOT}/bin/cmake \
  -H"${GSROOT}"/libobjc2 \
  -B"${GSROOT}"/libobjc2/build \
  -G"Ninja" \
  -DANDROID_ABI=${ABI_NAME} \
  -DANDROID_NDK=${ANDROID_NDK_HOME} \
  -DCMAKE_LIBRARY_OUTPUT_DIRECTORY="${GSROOT}"/libobjc2/build \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_MAKE_PROGRAM=${NINJA} \
  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} \
  -DANDROID_NATIVE_API_LEVEL=${ABI_LEVEL} \
  -DANDROID_TOOLCHAIN=clang \
  -DCMAKE_INSTALL_PREFIX="${ANDROID_GNUSTEP_INSTALL_ROOT}"

cd ${GSROOT}/libobjc2/build
sed 's/-Wl,--fatal-warnings//' build.ninja > build2.ninja && mv build2.ninja build.ninja

${NINJA} -j6
mkdir -p ${SYSTEM_LIBRARY_DIR}
mkdir -p ${SYSTEM_HEADERS_DIR}/objc

cp libobjc.so ${SYSTEM_LIBRARY_DIR}
cp -r ../objc/* ${SYSTEM_HEADERS_DIR}/objc
# cp -r ../objc/* ${SYSTEM_HEADERS_DIR}

if [ "$?" != "0" ]; then
    echo "### LIBOBJC2 BUILD FAILED!!!"
    exit 0
else
    echo "### Done with libobj2 build"
fi

. ${ROOT_DIR}/scripts/toolchain.sh

echo " "
echo "#### BUILD MAKE SYSTEM"
echo "### Build make..."
cd "${GSROOT}"
git clone https://github.com/gnustep/tools-make
cd "${GSROOT}"/tools-make
./configure --host=arm-linux-androideabi --prefix="${ANDROID_GNUSTEP_INSTALL_ROOT}" --enable-objc-arc=yes --with-layout=gnustep OBJCFLAGS="${OBJCFLAGS} -integrated-as"
gnumake GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install
if [ "$?" != "0" ]; then
    echo "### MAKE BUILD FAILED!!!"
    exit 0
else
    echo "### Done building make"
fi

echo "### Source ${ANDROID_GNUSTEP_INSTALL_ROOT}/share/GNUstep/Makefiles/GNUstep.sh"
. "${ANDROID_GNUSTEP_INSTALL_ROOT}"/System/Library/Makefiles/GNUstep.sh

echo " "
echo "#### BUILD GNUSTEP FOUNDATION"
echo "### Setup build for base..."
cd "${GSROOT}"
git clone https://github.com/gnustep/libs-base
cd "${GSROOT}"/libs-base
pwd
sed 's/cross_objc2_runtime=0/cross_objc2_runtime=1/g' cross.config > cross.config2 && mv cross.config2 cross.config
cat cross.config
sed 's/SUBPROJECTS += Tools NSTimeZones Resources Tests//' GNUmakefile > GNUmakefile2 && mv GNUmakefile2 GNUmakefile

./configure --host=arm-linux-androideabi \
  --enable-nxconstantstring \
  --disable-invocations \
  --disable-iconv \
  --disable-tls \
  --disable-icu \
  --disable-xml \
  --disable-mixedabi \
  --disable-gdomap \
  --with-cross-compilation-info=./cross.config

echo " "
echo "### Build base..."
sed 's/cross_objc2_runtime=0/cross_objc2_runtime=1/g' cross.config > cross.config2 && mv cross.config2 cross.config
gnumake LD="${LD}" LDFLAGS="${LDFLAGS} -nopie" -j6 GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install
if [ "$?" != "0" ]; then
    echo "### BASE BUILD FAILED!!!"
    exit 0
else
    echo ### "Done building libobjc2"
fi

echo " "
echo "#### BUILD GUI DEPENDENCIES"
echo "### Setup build for libpng"
cd "${GSROOT}"
git clone https://github.com/julienr/libpng-android.git
cd "${GSROOT}"/libpng-android
PATH="$PATH:$ANDROID_NDK_HOME" ./build.sh
if [ "$?" != "0" ]; then
    echo "### LIBPNG BUILD FAILED!!!"
    exit 0
else
    echo "### Done building libpng"
fi
