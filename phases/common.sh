#!/bin/bash

cd `dirname $0`/..
export ROOT_DIR=`pwd`

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

  if [ "$NO_CLEAN" != true ]; then
    echo -e "\n### Cleaning project"
    git reset --hard
    git clean -qfdx
  fi

  if [ "$NO_UPDATE" != true ]; then
    # check if we are on a branch
    git_branch=`git symbolic-ref --short -q HEAD || echo "NONE"`
    if [ "$git_branch" != "NONE" ]; then
      # check if current branch has a remote
      git_remote=`git config --get branch.$git_branch.remote || echo "NONE"`
      if [ "$git_remote" != "NONE" ]; then
        echo -e "\n### Updating project"
        git pull
      else
        echo -e "\n### NOT updating project (no remote for branch $git_branch)"
      fi
    else
      echo -e "\n### NOT updating project (not on branch)"
    fi
  fi

  if [ "$NO_PATCHES" != true ]; then
    for patch in {"${ROOT_DIR}"/patches,${ADDITIONAL_PATCHES}}/${PROJECT}-*.patch; do
      if [ -f $patch ] ; then
        patch_name=`basename "$patch"`
        echo -e "\n### Applying $patch_name"
        patch -p1 --forward < "$patch" || [ $? -eq 1 ]
      fi
    done
  fi
  
  mkdir -p "${INSTALL_PREFIX}"
}
