#!/bin/bash

set -e # make any subsequent failing command exit the script

cd `dirname $0`/..
export ROOT_DIR="$PWD"

# load environment
. "$ROOT_DIR"/scripts/sdkenv.sh

get_latest_github_release_tag () {
  GITHUB_REPO=$1
  TAG_PREFIX=$2
  
  # use GitHub token authentication on CI to prevent rate limit errors
  if [ -n "$GITHUB_TOKEN" ]; then
    GITHUB_AUTHORIZATION_HEADER="Authorization: Bearer $GITHUB_TOKEN"
  fi
  
  # get the tags JSON from the GitHub API and parse it manually,
  # or output it to stderr if the server returns an error
  github_tags=`curl \
    --silent --show-error --fail-with-body \
    --header "$GITHUB_AUTHORIZATION_HEADER" \
    https://api.github.com/repos/$GITHUB_REPO/tags`

  echo "$github_tags" \
    | grep '"name":' \
    | sed -E 's/.*"([^"]+)".*/\1/' \
    | egrep "^${TAG_PREFIX:-[a-z_-]+}[0-9]+[\._-][0-9]+([\._-][0-9]+)?\$" \
    | head -n 1
}

prepare_project () {
  PROJECT=$1
  REPO=$2
  TAG=$3

  # allow passing GitHub username/repo
  if [[ $REPO != http* ]]; then
    REPO=https://github.com/$REPO.git
  fi

  if [ ${REPO##*.} = "gz" ]; then
    # downloaded project
    
    archive_name=`basename $REPO`
    
    if [ ! -f "$CACHE_ROOT/$archive_name" ]; then
      echo -e "\n### Downloading project"
      mkdir -p "$CACHE_ROOT"
      cd "$CACHE_ROOT"
      curl -O -# $REPO
    fi

    cd "$SRCROOT"
    
    if [ ! -d "$PROJECT" -o "$NO_CLEAN" != true ]; then
      echo -e "\n### Extracting project"
      rm -rf $PROJECT
      mkdir $PROJECT
      tar -xzf "$CACHE_ROOT/$archive_name" -C $PROJECT --strip-components 1
    fi
    
    cd "$PROJECT"
    
  else
    # git project

    cd "$SRCROOT"
    
    if [ ! -d "$PROJECT" ]; then
      echo -e "\n### Cloning project"
      git clone --recursive $REPO $PROJECT
    fi
    
    cd "$PROJECT"

    if [ "$NO_CLEAN" != true ]; then
      echo -e "\n### Cleaning project"
      git reset --hard
      git clean -qfdx
    fi

    if [ "$NO_UPDATE" != true ]; then
      # check out tag/branch if any
      if [ -n "$TAG" ]; then
        echo -e "\n### Checking out \"$TAG\""
        git fetch --tags
        git checkout -q $TAG
      fi

      # check if we should update project
      git_branch=`git symbolic-ref --short -q HEAD || echo "NONE"`
      if [ "$git_branch" != "NONE" ]; then
        # check if current branch has a remote
        git_remote=`git config --get branch.$git_branch.remote || echo "NONE"`
        if [ "$git_remote" != "NONE" ]; then
          echo -e "\n### Updating project"
          git pull --ff-only
        else
          echo -e "\n### NOT updating project (no remote for branch $git_branch)"
        fi
      elif [ -z $TAG ]; then
        echo -e "\n### NOT updating project (not on branch)"
      fi

      git submodule sync --recursive
      git submodule update --recursive --init # also init in case submodule was added with update
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
  
  if [ "$NO_BUILD" != true ]; then
    mkdir -p "${INSTALL_PREFIX}"
    return 0
  else
    return 1
  fi
}
