#!/bin/bash

cd `dirname $0`
export ROOT_DIR=`pwd`

display_usage() {
  echo "Usage: $0"
  echo "  -r, --rev NDK_REVISION     NDK revision (default: $ANDROID_NDK_VERSION)"
  echo "  -c, --clang CLANG_VERSION  Clang prebuilt release (default: $ANDROID_CLANG_VERSION)"
  echo "  -n, --ndk NDK_PATH         Path to existing Android NDK (default: $ANDROID_NDK_HOME)"
  echo "  -a, --abis ABI_NAMES       ABIs being targeted (default: \"${ABI_NAMES}\")"
  echo "  -l, --level API_LEVEL      Android API level being targeted (default: ${ANDROID_API_LEVEL})"
  echo "  -b, --build BUILD_TYPE     Build type \"Debug\" or \"Release\" (default: ${BUILD_TYPE})"
  echo "  -u, --no-update            Don't update projects to latest version from GitHub"
  echo "  -c, --no-clean             Don't clean projects during build (e.g. for building local changes, only applies to first ABI being built)"
  echo "  -p, --patches DIR          Apply additional patches from given directory"
  echo "  -o, --only PHASE           Build only the given phase (e.g. \"gnustep-base\", requires previous build)"
  echo "  -h, --help                 Print usage information and exit"
}

phase_name() {
  name=`basename -s .sh $1`
  echo ${name/[0-9][0-9]-/}
}

phase_glob="${ROOT_DIR}/phases/[0-9][0-9]-*.sh"

. "${ROOT_DIR}"/env/sdkenv.sh

# handle command-line options
# adapted from https://stackoverflow.com/a/31024664/1534401
while [[ $# > 0 ]]
do
  key="$1"
  while [[ ${key+x} ]]
  do
    case $key in
      -r|--rev)
        export ANDROID_NDK_VERSION=$2
        shift # option has parameter
        ;;
      -c|--clang)
        export ANDROID_CLANG_VERSION=$2
        shift # option has parameter
        ;;
      -n|--ndk)
        export ANDROID_NDK_HOME=$2
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
          
          for PHASE in ${phase_glob}; do
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

echo "### Build type: ${BUILD_TYPE}"
echo "### ABIs: ${ABI_NAMES}"
echo "### Android API level: ${ANDROID_API_LEVEL}"

# install custom NDK if required
if [ ! -d "${ANDROID_NDK_HOME}" ]; then
  echo "### Installing NDK $ANDROID_NDK_VERSION with Clang $ANDROID_CLANG_VERSION..."
  ./install-ndk.sh -r $ANDROID_NDK_VERSION -c $ANDROID_CLANG_VERSION || exit $?
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
  for PHASE in ${phase_glob}; do
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