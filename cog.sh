#!/bin/sh

set -a

CHECK="${1}"
LATEST_TAG_ONLY="${2}"
RELEASE="${3}"
GIT_USER="${4}"
GIT_USER_EMAIL="${5}"
VERIFY="${6}"

echo "Setting git user : ${GIT_USER}"
git config --global user.name "${GIT_USER}"

echo "Settings git user email ${GIT_USER_EMAIL}"
git config --global user.email "${GIT_USER_EMAIL}"

cog --version

OLD_VERSION=$(cog get-version 2>/dev/null || echo '')
echo "LATEST=${LATEST_VERSION}"

if [ "${CHECK}" = "true" ]; then
  if [ "${LATEST_TAG_ONLY}" = "true" ]; then
    if [ -n "${OLD_VERSION}" ]; then
      message="Checking commits from ${OLD_VERSION}"
    else
      message="No tag found checking history from first commit"
    fi
    echo "${message}"
    cog check --from-latest-tag || exit 1
  else
    echo "Checking all commits"
    cog check || exit 1
  fi
fi

if [ "${RELEASE}" = "true" ]; then
  cog bump --auto || exit 1
  NEW_VERSION=$(cog get-version 2>/dev/null || echo '')
  if [ -n "${NEW_VERSION}" ]; then 
    echo "version=${NEW_VERSION}" >> $GITHUB_OUTPUT
  fi
fi

if ( echo "${VERIFY}" | grep -Eiv '^([01]|(true)|(false))$' > /dev/null ) ; then
  cog verify "${VERIFY}" || exit 1
fi
