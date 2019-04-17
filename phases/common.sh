#!/bin/bash

. "${ROOT_DIR}"/env/sdkenv.sh

prepare_project () {
  PROJECT=$1
  REPO=$2

  cd "${SRCROOT}"

  if [ ! -d "${PROJECT}" ]; then
    echo -e "\n### Cloning project"
    git clone ${REPO} ${PROJECT}
  fi

  cd ${PROJECT}

  if [ ! -n "$NO_CLEAN" ]; then
    echo -e "\n### Cleaning project"
    git reset --hard
    git clean -qfdx
  fi

  if [ ! -n "$NO_UPDATE" ]; then
    echo -e "\n### Updating project"
    git pull
  fi

  for patch in "${ROOT_DIR}"/patches/${PROJECT}-*.patch; do
    if [ -f $patch ] ; then
      echo -e "\n### Applying `basename "$patch"`"
      patch -p1 --forward < "$patch" || [ $? -eq 1 ]
    fi
  done
}
