#!/bin/sh

ARCH=$1

echo "== building tests for android ${ARCH}"
export PATH=~/Library/Android/sdk/platform-tools:${PATH}
DEVICE=`~/Library/Android/sdk/platform-tools/adb devices | grep -v "List of devices attached" | sed "s/device//g" | sed "s/\t//g" | sed "s/ //g"`  
RUN_DIR=`pwd`

# List devices...
echo "\n* starting server"
adb start-server
adb devices
adb shell rm -rf /data/local/temp/*

echo "\n* copying files..."
# Translate Architecture names...
case $ARCH in
	arm64-v8a)
		ARCH_SRCH=aarch64-linux-android
		;;
	armeabi-v7a)
		ARCH_SRCH=arm-linux-androideabi
		;;
	x86)
		ARCH_SRCH=i686-linux-android
		;;
	x86_64)
		ARCH_SRCH=x86_64-linux-android
		;;
	*)
		echo "Error, unknown architecture"
		;;
esac

# Go to source...
cd src/gnustep-base

# Initialize for a given architecture...
. ~/Library/Android/GNUstep/${ARCH}/share/GNUstep/Makefiles/GNUstep.sh
cd ~/Library/Android/android-ndk-r20-clang-r353983c1

# Copy .so files needed to link against...
echo "\n- sending toolchain .so files..."
FILES=`find . | grep \\.so$ | grep ${ARCH_SRCH} | grep toolchains | grep 21`
for i in ${FILES}
do
	adb push ${i} /data/local/tmp
done

echo "\n- sending libc++_shared.so files..."
FILES=`find . | grep \\.so$ | grep ${ARCH_SRCH} | grep toolchains | grep shared`
for i in ${FILES}
do
	adb push ${i} /data/local/tmp
done

echo "\n- sending GNUstep .so files..."
cd ~/Library/Android/GNUstep/${ARCH}
FILES=`find . | grep \\.so$`
for i in ${FILES}
do
	adb push ${i} /data/local/tmp
done

# Run tests...
echo "\n\n== running tests for ${ARCH}..."
cd ${RUN_DIR}/src/gnustep-base
pwd
make check

exit 0
