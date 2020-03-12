#!/bin/sh

ARCH=$1
DEVICE=$2

export ABI_NAME=${ARCH}

set -e

echo "## initialize environment"
. ./env/sdkenv.sh
. ./env/toolchain.sh
. ./env/makeenv.sh

$ADB start-server

if [ "${ARCH}" == "" ]; then
	#	echo "Architecture specification missing..."
	#echo "usage: $0 <architecture> <device>"
	#exit 0
	# Assume arm if nothing is specified....
	ARCH=armeabi-v7a
fi 

if [ "$DEVICE" == "" ]; then
	DEVICE=`${ADB} devices | grep -v "List of devices" | sed 's/device//g' | head -n 1`
fi

if [ "$DEVICE" == "" ]; then
	echo "Device specification missing or no device/emulator available..."
	echo "usage: $0 <architecture> <device>"
	exit 0
fi 
export GNUSTEP_TESTS_DIR=/data/local/tmp/gnustep-tests-${ARCH}
export ANDROID_DEVICE=${DEVICE}

echo "== building tests for android ${ARCH}"
export PATH=${ANDROID_PLATFORM_TOOLS}:${PATH}
RUN_DIR=`pwd`
cp ${RUN_DIR}/scripts/gnustep-tests /Users/heron/Library/Android/GNUstep/${ARCH}/bin/gnustep-tests

# List devices...
echo "\n* starting server, cleaning up and making directory"
${ADB} devices
${ADB} -s ${DEVICE} shell rm -rf ${GNUSTEP_TESTS_DIR}
${ADB} -s ${DEVICE} shell mkdir -p ${GNUSTEP_TESTS_DIR}

echo "\n* copying files..."
# Translate Architecture names...
case $ARCH in
	arm64-v8a)
		TARGET=aarch64-linux-android
		;;
	armeabi-v7a)
		TARGET=arm-linux-androideabi
		;;
	x86)
		TARGET=i686-linux-android
		;;
	x86_64)
		TARGET=x86_64-linux-android
		;;
	*)
		echo "Error, unknown architecture"
		;;
esac

# Go to source...
cd src/gnustep-base

# Initialize for a given architecture...
. ${INSTALL_PREFIX}/share/GNUstep/Makefiles/GNUstep.sh
cd ${ANDROID_NDK_ROOT} #~/Library/Android/android-ndk-r20-clang-r353983c1

# Copy .so files needed to link against...
${ADB} -s ${DEVICE} shell mkdir -p ${GNUSTEP_TESTS_DIR}/libs
echo "\n- sending toolchain .so files..."
FILES=`find . | grep \\.so$ | grep ${TARGET} | grep toolchains | grep 21`
for i in ${FILES}
do
	${ADB} -s ${DEVICE} push ${i} ${GNUSTEP_TESTS_DIR}/libs
done

echo "\n- sending libc++_shared.so files..."
FILES=`find . | grep \\.so$ | grep ${TARGET} | grep toolchains | grep shared`
for i in ${FILES}
do
	${ADB} -s ${DEVICE} push ${i} ${GNUSTEP_TESTS_DIR}/libs
done

echo "\n- sending GNUstep .so files..."
cd ~/Library/Android/GNUstep/${ARCH}
FILES=`find . | grep \\.so$`
for i in ${FILES}
do
	${ADB} -s ${DEVICE} push ${i} ${GNUSTEP_TESTS_DIR}/libs
done

set +e

# Run tests...
echo "\n\n== running tests for ${ARCH}..."
cd ${RUN_DIR}/src/gnustep-base
pwd
make check

echo "\n\n== cleaning up"
${ADB} -s ${DEVICE} shell rm -rf ${GNUSTEP_TESTS_DIR}

echo "\n\n* done"

exit 0
