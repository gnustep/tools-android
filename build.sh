#!/bin/bash

cd `dirname $0`
export ROOT_DIR=`pwd`

. "${ROOT_DIR}"/env/sdkenv.sh

# clean up src folder
rm -rf "${SRCROOT}"
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
  
  if [ $? -ne 0 ]; then
    echo -e "\n### phases/`basename $PHASE` failed"
    
    if [ -d "${INSTALL_PREFIX}.bak" ]; then
      rm -rf "${INSTALL_PREFIX}"
      mv "${INSTALL_PREFIX}.bak" "${INSTALL_PREFIX}"
      echo "The previous toolchain build has been restored."
    fi
    
    exit $?
  fi
done

# remove backup if all went well
rm -rf "${INSTALL_PREFIX}.bak"
