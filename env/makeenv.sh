#!/bin/sh

echo "### Setting make environment"

export ANDROID_SDK=${ANDROID_HOME}
export GSCONFIG=${INSTALL_PREFIX}/bin/gnustep-config
export ADB=${ANDROID_PLATFORM_TOOLS}/adb
