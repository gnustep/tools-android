#!/bin/bash

cd `dirname $0`
export ROOT_DIR=`pwd`

# handle command-line options
# adapted from https://stackoverflow.com/a/31024664/1534401
while [[ $# > 0 ]]
do
  key="$1"
  while [[ ${key+x} ]]
  do
    case $key in
      -u|--no-update)
        echo "### Not updating projects"
        export NO_UPDATE=1
        ;;
      -n|--no-clean)
        echo "### Not cleaning projects"
        export NO_CLEAN=1
        ;;
      -h|--help)
        echo "Usage: $0"
        echo -e "\t-u, --no-update\tDon't update projects to latest version from GitHub"
        echo -e "\t-n, --no-clean\tDon't clean projects during build (e.g. for building local changes)"
        exit 0
        ;;
      *)
        # unknown option
        echo Unknown option: $key
        exit 1
        ;;
    esac
    # prepare for next option in this key, if any
    [[ "$key" = -? || "$key" == --* ]] && unset key || key="${key/#-?/-}"
  done
  shift # option(s) fully processed, proceed to next input argument
done

. "${ROOT_DIR}"/env/sdkenv.sh

mkdir -p "${SRCROOT}"

# keep backup of previous build if any
if [ -d "${INSTALL_PREFIX}" ]; then
  mv "${INSTALL_PREFIX}" "${INSTALL_PREFIX}.bak"
fi
mkdir -p "${INSTALL_PREFIX}"

# run phases
for PHASE in "${ROOT_DIR}"/phases/[0-9][0-9]-*.sh; do
  PHASE_NAME=`basename -s .sh $PHASE`
  PHASE_NAME=${PHASE_NAME/[0-9][0-9]-/}
  
  echo -e "\n###### ${PHASE_NAME} ######"
  
  ${PHASE}
  PHASE_RESULT=$?
  
  if [ $PHASE_RESULT -ne 0 ]; then
    echo -e "\n### phases/`basename $PHASE` failed"
    
    if [ -d "${INSTALL_PREFIX}.bak" ]; then
      rm -rf "${INSTALL_PREFIX}"
      mv "${INSTALL_PREFIX}.bak" "${INSTALL_PREFIX}"
      echo "The previous toolchain build has been restored."
    fi
    
    exit $PHASE_RESULT
  fi
done

# remove backup if all went well
rm -rf "${INSTALL_PREFIX}.bak"
