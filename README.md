GNUstep Android Toolchain
=========================

This project comprises a collection of scripts to build a GNUstep toolchain for Android. The toolchain can then be used in an Android project to compile and run Objective-C code using the Foundation and CoreFoundation libraries.

The toolchain is built using the tools provided by the standard Android SDK (installed e.g. via [Android Studio](https://developer.android.com/studio)), plus a custom NDK using the latest Clang prebuilt from Google (required to work around bugs in the older Clang version shipping with the official NDK which prevent usage of the gnustep-2.0 Objective C runtime).

The toolchain is set up to target Android API level 21 (5.0 / Lollipop) and supports all common Android ABIs (armeabi-v7a, arm64-v8a, x86, x86_64).

Libraries
---------

The toolchain currently compiles the following libraries for Android:

* [GNUstep Base Library](https://github.com/gnustep/libs-base) (Foundation)
* [GNUstep CoreBase Library](https://github.com/gnustep/libs-corebase) (CoreFoundation)
* [libobjc2](https://github.com/gnustep/libobjc2) (using gnustep-2.0 runtime)
* [libdispatch](https://github.com/apple/swift-corelibs-libdispatch) (official Apple release from the Swift Core Libraries)
* [libcxxrt](https://github.com/pathscale/libcxxrt) (for Objective-C++ exception support)
* [libffi](https://github.com/libffi/libffi)
* [libxml2](https://github.com/GNOME/libxml2)
* [libxslt](https://github.com/GNOME/libxslt)
* [ICU](https://github.com/unicode-org/icu)

Requirements
------------

Supported host platforms are macOS and Linux.

You must have [Android Studio](https://developer.android.com/studio), and have the following options installed in the SDK Manager:

* CMake _– version 3.10.2.4988404 as specified in [sdkenv.sh](env/sdkenv.sh)_

Additionally the following packages are required depending on your system.

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

Usage
-----

Run the [build.sh](build.sh) script to build the toolchain:

```
Usage: ./build.sh
  -r, --rev NDK_REVISION     NDK revision (default: r20)
  -c, --clang CLANG_VERSION  Clang prebuilt release (default: r353983c1)
  -n, --ndk NDK_PATH         Path to existing Android NDK (default: ~/Library/Android/android-ndk-r20-clang-r353983c1)
  -a, --abis ABI_NAMES       ABIs being targeted (default: "armeabi-v7a arm64-v8a x86 x86_64")
  -l, --level API_LEVEL      Android API level being targeted (default: 21)
  -b, --build BUILD_TYPE     Build type "Debug" or "Release" or "RelWithDebInfo" (default: RelWithDebInfo)
  -u, --no-update            Don't update projects to latest version from GitHub
  -c, --no-clean             Don't clean projects during build (e.g. for building local changes, only applies to first ABI being built)
  -p, --patches DIR          Apply additional patches from given directory
  -o, --only PHASE           Build only the given phase (e.g. "gnustep-base", requires previous build)
  -h, --help                 Print usage information and exit
```

The toolchain automatically downloads and installs the NDK and prebuilt Clang release (via [install-ndk.sh](install-ndk.sh)), and builds and installs the GNUstep toolchain into the following location (`$GNUSTEP_HOME`):

* macOS: `~/Library/Android/GNUstep`
* Linux: `~/Android/GNUstep`

The build for each supported ABI is installed into its separate subfolder at that location (both libraries and header files differ per ABI).

To use the toolchain from an Android project, you can use `$GNUSTEP_HOME/$ABI_NAME/bin/gnustep-config` to obtain various flags that should be used to compile and link Objective-C files, e.g.

* `gnustep-config --variable=CC`
* `gnustep-config --objc-flags` (or `--debug-flags`)
* `gnustep-config --base-libs`

Call `gnustep-config --help` to obtain the full list of available variables.

You may also want to configure your app’s build environment to use the custom NDK (e.g. in Android Studio), which is installed into the following location:

* macOS: `~/Library/Android/android-ndk-<NDK_REVISION>-clang-<CLANG_VERSION>`
* Linux: `~/Android/android-ndk-<NDK_REVISION>-clang-<CLANG_VERSION>`

Step by step Android project configuration
------------------------------------------
1. Create or open an android project. Java or Kotlin works.
2. In the project pane, switch to "Project Files".
3. Create a new folder "app/src/main/cpp".
4. Add your existing Objective-C header- and implementation-files to the cpp folder.
5. Copy the sample projects [CMakeLists.txt](https://github.com/gnustep/android-examples/blob/master/hello-objectivec/app/src/main/cpp/CMakeLists.txt) and [GSInitialize.m](https://github.com/gnustep/android-examples/blob/master/hello-objectivec/app/src/main/cpp/GSInitialize.m).
6. Right-click "app", select "Link to C++". Choose your CMakeLists.txt
7. Edit CMakeLists.txt to include GSInitialize.m and your Objective-C implementation files in OBJECTUVEC_SRCS. Remove the the reference to "native-lib.cpp".
8. Edit app/build.gradle and add the following to android > defaultConfig:
```
externalNativeBuild {
  cmake {
    cppFlags ""
  }
}
ndk {
  // ABIs supported by GNUstep toolchain
  abiFilters "armeabi-v7a", "arm64-v8a", "x86", "x86_64"
}
```
9. Add the path to the custom NDK in File > Projet Structure… > SDK Location > Android NDK location
10. Write JNI functions for every call into your Objective-C code.
10. Load and call into the library from your android code. Example for a MainActivity written in Kotlin:
```
class MainActivity : AppCompatActivity() {

    external fun initializeGNUstep(context: Context?)
    external fun stringFromObjectiveC(context: Context?)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initializeGNUstep(this)
        stringFromObjectiveC(this)
        …
    }

    companion object {
        // Used to load the 'native-lib' library on application startup.
        init {
            System.loadLibrary("native-lib")
        }
    }
}
```

Examples
--------

The [android-examples](https://github.com/gnustep/android-examples) repository contains example projects using this project.

Acknowledgements
----------------

Based on original work by Ivan Vučica.
