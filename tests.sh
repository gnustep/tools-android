#!/bin/sh

echo "== building tests for android"
ARCHS="armeabi-v7a x86 arm64-v8a x86_64"

# Go to source 
cd src/gnustep-base

# Initialize for a given architecture...
for arch in $ARCHS
do
	. ~/Library/Android/GNUstep/${arch}/share/GNUstep/Makefiles/GNUstep.sh
	echo "* Running tests for ${arch}..."
done

exit 0