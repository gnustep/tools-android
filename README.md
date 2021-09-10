GNUstep Android Toolchain
=========================

[![CI](https://github.com/gnustep/tools-android/actions/workflows/ci.yml/badge.svg)](https://github.com/gnustep/tools-android/actions/workflows/ci.yml?query=branch%3Amaster)

This project comprises a collection of scripts to build a GNUstep toolchain for Android. The toolchain can then be used in an Android project to compile and run Objective-C code using the Foundation and CoreFoundation libraries.

The toolchain is built using the Android NDK (installed e.g. via [Android Studio](https://developer.android.com/studio)), and is set up to target Android API level 23 (6.0 / Marshmallow) and all common Android ABIs (armeabi-v7a, arm64-v8a, x86, x86_64).


Libraries
---------

The toolchain currently compiles the following libraries for Android:

* [GNUstep Base Library](https://github.com/gnustep/libs-base) (Foundation)
* [GNUstep CoreBase Library](https://github.com/gnustep/libs-corebase) (CoreFoundation)
* [libobjc2](https://github.com/gnustep/libobjc2) (using gnustep-2.0 runtime)
* [libdispatch](https://github.com/apple/swift-corelibs-libdispatch) (official Apple release from the Swift Core Libraries)
* [libffi](https://github.com/libffi/libffi)
* [libiconv](https://www.gnu.org/software/libiconv/)
* [libxml2](https://github.com/GNOME/libxml2)
* [libxslt](https://github.com/GNOME/libxslt)
* [ICU](https://github.com/unicode-org/icu)


Requirements
------------

Supported host platforms are macOS and Linux.

The toolchain requires the Android NDK, which can be installed via [Android Studio](https://developer.android.com/studio)’s SDK Manager. The NDK installation will be located using the `ANDROID_NDK_ROOT` environment variable if set, or otherwise it will use the latest version in `~/Library/Android/sdk/ndk` (macOS) / `~/Android/sdk/ndk` (Linux). A different NDK path can also be provided using the `--ndk` flag when building the toolchain (see below).

Please note that NDK r21 or later is required, as earlier NDK releases contain Clang versions with bugs which prevent usage of the gnustep-2.0 Objective-C runtime.


Installation
------------

To install a pre-built release, download it from [the releases on GitHub](https://github.com/gnustep/tools-android/releases) and unpack the "GNUstep" folder into the following location depending on your OS (`$GNUSTEP_HOME`):

* macOS: `~/Library/Android/GNUstep`
* Linux: `~/Android/GNUstep`


Using the Toolchain
-------------------

The [android-examples](https://github.com/gnustep/android-examples) repository contains Android Studio and Qt example projects using this project that can be used as templates for integrating Objective-C code into new or existing Android projects.

To use the toolchain from an Android project, you can use `$GNUSTEP_HOME/$ABI_NAME/bin/gnustep-config` to obtain various flags that should be used to compile and link Objective-C files, e.g.:

* `gnustep-config --variable=CC`
* `gnustep-config --objc-flags` (or `--debug-flags`)
* `gnustep-config --base-libs`

Call `gnustep-config --help` to obtain the full list of available variables.


Status and Known Issues
-----------------------

The toolchain is being used in production in an award-winnning music app available on Google Play.

Following are some notes and known issues about using GNUstep on Android.

* GNUstep base currently has no native integration between the Android run-loop and NSRunLoop or the libdispatch main queue, so things like `-performSelector:withObject:afterDelay:` or dispatching on `dispatch_get_main_queue()` will not work out of the box. An integration depends on the setup of the app (e.g. whether using Android Studio, Qt, or something else), and is possible to add in the app by swizzing NSRunLoop. Feel free to open an issue if this is of interest to you and you would like more information.
* GNUstep Base is integrated with Android’s [app-specific storage](https://developer.android.com/training/data-storage) and uses the path returned by `Context.getFilesDir()` as `NSHomeDirectory()` and when querying for directory paths (`NSLibraryDirectory`, `NSApplicationSupportDirectory`, etc.). It also uses `Context.getCacheDir()` as `NSTemporaryDirectory` and `NSCachesDirectory` (with `NSUserDomainMask`).
* GNUstep Base is further integrated with the [Android asset manager](https://developer.android.com/reference/android/content/res/AssetManager), and supports accessing the app’s resources from `[NSBundle mainBundle]` via APIs such as `-pathForResource:ofType:` and `-URLForResource:ofType:`, and reading them using NSFileManager, NSFileHandle, and NSDirectoryEnumerator APIs. This is done by returning paths from NSBundle APIs with a fixed, fake, per-app prefix (`Context.getPackageCodePath()` without extension + `/Resources`), which internally get routed through the NDK’s [AAsset](https://developer.android.com/ndk/reference/group/asset) API for reading.
* Note that NSDirectoryEnumerator is not able to enumerate directories in the app’s main bundle due to a [limitation](https://issuetracker.google.com/issues/140538113) of the AAssetDir API.
* The app must call `GSInitializeProcessAndroid()` (defined in `NSProcessInfo.h`) on launch in order to initialize the above Android-specific functionality in GNUstep.
* GNUstep Base doesn’t currently get the system languages on Android, which combined with the inability to list directories in the main bundle (see above) means that `NSLocalizedString()` won’t work out of the box even if localized strings are present in the app’s assets. As a workaround, the app should manually call `-[NSUserDefaults setUserLanguages:]` with a list of supported locales ordered by the user’s system language preferences.
* GNUstep Base will also currently not return the system locale as the current `NSLocale` on Android (the current locale will always default to `en_US_POSIX`). As a workaround, the app can manually set the system’s locale identifier for the key `"Locale"` in NSUserDefaults, and use `-[NSLocale autoupdatingCurrentLocale]` to retreive the locale.
* Android will not output stdout or stderr to logcat by default, which might cause some log or error output from GNUstep or other libraries to be missing. You can run a thread in your app to write these streams to the Android log to work around this, which is recommended for debugging.

For the last three points above please refer to [GSInitialize.m](https://github.com/gnustep/android-examples/blob/master/hello-objectivec/app/src/main/cpp/GSInitialize.m) in the examples for details.


Prerequisites for Building
--------------------------

The following packages are required for building the toolchain.

**macOS**

Install required packages via [Homebrew](https://brew.sh):

```
brew install git-lfs cmake autoconf automake libtool pkg-config
git lfs install
```

**Linux**

Install required packages via APT:

```
sudo apt install git git-lfs curl cmake make autoconf libtool pkg-config texinfo python3-distutils
git lfs install
```

Please note that you need to have CMake version 3.15.1 or later ([for libdispatch](https://github.com/apple/swift-corelibs-libdispatch/blob/master/CMakeLists.txt#L2)).


Building the Toolchain
----------------------

Run the [build.sh](build.sh) script to build the toolchain yourself:

```
Usage: ./build.sh
  --prefix INSTALL_ROOT      Install toolchain into given directory (default: see below)
  --dist-root DIST_ROOT      Make toolchain relocatable to given path relative to home folder on other machines
                             (use "HOME" as placeholder for home folder, e.g. "HOME/Library/Android/GNUstep")
  -n, --ndk NDK_PATH         Path to existing Android NDK (default: ANDROID_NDK_ROOT)
  -a, --abis ABI_NAMES       ABIs being targeted (default: "armeabi-v7a arm64-v8a x86 x86_64")
  -l, --level API_LEVEL      Android API level being targeted (default: 23)
  -b, --build BUILD_TYPE     Build type "Debug" or "Release" or "RelWithDebInfo" (default: RelWithDebInfo)
  -u, --no-update            Don't update projects to latest version from GitHub
  -c, --no-clean             Don't clean projects during build (e.g. for building local changes, only applies to first ABI being built)
  -p, --patches DIR          Apply additional patches from given directory
  -o, --only PHASE           Build only the given phase (e.g. "gnustep-base", requires previous build)
  -h, --help                 Print usage information and exit
```

The toolchain builds and installs the GNUstep toolchain into the following location (`$GNUSTEP_HOME`):

* macOS: `~/Library/Android/GNUstep`
* Linux: `~/Android/GNUstep`

The build for each supported ABI is installed into its separate subfolder at that location (both libraries and header files differ per ABI).


Acknowledgements
----------------

Based on original work by Ivan Vučica.
