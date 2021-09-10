#!/bin/bash

cd `dirname $0`
export ROOT_DIR=`pwd`

display_usage() {
  . "$ROOT_DIR"/scripts/sdkenv.sh
  
  echo "Builds GNUstep Android toolchain."
  echo "https://github.com/gnustep/tools-android"
  echo ""
  echo "Usage: $0"
  echo "  --prefix INSTALL_ROOT      Install toolchain into given directory (default: ${INSTALL_ROOT})"
  echo "  --dist-root DIST_ROOT      Make toolchain relocatable to given path relative to home folder on other machines"
  echo "                             (use \"HOME\" as placeholder for home folder, e.g. \"HOME/Library/Android/GNUstep\")"
  echo "  -n, --ndk NDK_PATH         Path to Android NDK (default: $ANDROID_NDK_ROOT)"
  echo "  -a, --abis ABI_NAMES       ABIs being targeted (default: \"${ABI_NAMES}\")"
  echo "  -l, --level API_LEVEL      Android API level being targeted (default: ${ANDROID_API_LEVEL})"
  echo "  -b, --build BUILD_TYPE     Build type \"Debug\" or \"Release\" or \"RelWithDebInfo\" (default: ${BUILD_TYPE})"
  echo "  -u, --no-update            Don't update projects to latest version from GitHub"
  echo "  -c, --no-clean             Don't clean projects during build (e.g. for building local changes, only applies to first ABI being built)"
  echo "  -p, --patches DIR          Apply additional patches from given directory"
  echo "  -o, --only PHASE           Build only the given phase (e.g. \"gnustep-base\", requires previous build)"
  echo "  -h, --help                 Print usage information and exit"
}

# handle command-line options
# adapted from https://stackoverflow.com/a/31024664/1534401
while [[ $# > 0 ]]
do
  key="$1"
  while [[ ${key+x} ]]
  do
    case $key in
      --prefix)
        export INSTALL_ROOT=$2
        shift # option has parameter
        ;;
      --dist-root)
        export DIST_ROOT=$2
        shift # option has parameter
        ;;
      -n|--ndk)
        export ANDROID_NDK_ROOT=$2
        shift # option has parameter
        ;;
      -a|--abis)
        export ABI_NAMES=$2
        shift # option has parameter
        ;;
      -l|--level)
        export ANDROID_API_LEVEL=$2
        shift # option has parameter
        ;;
      -b|--build)
        export BUILD_TYPE=$2
        shift # option has parameter
        ;;
      -u|--no-update)
        echo "### Not updating projects"
        export NO_UPDATE=true
        ;;
      -c|--no-clean)
        echo "### Not cleaning projects"
        export NO_CLEAN=true
        ;;
      -p|--patches)
        export ADDITIONAL_PATCHES=$2
        echo "### Additional patches: ${ADDITIONAL_PATCHES}"
        shift # option has parameter
        ;;
      -o|--only)
        export ONLY_PHASE=$2
        if [ ! -f "${ROOT_DIR}"/phases/[0-9][0-9]-${ONLY_PHASE}.sh ]; then
          echo "Error: Unknown phase \"${ONLY_PHASE}\""
          
          for PHASE in $PHASE_GLOB; do
            PHASES="${PHASES}$(phase_name $PHASE) "
          done
          
          echo "Valid phases: ${PHASES}"
          exit 1
        fi
        echo "### Building only ${ONLY_PHASE}"
        shift # option has parameter
        ;;
      -h|--help)
        display_usage
        exit 0
        ;;
      *)
        # unknown option
        echo Unknown option: $key
        display_usage
        exit 1
        ;;
    esac
    # prepare for next option in this key, if any
    [[ "$key" = -? || "$key" == --* ]] && unset key || key="${key/#-?/-}"
  done
  shift # option(s) fully processed, proceed to next input argument
done

. "$ROOT_DIR"/scripts/sdkenv.sh

# check if NDK exists
if [ -z $ANDROID_NDK_ROOT ]; then
  echo "Error: no Android NDK found."
  echo "Please install via Android Studio > SDK Manager > SDK Tools > NDK (Side by side),"
  echo "or use the --ndk option or ANDROID_NDK_ROOT environment variable to specify the"
  echo "path to your NDK installation."
  exit 1
elif [ ! -d "$ANDROID_NDK_ROOT" ]; then
  echo "Error: Android NDK folder not found: $ANDROID_NDK_ROOT"
  echo "Please install via Android Studio > SDK Manager > SDK Tools > NDK (Side by side),"
  echo "or use the --ndk option or ANDROID_NDK_ROOT environment variable to specify the"
  echo "path to your NDK installation."
  exit 1
fi

echo "### Build type: ${BUILD_TYPE}"
echo "### NDK: $(basename $ANDROID_NDK_ROOT 2>/dev/null)"
echo "### ABIs: ${ABI_NAMES}"
echo "### Android API level: ${ANDROID_API_LEVEL}"

