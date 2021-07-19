#!/bin/bash

cd `dirname $0`
ROOT_DIR=`pwd`

display_usage() {
  echo "Packages sources of GNUstep Android toolchain."
  echo "https://github.com/gnustep/tools-android"
  echo ""
  echo "Usage: $0"
  echo "  -p, --patches DIR          Apply additional patches from given directory"
  echo "  -h, --help                 Print usage information and exit"
}

. "${ROOT_DIR}"/scripts/sdkenv.sh

# handle command-line options
# adapted from https://stackoverflow.com/a/31024664/1534401
while [[ $# > 0 ]]
do
  key="$1"
  while [[ ${key+x} ]]
  do
    case $key in
      -p|--patches)
        export ADDITIONAL_PATCHES=$2
        echo "### Additional patches: ${ADDITIONAL_PATCHES}"
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

# don't update or build sources
export NO_UPDATE=true
export NO_BUILD=true

# run phases
for PHASE in $PHASE_GLOB; do
  PHASE_NAME=$(phase_name $PHASE)
  
  echo -e "\n###### $PHASE_NAME ######"
  
  ${PHASE}
done


# package sources
echo -e "\n###### Creating package ######"
today=`date "+%Y-%m-%d"`
package=gnustep-toolchain-sources-$today.tgz
tar -czf $package -C "$SRCROOT" .

echo "Packaged sources as $package"
