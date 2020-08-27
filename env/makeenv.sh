#!/bin/sh

echo "### Setting make environment"

export GSCONFIG=${INSTALL_PREFIX}/bin/gnustep-config
export ADB=${ANDROID_PLATFORM_TOOLS}/adb
