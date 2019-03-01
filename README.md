# GNUstep Android Toolchain

This project comprises a collection of scripts to build a GNUstep toolchain for Android. The toolchain can then be used in an Android project to compile and run Objective-C code using the Foundation library.

As a general goal, the project aims to use the most recent versions of the included libraries and the most modern feature set. This enables use of the following Objective-C features:

* Modern Objective-C runtime
* Automatic Reference Counting (ARC)
* Blocks
* Synthesised property accessors

The toolchain is built using the compiler and tools provided by the standard Android SDK and NDK (installed e.g. via [Android Studio](https://developer.android.com/studio)). It is currently set up to target `armeabi-v7a` and Android API level 21 (5.0 / Lollipop).

## Libraries

The toolchain currently compiles the following libraries for Android:

* [GNUstep Base Library](https://github.com/gnustep/libs-base)
* [libobjc2](https://github.com/gnustep/libobjc2) – using modern (v2) ABI
* [libdispatch](https://github.com/apple/swift-corelibs-libdispatch) – official Apple release from the Swift Core Libraries

## Requirements

The project currently requires using macOS to compile the toolchain, but adapting it for other platforms should be relatively straightforward (contributions welcome).

The following options need to be installed via the Android SDK Manager (e.g. via Android Studio):

* Android 5.0 (Lollipop / API level 21) SDK Platform _– or other SDK Platform as specified in [sdkenv.sh](env/sdkenv.sh)_
* Android SDK Build-Tools
* LLDB
* CMake _– version 3.10.2.4988404 as specified in [sdkenv.sh](env/sdkenv.sh)_
* Android SDK Platform-Tools
* Android SDK Tools
* NDK

## Usage

Run the [build.sh](build.sh) script to build the toolchain. It is installed into `~/Library/Android/GNUstep`.

To use the toolchain from an Android project, you can source `~/Library/Android/GNUstep/etc/makeenv.conf` to set various environment variables for building. Most notably, this defines `$GSCONFIG` for calling _gnustep-config_ to obtain various flags that should be used to compile and link Objective-C files, e.g.

* `$GSCONFIG --variable=CC`
* `$GSCONFIG --variable=LDFLAGS`
* `$GSCONFIG --objc-flags` 
* `$GSCONFIG --base-libs`

Call `$GSCONFIG --help` to obtain the full list of available variables.

## Future work

The following is an (incomplete) list of open work items:

* Add [libxml2](https://github.com/GNOME/libxml2) for GNUstep Base
* Add [libxlst](https://github.com/GNOME/libxslt) for GNUstep Base
* Add [libffi](https://github.com/libffi/libffi) for GNUstep Base
* Add support for arm64 architecture
* Add support for x86 architecture
