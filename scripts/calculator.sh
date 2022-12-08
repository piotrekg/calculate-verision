#!/bin/bash

function calculate_version {
  MAJOR_NUM=$(echo $2 | cut -d. -f1)
  MINOR_NUM=$(echo $2 | cut -d. -f2)
  PATCH_NUM=$(echo $2 | cut -d. -f3 | cut -d- -f1)

  NEW_MAJOR_NUM=$MAJOR_NUM
  NEW_MINOR_NUM=$MINOR_NUM
  NEW_PATCH_NUM=$PATCH_NUM

  if [ "${1,,}" = major ] ; then
    let NEW_MAJOR_NUM=$MAJOR_NUM+1
    NEW_MINOR_NUM=0
    NEW_PATCH_NUM=0
  elif [ "${1,,}" = minor ] ; then
    let NEW_MINOR_NUM=$MINOR_NUM+1
    NEW_PATCH_NUM=0
  elif [ "${1,,}" = patch ] ; then
    let NEW_PATCH_NUM=$PATCH_NUM+1
  fi

  echo $NEW_MAJOR_NUM.$NEW_MINOR_NUM.$NEW_PATCH_NUM
}

function calculate_build_version {
  MAJOR_NUM=$(echo $1 | cut -d. -f1)
  MINOR_NUM=$(echo $1 | cut -d. -f2)
  PATCH_NUM=$(echo $1 | cut -d. -f3)

  let NEW_MINOR_NUM=$MINOR_NUM+1

  echo $MAJOR_NUM.$NEW_MINOR_NUM.$PATCH_NUM-build.${CI_COMMIT_SHORT_SHA}
}

# Fetch git tags with versions different than hotfix, ignore grep not match as a part of logic related with version initialisation
set +e
PREV_VERSION=$(git tag | grep -E '.*[^hotfix]$' | tail -n 1)
set -e

if [ -z $PREV_VERSION ] ; then
  echo 'No version present, initialize first version'
  PREV_VERSION=0.0.0
fi

export HOTFIX="$(echo $CI_COMMIT_BRANCH | sed -n "s/^hotfix\/\([0-9.]*\).*/\1/p")"
if [ $HOTFIX ] || [ "${RELEASE,,}" == patch ] ; then
  export PREV_VERSION=$HOTFIX
  echo 'Overriding hotfix base' $RELEASE 'version'
fi

echo 'Last version:' $PREV_VERSION

if [ "${RELEASE,,}" = major ] || [ "${RELEASE,,}" = minor ] || [ "${RELEASE,,}" = patch ] ; then
  echo 'Bump' $RELEASE 'version'
  export RELEASE_VERSION=$(calculate_version $RELEASE $PREV_VERSION)
else
  echo 'Not release build, increment build version as default'
  export RELEASE_VERSION=$(calculate_build_version $PREV_VERSION)
fi

echo $RELEASE_VERSION > version.txt
echo 'New version:' $RELEASE_VERSION