# check if additional patches directory is valid
if [[ ! -z "$ADDITIONAL_PATCHES" && ! -d "$ADDITIONAL_PATCHES" ]]; then
  echo "Error: patches directory does not exist:"
  echo "    $ADDITIONAL_PATCHES"
  exit 1
fi

if [ -z "${ONLY_PHASE}" ]; then
  # keep backup of previous build if any
  if [ -d "${INSTALL_ROOT}" ]; then
    rm -rf "${INSTALL_ROOT}.bak"
    mv "${INSTALL_ROOT}" "${INSTALL_ROOT}.bak"
  fi

  # remove previous failed build if any
  rm -rf "${INSTALL_ROOT}.failed"
fi

mkdir -p "${SRCROOT}"
mkdir -p "${INSTALL_ROOT}"

# build toolchain for each ABI
for ABI_NAME in $ABI_NAMES; do
  echo -e "\n######## BUILDING FOR ${ABI_NAME} ########" | tee -a "${BUILD_LOG}"

  # run phases
  for PHASE in $PHASE_GLOB; do
    PHASE_NAME=$(phase_name $PHASE)
    
    if [[ ! -z "${ONLY_PHASE}" && "${ONLY_PHASE}" != "${PHASE_NAME}" ]]; then
      continue
    fi

    echo -e "\n###### ${PHASE_NAME} ######" | tee -a "${BUILD_LOG}"
    
    # execute phase for ABI
    ABI_NAME=$ABI_NAME ${PHASE} 2>&1 | tee -a "${BUILD_LOG}"
    PHASE_RESULT=${PIPESTATUS[0]}

    if [ $PHASE_RESULT -ne 0 ]; then
      echo -e "\n### phases/`basename $PHASE` failed for ABI ${ABI_NAME}" | tee -a "${BUILD_LOG}"

      if [ -d "${INSTALL_ROOT}.bak" ]; then
        mv "${INSTALL_ROOT}" "${INSTALL_ROOT}.failed"
        mv "${INSTALL_ROOT}.bak" "${INSTALL_ROOT}"
        echo -e "\nThe previous toolchain build has been restored. The failed build can be found at:\n${INSTALL_ROOT}.failed"
      fi

      exit $PHASE_RESULT
    fi
  done

  # don't update projects for subsequent ABIs to avoid mismatching builds
  export NO_UPDATE=true

  # always clean projects for subsequent ABIs
  export NO_CLEAN=false

done

# write build.txt
echo "Build type: ${BUILD_TYPE}" >> "${BUILD_TXT}"
echo "NDK: $(basename $ANDROID_NDK_ROOT)" >> "${BUILD_TXT}"
echo "ABIs: ${ABI_NAMES}" >> "${BUILD_TXT}"
echo "Android API level: ${ANDROID_API_LEVEL}" >> "${BUILD_TXT}"

for src in "${SRCROOT}"/*; do
  cd "${src}"
  PROJECT=`basename "${src}"`
  
  project_rev=`git rev-parse HEAD`
  echo -e "\n* ${PROJECT}" >> "${BUILD_TXT}"
  echo -e "\t- Revision: ${project_rev}" >> "${BUILD_TXT}"
  
  has_patches=false
  
  for patch in {"${ROOT_DIR}"/patches,${ADDITIONAL_PATCHES}}/${PROJECT}-*.patch; do
    if [ -f $patch ] ; then
      patch_name=`basename "$patch"`
      if [ "$has_patches" != true ]; then
        echo -e "\t- Patches:" >> "${BUILD_TXT}"
        has_patches=true
      fi
      echo -e "\t\t$patch_name" >> "${BUILD_TXT}"
    fi
  done
done

# remove backup if all went well
rm -rf "${INSTALL_ROOT}.bak"

echo -e "\n### Finished building GNUstep Android toolchain"

# make toolchain relocatable if requested
if [[ $DIST_ROOT ]]; then
  DIST_ROOT=${DIST_ROOT/HOME/\$\{HOME\}}
  ANDROID_SDK_DIST_ROOT=${ANDROID_SDK_ROOT/$HOME/\$\{HOME\}}
  ANDROID_NDK_DIST_ROOT=${ANDROID_NDK_ROOT/$HOME/\$\{HOME\}}
  
  echo -e "\n### Making toolchain relocatable with:"
  echo "### - DIST_ROOT: $DIST_ROOT"
  echo "### - ANDROID_SDK_ROOT: $ANDROID_SDK_DIST_ROOT"
  echo "### - ANDROID_NDK_ROOT: $ANDROID_NDK_DIST_ROOT"
  
  find "$INSTALL_ROOT" -type f -exec perl -i -pe "s|$INSTALL_ROOT|${DIST_ROOT/\$/\\\$}|g; s|$ANDROID_SDK_ROOT|${ANDROID_SDK_DIST_ROOT/\$/\\\$}|g; s|$ANDROID_NDK_ROOT|${ANDROID_NDK_DIST_ROOT/\$/\\\$}|g;" {} +
  
  echo -e "\n### Done"
fi
