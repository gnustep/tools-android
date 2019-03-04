#!/bin/bash

cd `dirname $0`
export ROOT_DIR=`pwd`

. "${ROOT_DIR}"/env/sdkenv.sh

# clean up src and installation folders
rm -rf "${SRCROOT}"
mkdir -p "${SRCROOT}"
rm -rf "${INSTALL_PREFIX}"
mkdir -p "${INSTALL_PREFIX}"

# run phases
for PHASE in "${ROOT_DIR}"/phases/[0-9][0-9]-*.sh; do
  PHASE_NAME=`basename -s .sh $PHASE`
  PHASE_NAME=${PHASE_NAME/[0-9][0-9]-/}
  
  echo -e "\n###### ${PHASE_NAME} ######"
  
  ${PHASE}
  
  if [ $? -ne 0 ]; then
    echo -e "\n### phases/`basename $PHASE` failed"
    exit $?
  fi
done

# create makeenv.conf
perl -pe 's/\${(\w+)}/$ENV{$1}/g' "${ROOT_DIR}"/env/makeenv.sh > "${INSTALL_PREFIX}"/etc/makeenv.conf
