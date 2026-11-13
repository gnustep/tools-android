#!/bin/bash
#
# Records the revision and applied patches of the given project in build.txt
# in the install root, replacing any previous entry for the project.
#

set -e

cd `dirname $0`/..
export ROOT_DIR="$PWD"

. "$ROOT_DIR"/scripts/sdkenv.sh

PROJECT=$1

if [ -z "$PROJECT" ]; then
  echo "Usage: $0 <project>"
  exit 1
fi

SRC_DIR="$SRCROOT/$PROJECT"

write_header() {
  echo "Build type: $BUILD_TYPE"
  echo "NDK: `basename "$ANDROID_NDK_ROOT"`"
  echo "ABIs: $ABI_NAMES"
  echo "Android API level: $ANDROID_API_LEVEL"
}

write_entry() {
  echo "* $PROJECT"

  if [ -d "$SRC_DIR/.git" ]; then
    printf '\t- Revision: %s\n' "`git -C "$SRC_DIR" rev-parse HEAD`"

    tag=`git -C "$SRC_DIR" describe --tags --exact-match 2>/dev/null || true`
    if [ -n "$tag" ]; then
      printf '\t- Tag: %s\n' "$tag"
    fi
  else
    cache_files=("$CACHE_ROOT/$PROJECT"*)
    cache_file=${cache_files[${#cache_files[@]}-1]} # last item
    if [ -e "$cache_file" ]; then
      printf '\t- File: %s\n' "`basename "$cache_file"`"
    fi
  fi

  has_patches=false
  for patch_dir in "$ROOT_DIR/patches" ${ADDITIONAL_PATCHES:+"$ADDITIONAL_PATCHES"}; do
    for patch in "$patch_dir/$PROJECT"-*.patch; do
      if [ -f "$patch" ]; then
        if [ "$has_patches" != true ]; then
          printf '\t- Patches:\n'
          has_patches=true
        fi
        printf '\t\t%s\n' "`basename "$patch"`"
      fi
    done
  done
}

entry=`write_entry`

if [ -f "$BUILD_TXT" ]; then
  # replace previous entry for this project in place, or append it
  ENTRY="$entry" awk -v RS= -v header="* $PROJECT" '
    BEGIN { entry = ENVIRON["ENTRY"] }
    { split($0, lines, "\n"); if (lines[1] == header) { $0 = entry; found = 1 } }
    { print sep $0; sep = "\n" }
    END { if (!found) print sep entry }
  ' "$BUILD_TXT" > "$BUILD_TXT.tmp"
else
  { write_header; echo; echo "$entry"; } > "$BUILD_TXT.tmp"
fi

mv "$BUILD_TXT.tmp" "$BUILD_TXT"
